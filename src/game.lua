
local Input = require("core.input")
local State = require("core.state")
local PlayState = require("states.playstate")

local Game = {
  state = nil
}

function Game:load()
  self.input = Input.new()
  self.state = State.new()
  self.state:push(PlayState.new(self.input))
end

function Game:update(dt)
  self.state:update(dt)
  -- clear one-frame presses AFTER update so states can read them
  if self.input and self.input.clear then self.input:clear() end
end

function Game:draw()
  self.state:draw()
end

function Game:keypressed(key)
  if key == "escape" then love.event.quit() end
  if self.input and self.input.record then self.input:record(key) end
  self.state:keypressed(key)
end

return Game
