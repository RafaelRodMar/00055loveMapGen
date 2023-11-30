-- Delaunay triangulation
local Delaunay = require 'Delaunay'
local Graph = require 'graph'

numberOfPoints = 10

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

function calculateCircumcentre(x1, y1, x2, y2, x3, y3)
    -- Calculate midpoints of sides
    local midx1 = (x1 + x2) / 2
    local midy1 = (y1 + y2) / 2
    local midx2 = (x2 + x3) / 2
    local midy2 = (y2 + y3) / 2
    local midx3 = (x3 + x1) / 2
    local midy3 = (y3 + y1) / 2

    -- Calculate slopes of sides
    local slope1 = (y2 - y1) / (x2 - x1)
    local slope2 = (y3 - y2) / (x3 - x2)
    local slope3 = (y1 - y3) / (x1 - x3)

    -- Calculate perpendicular slopes
    local perp_slope1 = -1 / slope1
    local perp_slope2 = -1 / slope2
    local perp_slope3 = -1 / slope3

    -- Calculate y-intercepts of perpendicular bisectors
    local y_intercept1 = midy1 - perp_slope1 * midx1
    local y_intercept2 = midy2 - perp_slope2 * midx2
    local y_intercept3 = midy3 - perp_slope3 * midx3

    -- Calculate circumcentre (intersection point of perpendicular bisectors)
    local circumcentre_x = (y_intercept3 - y_intercept1) / (perp_slope1 - perp_slope3)
    local circumcentre_y = perp_slope1 * circumcentre_x + y_intercept1

    return circumcentre_x, circumcentre_y
end

-- Example coordinates of triangle vertices
-- local x1, y1 = 0, 0
-- local x2, y2 = 4, 0
-- local x3, y3 = 2, 3

-- Calculate circumcentre
-- local circumcentre_x, circumcentre_y = calculateCircumcentre(x1, y1, x2, y2, x3, y3)

