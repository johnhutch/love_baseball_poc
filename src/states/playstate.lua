
local Ball = require("entities.ball")
local Pitcher = require("entities.pitcher")
local Batter = require("entities.batter")

local PlayState = {}
PlayState.__index = PlayState

local FIELD = {
  width = 1024, height = 576,
  moundX = 512, moundY = 120,
  plateX = 512, plateY = 520,
  boxW = 120, boxH = 90, boxY = 450, boxOffsetX = 160
}

local function clamp(v, mn, mx) if v<mn then return mn elseif v>mx then return v end return mx end

local Pitches = {
  [1] = function() local vy=420; local vx=0; return vx,vy,0,0 end,
  [2] = function() local vy=320; local vx=-30; return vx,vy,-35,140 end,
  [3] = function() local vy=240; local vx=10; return vx,vy,12,20 end
}

-- point to segment distance
local function pointToSegmentSq(px,py, x1,y1, x2,y2)
  local vx, vy = x2-x1, y2-y1
  local wx, wy = px-x1, py-y1
  local len2 = vx*vx + vy*vy
  local t = 0
  if len2 > 0 then
    t = (wx*vx + wy*vy) / len2
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
  end
  local cx, cy = x1 + t*vx, y1 + t*vy
  local dx, dy = px - cx, py - cy
  return (dx*dx + dy*dy), t, cx, cy
end

local function normalize(x,y)
  local m = math.sqrt(x*x + y*y)
  if m == 0 then return 0,0 end
  return x/m, y/m
end

function PlayState.new(input)
  local s = setmetatable({}, PlayState)
  s.input = input
  s.pitcher = Pitcher.new(FIELD.moundX, FIELD.moundY)

  s.leftBoxX = FIELD.plateX - FIELD.boxOffsetX
  s.rightBoxX = FIELD.plateX + FIELD.boxOffsetX
  local startX = s.leftBoxX
  local leftBound = startX - FIELD.boxW/2 + 12
  local rightBound = startX + FIELD.boxW/2 - 12 + 36
  s.batter = Batter.new(startX, FIELD.boxY + FIELD.boxH, leftBound, rightBound)

  s.ball = Ball.new(s.pitcher.x, s.pitcher.y-8)
  s.selectedPitch = 1
  s.hudMsg = "1=FB 2=CB 3=CH | P=Pitch | SPACE=Swing | Left/Right=Move | R=Reset"
  return s
end

function PlayState:enter() end
function PlayState:exit() end

function PlayState:update(dt)
  self.batter:update(dt)
  self.ball:update(dt)

  -- No gravity in top-down after hit; pitched ball keeps its break via ax/ay set at pitch time.

  -- SPACE -> swing
  if self.input and self.input.wasPressed and self.input:wasPressed("space") then
    self.batter:swing()
  end

  -- Collision with any point on the bat segment while swinging
  if self.batter.isSwinging and self.ball.canHit and (self.ball.state == "pitched") then
    local hx, hy = self.batter:getHandle()
    local tx, ty = self.batter:getBatTip()
    local dist2, t, cx, cy = pointToSegmentSq(self.ball.x, self.ball.y, hx, hy, tx, ty)
    local sweetRadius = self.ball.r + 6
    if dist2 <= sweetRadius*sweetRadius then
      self.ball.canHit = false

      -- Base exit velocity from incoming + swing power
      local vin = math.sqrt(self.ball.vx*self.ball.vx + self.ball.vy*self.ball.vy)
      local batPower = 560
      local ev = math.max(220, math.min(780, 0.55*vin + 0.7*batPower))

      -- Barrel bonus
      if t >= 0.7 and t <= 0.9 then
        ev = ev * 1.15
      end

      -- Compute reflection across bat normal to send ball generally back where it came from
      local ux, uy = normalize(tx - hx, ty - hy)         -- bat direction (handle -> tip)
      local nx, ny = -uy, ux                              -- a normal (perpendicular)
      local ivx, ivy = self.ball.vx, self.ball.vy        -- incoming vector
      -- Reflect: r = v - 2*(v·n)*n
      local dot = ivx*nx + ivy*ny
      local rx = ivx - 2*dot*nx
      local ry = ivy - 2*dot*ny

      -- Blend a little of the bat direction to model swing follow-through influence
      local rdx, rdy = normalize(rx, ry)
      local mix = 0.18
      local dirx = rdx*(1-mix) + ux*mix
      local diry = rdy*(1-mix) + uy*mix
      dirx, diry = normalize(dirx, diry)

      self.ball.vx = dirx * ev
      self.ball.vy = diry * ev
      self.ball.state = "hit"
      -- No further acceleration in top-down (no gravity); zero out break
      self.ball.ax, self.ball.ay = 0, 0
    end
  end
end

function PlayState:draw()
  love.graphics.clear(0.05,0.12,0.05)
  -- dirt lane from mound to plate
  love.graphics.setColor(0.48,0.35,0.2)
  love.graphics.rectangle("fill", FIELD.plateX-60, FIELD.moundY, 120, FIELD.plateY - FIELD.moundY + 20)

  -- plate
  love.graphics.setColor(1,1,1)
  love.graphics.polygon("fill",
    FIELD.plateX-20, FIELD.plateY-16,
    FIELD.plateX+20, FIELD.plateY-16,
    FIELD.plateX+28, FIELD.plateY,
    FIELD.plateX,     FIELD.plateY+16,
    FIELD.plateX-28, FIELD.plateY
  )

  -- batter boxes
  love.graphics.setColor(0.9,0.9,0.9,0.15)
  love.graphics.rectangle("line", self.leftBoxX - FIELD.boxW/2, FIELD.boxY, FIELD.boxW, FIELD.boxH)
  love.graphics.rectangle("line", self.rightBoxX - FIELD.boxW/2, FIELD.boxY, FIELD.boxW, FIELD.boxH)

  -- mound
  love.graphics.setColor(0.6,0.45,0.25)
  love.graphics.circle("fill", FIELD.moundX, FIELD.moundY, 28)

  -- entities
  self.pitcher:draw()
  self.batter:draw()
  self.ball:draw()

  -- HUD
  love.graphics.setColor(1,1,1)
  love.graphics.print(self.hudMsg, 16, 16)
  local info = string.format("Pitch: %s | Ball: %s",
    ({[1]='Fastball',[2]='Curveball',[3]='Changeup'})[self.selectedPitch], self.ball.state)
  love.graphics.print(info, 16, 36)
end

function PlayState:keypressed(key)
  if key == "space" then
    self.batter:swing()
  elseif key == "p" then
    if self.ball.state == "idle" then
      local make = Pitches[self.selectedPitch] or Pitches[1]
      local vx, vy, ax, ay = make()
      self.ball:pitch(vx, vy, ax, ay)
    end
  elseif key == "r" then
    self.ball:reset(self.pitcher.x, self.pitcher.y-8)
    self.batter.isSwinging = false
    self.batter.swingTimer = 0
    self.batter.batAngle = self.batter.restAngle
  elseif key == "1" then
    self.selectedPitch = 1
  elseif key == "2" then
    self.selectedPitch = 2
  elseif key == "3" then
    self.selectedPitch = 3
  end
end

return PlayState
