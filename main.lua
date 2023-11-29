local Delaunay = require 'Delaunay'

numberOfPoints = 200

-- gets the centroid of a list of edges
function calculateCentroid(edges)
    local centroid = { x = 0, y = 0 }

    for _, edge in ipairs(edges) do
        centroid.x = centroid.x + edge.x
        centroid.y = centroid.y + edge.y
    end

    centroid.x = centroid.x / #edges
    centroid.y = centroid.y / #edges

    return centroid
end

-- for every point in the screen get the closest reference point
function createVoronoiCells(points)
    local voronoiCells = {}

    for i = 1, #points do
        local cell = {}
        cell.x = points[i].x
        cell.y = points[i].y
        cell.edges = {}

        table.insert(voronoiCells, cell)
    end

    for y = 0, love.graphics.getHeight() do
        for x = 0, love.graphics.getWidth() do
            local closestPointIndex = 1
            local closestDistance = math.huge

            for i, point in ipairs(points) do
                local distance = math.sqrt((x - point.x)^2 + (y - point.y)^2)

                if distance < closestDistance then
                    closestDistance = distance
                    closestPointIndex = i
                end
            end

            local cell = voronoiCells[closestPointIndex]
            table.insert(cell.edges, { x = x, y = y })
        end
    end

    return voronoiCells
end

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

    points = {}  -- Table to store points

    -- Generate random points with x and y coordinates
    for i = 1, numberOfPoints do
        local x = love.math.random(0, love.graphics.getWidth())
        local y = love.math.random(0, love.graphics.getHeight())
        table.insert(points, { x = x, y = y })
    end

    -- create a table with random colors
    colors = {}

    for i = 1, numberOfPoints do
        local col = {}
        col.r = math.random()
        col.g = math.random()
        col.b = math.random()
        table.insert(colors, col)
    end

    -- Perform Lloyd's algorithm iterations.
    -- Lloyd's algorithm is a method used to find the 
    -- centroids of clusters in data by iteratively 
    -- adjusting their positions based on the data points 
    -- closest to them.
    voronoiCells = {}
    local numIterations = 2
    for i = 1, numIterations do
        -- Create Voronoi cells for current points configuration
        voronoiCells = createVoronoiCells(points)

        -- Update points to centroids of their Voronoi cells
        for j, _ in ipairs(points) do
            local cell = voronoiCells[j]
            local centroid = calculateCentroid(cell.edges)
            points[j].x = centroid.x
            points[j].y = centroid.y
        end
    end

    -- Create a graph for Delaunay's results.
    local Point = Delaunay.Point

    -- Pass our random points to the Delaunay's library point format
    local delPoints = {}
    for i = 1, numberOfPoints do
        delPoints[i] = Point(points[i].x, points[i].y)
    end

    -- Triangulating de convex polygon made by those points
    triangles = Delaunay.triangulate(unpack(delPoints))

    -- Printing the results
    -- for i, triangle in ipairs(triangles) do
    --     print(triangle)
    -- end

    love.graphics.setLineStyle( "smooth" )
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

    -- Draw Voronoi cells
    local colIndex = 1
    for _, cell in ipairs(voronoiCells) do
        love.graphics.setColor(colors[colIndex].r, colors[colIndex].g, colors[colIndex].b)  -- Random cell color
        
        -- Draw edges of each cell
        for _, edge in ipairs(cell.edges) do
            love.graphics.points(edge.x, edge.y)
        end

        colIndex = colIndex + 1
    end

    love.graphics.setColor(0,0,0)
    for _, point in ipairs(points) do
        love.graphics.points(point.x, point.y)  -- Draw points
    end

    for _, tri in ipairs(triangles) do
        love.graphics.polygon("line", tri.p1.x, tri.p1.y, tri.p2.x, tri.p2.y, tri.p3.x, tri.p3.y)
    end

    -- Draw Debug Info
    --draw UI
    love.graphics.setColor(1,0,0)
    love.graphics.print("Mouse: " .. vMouse.x .. "," .. vMouse.y, 500, 4)
    love.graphics.print("Clicked: " .. vClicked.x .. "," .. vClicked.y, 250,4)
end
