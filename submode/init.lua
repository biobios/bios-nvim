local M = {}

local SID = vim.fn.expand("<SID>")

local class = require("bios-nvim.class")

M.setup = function(self)
end 

local class_submode = class.def_class
{
    static = {
        SID = vim.fn.expand("<SID>"),
        ID = 0,
        get_id = function(self)
            self.ID = self.ID + 1
            return self.SID .. self.ID .. "_"
        end,
    }
    methods = {
        initialize = function(self, name, enter_cmd, modes)
            self.name = name
            self.modes = modes
            self.id = self.class:get_id()
            vim.keymap.set(modes, enter_cmd, function()
                vim.opt.timeout = false
                vim.notify("-- " .. name .. " --")
                return self.id .. name
            end, { script = true, noremap = true, nowait = true, expr = true })
            vim.keymap.set(modes, self.id .. name, self:get_leave_submode_with_cmd(""), { noremap = true, expr = true })
        end,
        add_command = function(self, lhs, rhs, opts)
            if not opts then
                opts = {}
            end
            if not opts.expr then
                opts.expr = true
            end
            vim.keymap.set(self.modes, self.id .. self.name .. lhs, self:get_leave_submode_with_cmd(rhs), opts)
        end,
        get_leave_submode_with_cmd = function(self, cmd)
            return function()
                vim.opt.timeout = true
                vim.notify(" ")
                return cmd
            end
        end,
    }
}

M.make_submode = function(name, enter_cmd, modes)
    return class_submode(name, enter_cmd, modes)
end

return M