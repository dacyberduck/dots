local added = vifm.keys.add {
    shortcut = "<a-j>",
    modes = { "cmdline" },
    description = "go up",
    handler = function()
        local c = vifm.currview().cursor
        c.pos = c.pos + 1
    end,
}
if not added then
    vifm.sb.error("Failed to register Alt-j key")
end

local added = vifm.keys.add {
    shortcut = "<a-k>",
    modes = { "cmdline" },
    description = "go down",
    handler = function()
        local c = vifm.currview().cursor
        c.pos = c.pos - 1
    end,
}
if not added then
    vifm.sb.error("Failed to register Alt-k key")
end

local added = vifm.keys.add {
    shortcut = "<a-h>",
    modes = { "cmdline" },
    description = "go to parent",
    handler = function()
        vifm.currview():cd("..")
    end,
}
if not added then
    vifm.sb.error("Failed to register Alt-h key")
end

local added = vifm.keys.add {
    shortcut = "<a-l>",
    modes = { "cmdline" },
    description = "enter directory",
    handler = function()
        local v = vifm.currview()
        local e = v:entry(v.currententry)
        if e.type == 'dir' then
            v:cd(e.name)
        end
    end,
}
if not added then
    vifm.sb.error("Failed to register Alt-l key")
end

return {}
