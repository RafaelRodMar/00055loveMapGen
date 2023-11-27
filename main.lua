function love.load()
    --variables
    gameWidth = 640 + 383
    gameHeight = 480
    love.window.setMode(gameWidth, gameHeight, {resizable=false, vsync=false})
    love.graphics.setBackgroundColor(1,1,1) --white

    --load font
    font = love.graphics.newFont("sansation.ttf",15)
    love.graphics.setFont(font)

	-- Sprite that holds all imagery
    imagedata = love.image.newImageData('hexagon.png')
	hexagon = love.graphics.newImage(imagedata)
    textureWidth = imagedata:getWidth()
    textureHeight = imagedata:getHeight()
    hexMeasures = love.graphics.newImage('hexagonMeasures.png')

    vMouse = {x=0, y=0}
    vClicked = {x=-1, y = -1}
    vSect = {x=-1, y=-1}
    vSectPxl = {x=-1, y=-1}
    sectTyp = '0'
    r = textureWidth / 2
    s = 16 -- side size
    h = (textureHeight - s) / 2
end

function love.mousemoved( x, y, dx, dy, istouch )
    vMouse.x = x
    vMouse.y = y
end

function love.mousepressed(x,y,button, istouch)
	if button == 1 then
		vSect.x = math.floor(x / (2*r))
        vSect.y = math.floor(y / (h + s)) - 1

        vSectPxl.x = math.floor(x % (2 * r))
        vSectPxl.y = math.floor(y % (h + s)) - 1

        if vSect.y % 2 == 0 then sectTyp = 'A' else sectTyp = 'B' end

        local m = h / r   -- gradients of the edges
        local m2 = -h / r
        if sectTyp == 'A' then
            -- A-Sections consist of three areas.
            -- If the pixel position in question lies within the big bottom area the array coordinate of the tile is the same as the coordinate of our section.
            -- If the position lies within the top left edge we have to subtract one from the horizontal (x) and the vertical (y) component of our section coordinate.
            -- If the position lies within the top right edge we reduce only the vertical component.
            --middle
            vClicked.x = vSect.x
            vClicked.y = vSect.y
            --left edge
            if vSectPxl.y < (h + vSectPxl.x * m2) then
                vClicked.x = vSect.x - 1
                vClicked.y = vSect.y - 1
            end
            --right edge
            if vSectPxl.y < (-h + vSectPxl.x * m) then
                vClicked.x = vSect.x
                vClicked.y = vSect.y - 1
            end
        else
            -- B-Sections consist of three areas, too. But they are shaped differently!
            -- If the pixel position in question lies within the right area the array coordinate of the tile is the same as the coordinate of our section.
            -- If the position lies within the left area we have to subtract one from the horizontal (x) component of our section coordinate.
            -- If the position lies within the top area we have to subtract one from the vertical (y) component.
            --right side
            if vSectPxl.x >= r then
                if vSectPxl.y < (2 * h - vSectPxl.x * m) then
                    vClicked.x = vSect.x
                    vClicked.y = vSect.y - 1
                else
                    vClicked.x = vSect.x
                    vClicked.y = vSect.y
                end
            end
            --left side
            if vSectPxl.x < r then
                if vSectPxl.y < (vSectPxl.x * m) then
                    vClicked.x = vSect.x
                    vClicked.y = vSect.y - 1
                else
                    vClicked.x = vSect.x - 1
                    vClicked.y = vSect.y
                end
            end
        end
	end
end

function love.update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(1,1,1)
    love.graphics.setColor(1,1,1)

    -- measures of a hexagon
    love.graphics.draw(hexMeasures, 640, 0)

    -- draw the array of hexagons 20x15
    for y = 1, 15 do
        for x = 1, 20 do
            local pixelX

            if y % 2 == 0 then
                pixelX = x * 2 * r + r - 32
            else
                pixelX = x * 2 * r - 32
            end 

            local pixelY = y * (h + s)
            love.graphics.draw(hexagon, pixelX, pixelY)
        end
    end

    -- show selected hexagon
    if vClicked.x >= 0 and vClicked.y >= 0 and vClicked.x < 20 and vClicked.y < 15 then
        love.graphics.setColor(1,0,0)
        local sx = vClicked.x + 1
        local sy = vClicked.y + 1
        local pixelX

        if sy % 2 == 0 then
            pixelX = sx * 2 * r + r - 32
        else
            pixelX = sx * 2 * r - 32
        end 

        local pixelY = sy * (h + s)
        love.graphics.draw(hexagon, pixelX, pixelY)
        love.graphics.setColor(1,1,1)
    end


    -- Draw Debug Info
    --draw UI
    love.graphics.setColor(1,0,0)
    love.graphics.print("Mouse: " .. vMouse.x .. "," .. vMouse.y, 500, 4)
    love.graphics.print("Clicked: " .. vClicked.x .. "," .. vClicked.y, 250,4)
    love.graphics.print("Sect: " .. vSect.x .. "," .. vSect.y, 100, 4)
    if sectTyp ~= nil then love.graphics.print(sectTyp, 90,4) end
    love.graphics.print("Hexagon size = " .. textureWidth .. "x" .. textureHeight, 660, 350)
    love.graphics.print("s = 16", 660, 370)
    love.graphics.print("r = width / 2 = " .. r, 660, 390)
    love.graphics.print("h = (textureHeight - s) / 2 = " .. h, 660, 410)
end
