local Voronoi = require 'voronoi'
local Graph = require 'graph'

function love.load()
    --variables
    gameWidth = 640
    gameHeight = 480
    love.window.setMode(gameWidth, gameHeight, {resizable=false, vsync=false})
    love.graphics.setBackgroundColor(1,1,1) --white

    --load font
    font = love.graphics.newFont("sansation.ttf",15)
    love.graphics.setFont(font)

    vMouse = {x=0, y=0}
    vClicked = {x=-1, y = -1}

    love.graphics.setPointSize(4)

    -- generate the voronoi diagram
    pointcount = 50
    genvoronoi = Voronoi:new(pointcount,3,0,0,gameWidth,gameHeight)

end

function love.mousemoved( x, y, dx, dy, istouch )
    vMouse.x = x
    vMouse.y = y
end

function love.mousepressed(x,y,button, istouch)
	if button == 1 then
        vClicked.x = x
        vClicked.y = y
	end
end

function love.update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.setColor(0,0,0)

    -- draw the voronoi diagram
    draw(genvoronoi)

    -- Draw Debug Info
    --draw UI
    love.graphics.setColor(1,0,0)
    love.graphics.print("Mouse: " .. vMouse.x .. "," .. vMouse.y, 500, 4)
    love.graphics.print("Clicked: " .. vClicked.x .. "," .. vClicked.y, 250,4)
end

-- called from love.draw
function draw(ivoronoi)

	-- draws the polygons
	for index,polygon in pairs(ivoronoi.polygons) do
		if #polygon.points >= 6 then
			love.graphics.setColor(50,50,50)
			love.graphics.polygon('fill',unpack(polygon.points))
			love.graphics.setColor(255,255,255)
			love.graphics.polygon('line',unpack(polygon.points))
		end
	end

	-- draws the segments
	love.graphics.setColor(150,0,100)
	for index,segment in pairs(ivoronoi.segments) do
		love.graphics.line(segment.startPoint.x,segment.startPoint.y,segment.endPoint.x,segment.endPoint.y)
	end

	-- draws the segment's vertices (corners)
	love.graphics.setColor(250,100,200)
	love.graphics.setPointSize(5)
	for index,vertex in pairs(ivoronoi.vertex) do
		love.graphics.points(vertex.x,vertex.y)
	end

	-- draw the points (seeds)
	love.graphics.setColor(0,0,0)
	love.graphics.setPointSize(7)
	for index,point in pairs(ivoronoi.points) do
		love.graphics.points(point.x,point.y)
		love.graphics.print(index,point.x,point.y)
	end

	-- draws the centroids
	love.graphics.setColor(255,255,0)
	love.graphics.setPointSize(5)
	for index,point in pairs(ivoronoi.centroids) do
		love.graphics.points(point.x,point.y)
		love.graphics.print(index,point.x,point.y)
	end

	-- draws the relationship lines
	love.graphics.setColor(0,255,0)
	for pointindex,relationgroups in pairs(ivoronoi.polygonmap) do
		for badindex,subpindex in pairs(relationgroups) do
			love.graphics.line(ivoronoi.centroids[pointindex].x,ivoronoi.centroids[pointindex].y,ivoronoi.centroids[subpindex].x,ivoronoi.centroids[subpindex].y)
		end
	end
end