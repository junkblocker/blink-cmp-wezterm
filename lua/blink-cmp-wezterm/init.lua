---@class blink-cmp-wezterm.Opts
---@field all_panes boolean
---@field capture_history boolean
---@field triggered_only boolean
---@field trigger_chars string[]

---@type blink-cmp-wezterm.Opts
local default_opts = {
    all_panes = true,
    capture_history = true,
    triggered_only = false,
    trigger_chars = { "." },
}

--- @module 'blink.cmp'
---@class blink.cmp.weztermSource: blink.cmp.Source
---@field opts blink-cmp-wezterm.Opts
local wezterm = {}

---@param opts blink-cmp-wezterm.Opts
---@return blink.cmp.weztermSource
function wezterm.new(opts)
    vim.validate('wezterm.opts.all_panes', opts.all_panes, { 'boolean' }, true)
    vim.validate('wezterm.opts.capture_history', opts.capture_history, { 'boolean' }, true)
    vim.validate('wezterm.opts.triggered_only', opts.triggered_only, { 'boolean' }, true)
    vim.validate('wezterm.opts.trigger_chars', opts.trigger_chars, { 'table' }, true)

    local self = setmetatable({}, { __index = wezterm })

    self.opts = vim.tbl_deep_extend("force", default_opts, opts)

    return self
end

---@return boolean
function wezterm:enabled()
    return vim.fn.executable("wezterm") == 1 and os.getenv("TERM_PROGRAM") == "WezTerm"
end

---@return string[]
function wezterm:get_trigger_characters()
    return self.opts.trigger_chars
end

---@param pane_id string
---@return string
function wezterm:get_pane_content(pane_id)
    local cmd = { "wezterm", "cli", "get-text", "--pane-id", pane_id }

    if self.opts.capture_history then
        table.insert(cmd, "--start-line")
        table.insert(cmd, "-2147483648")
        table.insert(cmd, "--end-line")
        table.insert(cmd, "2147483647")
    end

    return vim.system(cmd, { text = true }):wait().stdout
end

---@return string[]
function wezterm:get_words()
    local words = {}

    vim.iter(self:get_pane_ids()):each(function(id)
        -- match not only full words, but urls, paths, etc.
        vim.iter(string.gmatch(self:get_pane_content(id), "[%w%d_:/.%-~][%w%d_:/.%-~]+")):each(function(word)
            if #word > 2 then
                words[word] = true
            end

            -- but also isolate the words from the result
            for sub_word in string.gmatch(word, "[a-zA-Z0-9_:.%-~]+") do
                if #sub_word > 2 then
                    words[sub_word] = true
                end
            end
        end)
    end)

    return vim.tbl_keys(words)
end

---@return string[]
function wezterm:get_pane_ids()
    local ids          = {}
    local cmd          = { "wezterm", "cli", "list" }

    local lines        = vim.fn.systemlist(cmd)
    local wezterm_pane = os.getenv("WEZTERM_PANE")
    for i = 2, #lines do
        local id = lines[i]:match("^%s+%d+%s+%d+%s+(%d+)")
        if id ~= nil and (self.opts.all_panes or wezterm_pane ~= id) then
            table.insert(ids, id)
        end
    end

    return ids
end

---@param context blink.cmp.Context
---@return lsp.CompletionItem[]
function wezterm:get_completion_items(context)
    return vim.iter(self:get_words())
        :map(function(word)
            ---@type lsp.CompletionItem
            local item = {
                label = word,
                kind = require("blink.cmp.types").CompletionItemKind.Text,
                insertText = word,
            }
            if self.opts.triggered_only then
                item = vim.tbl_deep_extend("force", item, {
                    textEdit = {
                        newText = word,
                        range = {
                            start = { line = context.cursor[1] - 1, character = context.bounds.start_col - 2 },
                            ["end"] = { line = context.cursor[1] - 1, character = context.cursor[2] },
                        },
                    },
                })
            end
            return item
        end)
        :totable()
end

---@param context blink.cmp.Context
---@param callback fun(items: blink.cmp.CompletionItem[])
function wezterm:get_completions(context, callback)
    vim.schedule(function()
        local triggered = not self.opts.triggered_only
            or vim.list_contains(
                self:get_trigger_characters(),
                context.line:sub(context.bounds.start_col - 1, context.bounds.start_col - 1)
            )
        callback({
            items = triggered and self:get_completion_items(context) or {},
            is_incomplete_backward = true,
            is_incomplete_forward = true,
        })
    end)
end

return wezterm
