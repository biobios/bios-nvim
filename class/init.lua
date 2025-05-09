local M = {}

local instance_metatable = {
    __add = function(self, other)
        return self:operator_add(other)
    end,
    __sub = function(self, other)
        return self:operator_sub(other)
    end,
    __mul = function(self, other)
        return self:operator_mul(other)
    end,
    __div = function(self, other)
        return self:operator_div(other)
    end,
    __mod = function(self, other)
        return self:operator_mod(other)
    end,
    __pow = function(self, other)
        return self:operator_pow(other)
    end,
    __unm = function(self)
        return self:operator_unm()
    end,
    __idiv = function(self, other)
        return self:operator_idiv(other)
    end,
    __band = function(self, other)
        return self:operator_band(other)
    end,
    __bor = function(self, other)
        return self:operator_bor(other)
    end,
    __bxor = function(self, other)
        return self:operator_bxor(other)
    end,
    __bnot = function(self)
        return self:operator_bnot()
    end,
    __shl = function(self, other)
        return self:operator_shl(other)
    end,
    __shr = function(self, other)
        return self:operator_shr(other)
    end,
    __concat = function(self, other)
        return self:operator_concat(other)
    end,
    __len = function(self)
        return self:operator_len()
    end,
    __eq = function(self, other)
        return self:operator_eq(other)
    end,
    __lt = function(self, other)
        return self:operator_lt(other)
    end,
    __le = function(self, other)
        return self:operator_le(other)
    end,
    __index = function(self, key)
        -- インスタンスではないなら、nilを返す
        local class = rawget(self, "class")
        if not class then
            return nil
        end
        local methods = rawget(class, "methods")
        if not methods then
            return nil
        end
        local operator_access = rawget(methods, "operator_access")
        if not operator_access then
            return nil
        end
        return operator_access(self, key)
    end,
    __call = function(self, ...)
        return self:operator_call(...)
    end,
}

local Metaclass = {
    methods = {
        operator_access = function(self, key)
            local class = rawget(self, "class")
            if not class then
                return nil
            end
            local methods = rawget(class, "methods")
            if not methods then
                return nil
            end
            return rawget(methods, key)
        end,
        operator_call = function(self, ...)
            local instance = {class = self}
            setmetatable(instance, instance_metatable)
            if instance.initialize then
                instance:initialize(...)
            end
            return instance
        end,
        set_method = function(self, method_name, method)
            self.methods = self.methods or {}
            self.methods[method_name] = method
        end,
    },
}

Metaclass.class = Metaclass
setmetatable(Metaclass, instance_metatable)
local Class = Metaclass()
Class:set_method("operator_call", Metaclass.methods.operator_call)
Class:set_method("set_method", Metaclass.methods.set_method)
Class:set_method("operator_access", function(self, key)
    local class = rawget(self, "class")
    while class do
        local methods = rawget(class, "methods")
        if not methods then
            class = class.super
            goto continue
        end
        local method = rawget(methods, key)
        if method then
            return method
        end
        class = class.super
        ::continue::
    end
    return nil
end)
Class:set_method("subclass", 
    function(self)
        local subMetaclass = Metaclass()
        subMetaclass:set_method("operator_access", Class.methods.operator_access)
        subMetaclass.super = self.class
        local subclass = subMetaclass()
        subclass.super = self
        return subclass
    end
)
Class:set_method("initialize", function(self, ...)
    self:set_method("operator_access", Class.methods.operator_access)
end)

local Object = Class()

function M.def_class(class_definition)
    if type(class_definition) ~= "table" then
        error("class_definition must be a table")
    end
    local class
    if class_definition.super then
        class = class_definition.super:subclass()
    else
        class = Object:subclass()
    end
    if class_definition.static then
        for k, v in pairs(class_definition.static) do
            class.class:set_method(k, v)
        end
    end
    
    if class_definition.methods then
        for k, v in pairs(class_definition.methods) do
            class:set_method(k, v)
        end
    end
    return class
end

function M:setup()
end

return M