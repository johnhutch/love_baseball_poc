
local State = {}
State.__index = State

function State.new()
  local s = setmetatable({}, State)
  s.stack = {}
  return s
end

function State:push(st)
  table.insert(self.stack, st)
  if st.enter then st:enter() end
end

function State:pop()
  local st = table.remove(self.stack)
  if st and st.exit then st:exit() end
end

function State:update(dt)
  if #self.stack > 0 and self.stack[#self.stack].update then
    self.stack[#self.stack]:update(dt)
  end
end

function State:draw()
  for i=1,#self.stack do
    local st = self.stack[i]
    if st.draw then st.draw(st) end
  end
end

function State:keypressed(key)
  if #self.stack > 0 and self.stack[#self.stack].keypressed then
    self.stack[#self.stack]:keypressed(key)
  end
end

return State
