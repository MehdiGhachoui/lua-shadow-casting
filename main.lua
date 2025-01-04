require "light"

local width,height = 640,480
local ball

drawSingleLight = drawRaycastedFan

love.load = function()
  love.window.setMode(width,height)
  love.physics.setMeter(64)
  world = love.physics.newWorld(0,9.81*64)

  local space = 10
  local s,b,f

  --- Create boundaries
  b = love.physics.newBody(world)
  s = love.physics.newChainShape(
    true,
    space,space,
    width-space,space,
    width-space,height-space,
    space,height-space
  )
  f = love.physics.newFixture(b,s)
  f:setRestitution(1)

  --- Create a torch
  b = love.physics.newBody(world, 130, 300, "static")
  s = love.physics.newCircleShape(10)
  f = love.physics.newFixture(b, s)
  f:setRestitution(1)

  ball = b
  -- b:applyLinearImpulse(50,0)

  --- Create a couple squares
  --- So that the light has something interesting
  --- to interact with
  b = love.physics.newBody(world)

  s = love.physics.newPolygonShape( 200, 200, 250, 200, 250, 250, 200, 250 )
  f = love.physics.newFixture(b, s)

  s = love.physics.newPolygonShape( 300, 300, 350, 300, 350, 350, 300, 350 )
  f = love.physics.newFixture(b, s)
end

love.draw = function ()
  local x,y = ball:getWorldCenter()

  love.graphics.setColor(0.5,0.5,0.5)
  drawSingleLight(world,x,y)

  love.graphics.setColor(1, 1, 1)
  for _, body in pairs(world:getBodies()) do
      for _, fixture in pairs(body:getFixtures()) do
          local shape = fixture:getShape()

          if shape:typeOf("CircleShape") then
              local cx, cy = body:getWorldPoints(shape:getPoint())
              love.graphics.circle("fill", cx, cy, shape:getRadius())
          elseif shape:typeOf("PolygonShape") then
              love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
          else
              love.graphics.line(body:getWorldPoints(shape:getPoints()))
          end
      end
  end

end

love.update = function (dt)
  world:update(dt)
end
