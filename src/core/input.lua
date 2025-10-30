
local Input = {}
Input.__index = Input

function Input.new()
  local s = setmetatable({}, Input)
  s.pressed = {}
  return s
end

function Input:record(key)
  self.pressed[key] = true
end

function Input:wasPressed(key)
  return self.pressed[key] == true
end

function Input:clear()
  -- Call once per frame if you want 'just pressed' semantics
  for k,_ in pairs(self.pressed) do self.pressed[k] = nil end
end

return Input
