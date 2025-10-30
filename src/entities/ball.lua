
local Ball = {}
Ball.__index = Ball

function Ball.new(x, y)
  return setmetatable({
    x=x, y=y, r=5,
    vx=0, vy=0,
    ax=0, ay=0,
    state="idle", -- idle | pitched | hit
    canHit=true,
  }, Ball)
end

function Ball:reset(x, y)
  self.x, self.y = x, y
  self.vx, self.vy = 0, 0
  self.ax, self.ay = 0, 0
  self.state = "idle"
  self.canHit = true
end

function Ball:pitch(vx, vy, ax, ay)
  self.vx, self.vy = vx, vy
  self.ax, self.ay = ax or 0, ay or 0
  self.state = "pitched"
  self.canHit = true
end

function Ball:update(dt)
  if self.state == "pitched" or self.state == "hit" then
    -- Integrate acceleration (break for pitched; none for hit)
    self.vx = self.vx + self.ax*dt
    self.vy = self.vy + self.ay*dt

    -- Friction only when 'hit' (top-down turf drag)
    if self.state == "hit" then
      local speed = math.sqrt(self.vx*self.vx + self.vy*self.vy)
      if speed > 0 then
        local drag = math.max(0, 1 - 1.2*dt) -- adjustable drag factor
        self.vx = self.vx * drag
        self.vy = self.vy * drag
        if speed < 24 then
          self.vx, self.vy = 0, 0
          self.state = "idle"
        end
      end
    end

    self.x = self.x + self.vx*dt
    self.y = self.y + self.vy*dt
  end
end

function Ball:draw()
  love.graphics.setColor(1,1,1)
  love.graphics.circle("fill", self.x, self.y, self.r)
  -- seams
  love.graphics.setColor(1,0,0)
  love.graphics.arc("line", self.x, self.y, self.r+2, -0.8, 0.8)
  love.graphics.arc("line", self.x, self.y, self.r+2, math.pi-0.8, math.pi+0.8)
  love.graphics.setColor(1,1,1)
end

return Ball