-- Output circumcentre coordinates
-- print("Circumcentre coordinates: (" .. circumcentre_x .. ", " .. circumcentre_y .. ")")


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
    voronoiCells = createVoronoiCells(points) -- Create Voronoi cells for current points configuration
    local numIterations = 2
    for i = 1, numIterations do
        -- Update points to centroids of their Voronoi cells
        for j, _ in ipairs(points) do
            local cell = voronoiCells[j]
            local centroid = calculateCentroid(cell.edges)
            points[j].x = centroid.x
            points[j].y = centroid.y
        end

        -- Update the voronoi diagram with the new points
        voronoiCells = createVoronoiCells(points)
    end

    -- Create a graph for Delaunay's results.
    local Point = Delaunay.Point

    -- Pass our random points to the Delaunay's library point format
    local delPoints = {}
    for i = 1, numberOfPoints do
        delPoints[i] = Point(points[i].x, points[i].y)
    end

    -- Generate the triangles.
    triangles = Delaunay.triangulate(unpack(delPoints))

    -- Printing the results
    -- for i, triangle in ipairs(triangles) do
    --     print(triangle)
    -- end

    -- Create a graph. The first graph has nodes for each polygon and edges between adjacent polygons.
    -- Use example:
    -- local Graph = require("graph") -- Replace "graph" with the actual file/module name

    -- -- Creating an empty graph
    -- local myGraph = Graph.new()

    -- -- Adding nodes
    -- myGraph:add_node("A")
    -- myGraph:add_node("B")
    -- myGraph:add_node("C")

    -- -- Adding edges between nodes
    -- myGraph:add_edge("A", "B")
    -- myGraph:add_edge("B", "C")
    -- myGraph:add_edge("C", "A")

    -- -- Setting weights
    -- myGraph:set_weight("A", "B", 5)
    -- myGraph:set_weight("B", "C", 3)
    -- myGraph:set_weight("C", "A", 2)

    -- to get the number of Nodes in the graph: 
    -- local numNodes = 0
    -- for _ in myGraph:nodes() do
    --     numNodes = numNodes + 1
    -- end

    -- print("Number of nodes:", numNodes)

    polygonGraph = Graph.new()
    -- each point determines a polygon, so:
    checkPointsTable = {} -- this table is for checking what point number is given its coordinates.
    for i = 1, #delPoints do
        polygonGraph:add_node(i)
        checkPointsTable[delPoints[i].x] = {}
        checkPointsTable[delPoints[i].x][delPoints[i].y] = i
    end

    -- now the triangles tell us the edges between polygons
    for i=1, #triangles do
        -- get the three points
        local p1, p2, p3 = triangles[i].p1, triangles[i].p2, triangles[i].p3
        -- identify the number of polygon
        local pol1 = checkPointsTable[p1.x][p1.y]
        local pol2 = checkPointsTable[p2.x][p2.y]
        local pol3 = checkPointsTable[p3.x][p3.y]
        if not polygonGraph:has_edge(pol1, pol2) then
            polygonGraph:add_edge(pol1, pol2)
        end
        if not polygonGraph:has_edge(pol2, pol1) then
            polygonGraph:add_edge(pol2, pol1)
        end
        if not polygonGraph:has_edge(pol1, pol3) then
            polygonGraph:add_edge(pol1, pol3)
        end
        if not polygonGraph:has_edge(pol3, pol1) then
            polygonGraph:add_edge(pol3, pol1)
        end
        if not polygonGraph:has_edge(pol2, pol3) then
            polygonGraph:add_edge(pol2, pol3)
        end
        if not polygonGraph:has_edge(pol3, pol2) then
            polygonGraph:add_edge(pol3, pol2)
        end
    end

    checkPointsTable = {} -- data not needed anymore

    -- to get the number of Nodes in the graph: 
    local numNodes = 0
    for _ in polygonGraph:nodes() do
        numNodes = numNodes + 1
    end

    print("Number of nodes:", numNodes)

    local numEdges = 0
    for _ in polygonGraph:edges() do
        numEdges = numEdges + 1
    end

    print("Number of edges:", numEdges)

    -- now let's create the second graph. The nodes of this graph are the corners of the voronoi diagram.
    -- The voronoi corners are the circumcentre of the triangles
    corners = {}
    for i=1, #triangles do
        local cornerCoords = {}
        cornerCoords.x, cornerCoords.y = calculateCircumcentre(triangles[i].p1.x, triangles[i].p1.y,triangles[i].p2.x, triangles[i].p2.y,triangles[i].p3.x, triangles[i].p3.y)
        -- check to what polygon this point belongs
        local closestPointIndex = 1
        local closestDistance = math.huge

        for i, point in ipairs(delPoints) do
            local distance = math.sqrt((cornerCoords.x - point.x)^2 + (cornerCoords.y - point.y)^2)

            if distance < closestDistance then
                closestDistance = distance
                closestPointIndex = i
            end
        end
        cornerCoords.polygon = closestPointIndex

        corners[i] = cornerCoords
    end

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
    local num = 1
    for _, point in ipairs(points) do
        love.graphics.points(point.x, point.y)  -- Draw seed points
        love.graphics.print(num, point.x, point.y)
        num = num + 1
    end

    -- draw Delaunay's triangulation triangles
    for _, tri in ipairs(triangles) do
        love.graphics.polygon("line", tri.p1.x, tri.p1.y, tri.p2.x, tri.p2.y, tri.p3.x, tri.p3.y)
    end

    -- draw voronoi corners
    love.graphics.setColor(1,1,1)
    for _, corner in ipairs(corners) do
        love.graphics.points(corner.x, corner.y)
        love.graphics.print(corner.polygon, corner.x, corner.y)
    end

    -- draw edges between voronoi corners
    -- love.graphics.setColor(0,0,1)
    -- for x=1, #corners - 1 do
    --     for y=x+1, #corners do
    --         if polygonGraph:has_edge(corners[x].polygon, corners[y].polygon) then
    --             love.graphics.line(corners[x].x, corners[x].y, corners[y].x, corners[y].y)
    --         end
    --     end
    -- end

    -- Draw Debug Info
    --draw UI
    love.graphics.setColor(1,0,0)
    love.graphics.print("Mouse: " .. vMouse.x .. "," .. vMouse.y, 500, 4)
    love.graphics.print("Clicked: " .. vClicked.x .. "," .. vClicked.y, 250,4)
end
