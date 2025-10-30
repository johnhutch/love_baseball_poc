
package.path = package.path .. ";src/?.lua;src/?/init.lua;src/?/?.lua"

local Game = require("game")

function love.load()
  love.graphics.setDefaultFilter("nearest","nearest",1)
  Game:load()
end

function love.update(dt)
  Game:update(dt)
end

function love.draw()
  Game:draw()
end

function love.keypressed(key)
  Game:keypressed(key)
end
