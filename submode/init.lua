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
    },
    methods = {
        initialize = function(self, name, enter_cmd, modes)
            self.name = name
            self.modes = modes
            self.id = self.class:get_id()
            vim.keymap.set(modes, enter_cmd, function()
                vim.opt.timeout = false
                vim.notify("-- " .. name .. " --")
                return self.id
            end, { script = true, noremap = true, nowait = true, expr = true, silent = true })
            vim.keymap.set(modes, self.id, self:get_leave_submode_with_cmd(""), { noremap = true, expr = true })
        end,
        add_command = function(self, lhs, rhs, opts)
            if not opts then
                opts = {}
            end
            if opts.continue or opts.leave == false then
                rhs = self:get_continue_submode_after_cmd(rhs)
            else
                rhs = self:get_leave_submode_with_cmd(rhs)
            end
            if type(rhs) == "function" and not opts.expr then
                opts.expr = true
            end
            vim.keymap.set(self.modes, self.id .. lhs, rhs, opts)
        end,
        get_leave_submode_with_cmd = function(self, cmd)
            if type(cmd) == "function" then
                return function()
                    vim.opt.timeout = true
                    vim.notify(" ")
                    local ret_cmd = cmd()
                    if type(ret_cmd) == "string" then
                        return ret_cmd
                    end
                end
            else
                return function()
                    vim.opt.timeout = true
                    vim.notify(" ")
                    return cmd
                end
            end
        end,
        get_continue_submode_after_cmd = function(self, cmd)
            if type(cmd) == "function" then
                return function()
                    local ret_cmd = cmd()
                    if type(ret_cmd) == "string" then
                        return ret_cmd .. self.id
                    else
                        return self.id
                    end
                end
            else
                return cmd .. self.id
            end
        end,
    }
}

M.make_submode = function(name, enter_cmd, modes)
    return class_submode(name, enter_cmd, modes)
end

return M