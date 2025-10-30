
local Pitcher = {}
Pitcher.__index = Pitcher

function Pitcher.new(x, y)
  return setmetatable({x=x, y=y, selected=1}, Pitcher)
end

function Pitcher:draw()
  love.graphics.setColor(0.2,0.6,1)
  love.graphics.rectangle("fill", self.x-10, self.y-30, 20, 30)
  love.graphics.setColor(1,1,1)
end

return Pitcher
