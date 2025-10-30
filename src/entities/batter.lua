
local Batter = {}
Batter.__index = Batter

local function easeInOutQuad(t)
  if t < 0.5 then
    return 2*t*t
  else
    return 1 - ((-2*t + 2)^2)/2
  end
end

function Batter.new(x, y, leftBound, rightBound)
  local self = setmetatable({}, Batter)
  self.x, self.y = x, y
  self.leftBound = leftBound or x-40
  self.rightBound = (rightBound or x+40) + 36  -- allow overlap toward plate

  -- Start back at ~7 o'clock (≈120°). Reverse swing direction (clockwise) with a big follow-through.
  self.restAngle   = math.rad(120)
  self.startAngle  = self.restAngle
  self.sweep       = math.rad(-270)  -- NEGATIVE = clockwise in LÖVE's coordinate system
  self.batAngle    = self.restAngle
  self.batLen      = 70

  self.isSwinging   = false
  self.swingTimer   = 0
  self.swingDur     = 0.60           -- slower for readability

  return self
end

function Batter:update(dt)
  -- horizontal movement
  local speed = 200
  if love.keyboard.isDown("left") then
    self.x = math.max(self.leftBound, self.x - speed*dt)
  elseif love.keyboard.isDown("right") then
    self.x = math.min(self.rightBound, self.x + speed*dt)
  end

  if self.isSwinging then
    self.swingTimer = self.swingTimer + dt
    local t = self.swingTimer / self.swingDur
    if t >= 1 then
      self.isSwinging = false
      self.batAngle = self.restAngle
    else
      local te = easeInOutQuad(t)
      self.batAngle = self.startAngle + self.sweep * te
    end
  else
    self.batAngle = self.restAngle
  end
end

function Batter:swing()
  -- Always (re)start swing from restAngle
  self.isSwinging = true
  self.swingTimer = 0
  self.batAngle = self.startAngle
end

function Batter:getHandle()
  return self.x, self.y-10
end

function Batter:getBatTip()
  local hx, hy = self:getHandle()
  local tipx = hx + math.cos(self.batAngle)*self.batLen
  local tipy = hy + math.sin(self.batAngle)*self.batLen
  return tipx, tipy
end

function Batter:draw()
  -- body
  love.graphics.setColor(1,0.8,0.2)
  love.graphics.rectangle("fill", self.x-10, self.y-40, 20, 40)

  -- bat
  local hx, hy = self:getHandle()
  local tipx, tipy = self:getBatTip()
  love.graphics.setColor(0.8,0.6,0.2)
  love.graphics.setLineWidth(6)
  love.graphics.line(hx, hy, tipx, tipy)
  love.graphics.setLineWidth(1)

  love.graphics.setColor(1,1,1,0.3)
  love.graphics.circle("line", tipx, tipy, 10)
  love.graphics.setColor(1,1,1,1)
end

return Batter
