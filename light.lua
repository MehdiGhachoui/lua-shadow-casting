local closestX, closestY, closestF
local dx,dy

--- It projects light away from the source.
--- Light only reaches the places that the source can see.
--- @param x number -- the x position of the light
--- @param y number -- the y position of the light
function drawRaycastedLines(x,y)
  local slices = 128 --- Number of the rays comming out of the ligth
  local radius = 1000

  --- Cast rays in all direction
  for theta = 0, math.pi*2, math.pi/slices*2 do -- why ?
    dx,dy = math.cos(theta),math.sin(theta)

    --- Cast outward
    dx = dx*radius
    dy = dy*radius

    --- Calculate the colsest point in the physics world
    closestX = x + dx
    closestY = y + dy
    closestF = 1

    --- Casts a ray and calls a function for each fixtures it intersects.
    world:rayCast(x,y,x+dx,y+dy,rayCastCallback)
    love.graphics.line(x,y,closestX,closestY)
  end
end

--- @param fixture love.Fixture -- the fixture intersecting the ray.
--- @param cx number -- The x position of the intersection point.
--- @param cy number -- The y position of the intersection point.
--- @param xn number -- The x value of the surface normal vector of the shape edge.
--- @param yn number -- The y value of the surface normal vector of the shape edge.
--- @pram fraction number --The position of the intersection on the ray as a number from 0 to 1 (or even higher if the ray length was changed with the return value).
function rayCastCallback(fixture,cx,cy,xn,yn,fraction)
  ---If the collision is the new closest
  --- Updated the closest X and Y
  if fraction < closestF then
    closestF = fraction
    closestX = cx
    closestY = cy
  end
  --- Keep tracing the ray no matter what
  return -1
end
