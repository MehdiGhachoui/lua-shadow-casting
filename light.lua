local lightShader = love.graphics.newShader([[
  uniform vec2 lightPos;

  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
    float d = distance(screen_coords,lightPos)/100;
    float intensity = 1.0/(1.0+d*d);

    return color * vec4(intensity,intensity,intensity,1);
  }
]])

local closestX, closestY, closestF
local dx,dy

--- It projects light away from the source.
--- Light only reaches the places that the source can see.
--- @param world love.World
--- @param x number -- the x position of the light
--- @param y number -- the y position of the light
--- @param skipLines boolean -- if true the function won't draw any lines
function drawRaycastedLines(world,x,y,skipLines)
  local slices = 128 --- Number of the rays comming out of the ligth
  local radius = 1000
  local points = {}
  local vertices = {}
  local angles = {}

  for _,body in pairs(world:getBodies()) do
    for _, fixture in pairs(body:getFixtures()) do
      local shape = fixture:getShape()
      if shape:typeOf("PolygonShape") then
        local a,b,c,d,e,f,g,h = body:getWorldPoints(shape:getPoints())
        vertices[#vertices+1] = {x=a,y=b}
        vertices[#vertices+1] = {x=c,y=d}
        vertices[#vertices+1] = {x=e,y=f}
        vertices[#vertices+1] = {x=g,y=h}
      end
    end
  end

  for i = 1, #vertices do
    local ang = math.atan2(vertices[i].y - y, vertices[i].x - x)
    angles[#angles+1] = { angle = ang - 0.0005 };
		angles[#angles+1] = { angle = ang + 0.0005 };
  end

  table.sort(angles, function(a, b)
      return a.angle < b.angle
    end
  );

  --- Cast rays in all direction
  for  i= 1, #angles do
    dx,dy = math.cos(angles[i].angle),math.sin(angles[i].angle)

    --- Cast outward
    dx = dx*radius
    dy = dy*radius

    --- Calculate the colsest point in the physics world
    closestX = x + dx
    closestY = y + dy
    closestF = 1

    --- Casts a ray and calls a function for each fixtures it intersects.
    world:rayCast(x,y,x+dx,y+dy,rayCastCallback)
    if not skipLines then
      love.graphics.line(x,y,closestX,closestY)
    end

    table.insert(points,{x=closestX,y=closestY})
  end

  return points
end

--- @param fixture love.Fixture -- the fixture intersecting the ray.
--- @param cx number -- The x position of the intersection point.
--- @param cy number -- The y position of the intersection point.
--- @param xn number -- The x value of the surface normal vector of the shape edge.
--- @param yn number -- The y value of the surface normal vector of the shape edge.
--- @param fraction number --The position of the intersection on the ray as a number from 0 to 1 (or even higher if the ray length was changed with the return value).
function rayCastCallback(fixture,cx,cy,xn,yn,fraction)
  --- If the collision is the new closest
  --- Updated the closest X and Y
  if fraction < closestF then
    closestF = fraction
    closestX = cx
    closestY = cy
  end
  --- Keep tracing the ray no matter what
  return 1
end

function drawRaycastedFan(world,x,y)
  local points = drawRaycastedLines(world,x,y,true)

  -- Now, we draw a "fan" for every point in the light
  -- Pretty much all this has to do is rearrange the data
  -- into a table that love.draw.polygon() can use
  local vertices = {}

  --- Center of the fan
  table.insert(vertices,x)
  table.insert(vertices,y)

  --- Draw the outside points
  for i = 1, #points do
    local point = points[i]

    table.insert(vertices,point.x)
    table.insert(vertices,point.y)
  end

  --- Send the light's location
  -- lightShader:send("lightPos",{x,y})

  --- Draw the fan
  -- love.graphics.setShader(lightShader)
  love.graphics.polygon("line",vertices)
  -- love.graphics.setShader()
end
