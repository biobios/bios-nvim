local M = {}

M.class = require("bios-nvim.class")
-- M.user_operator = require("bios-nvim.user-operator")
M.submode = require("bios-nvim.submode")

function M.setup(self)
    self = self or {}
    -- self.user_operator = self.user_operator or M.user_operator
    self.submode = self.submode or M.submode
    self.class = self.class or M.class

    self.class:setup()
    -- self.user_operator:setup()
    self.submode:setup()
end

return M