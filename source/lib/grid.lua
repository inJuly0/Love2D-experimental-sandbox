-- Fixed resolution grid for now. 
-- TODO: test against a quadtree later
local Collider = require('components/collider')
local GameConstants = require('gameconstants')

local Grid = {}
-- local DEFAULT_ROW_COUNT, DEFAULT_COL_COUNT = 10, 10

function Grid:new(rows, cols, _world)
    local grid = {}
    self.__index = self
    grid.world = _world -- world which the grid belongs too
    grid.rows, grid.cols = rows, cols
    grid.cellWidth = GameConstants.SCREEN_WIDTH / grid.cols
    grid.cellHeight = GameConstants.SCREEN_HEIGHT / grid.rows
    grid.cells = {}
    for i = 1, grid.rows do
        grid.cells[i] = {}
        for j = 1, grid.cols do grid.cells[i][j] = {} end
    end
    setmetatable(grid, self)
    return grid
end

local _insert_shape = {
    ['rect'] = function(body, grid)
        local collider = body.collider
        local pos = body.collider.pos
        --[[ finding the row and column of the min and max cell locations.
        An entity can span multiple grid cells, so I need to find out :
        -> the row and column where the TOP LEFT corner of the entity ends up 
        -> the last column that the entity takes up
        -> the last row that the entity takes up
    --]]

        local col = math.floor(pos.x / grid.cellWidth) + 1
        local row = math.floor(pos.y / grid.cellHeight) + 1
        local maxCol = math.floor((pos.x + collider.width) / grid.cellWidth) + 1
        local maxRow =
            (math.floor((pos.y + collider.height) / grid.cellHeight) + 1)

        for i = row, maxRow do
            if grid.cells[i] then
                for j = col, maxCol do
                    if grid.cells[i][j] then
                        table.insert(grid.cells[i][j], body)
                    end
                end
            end
        end
        -- There is probably a more efficient solution out there 
        -- than doing this if check every time I insert
        -- but I'll look for micro optimizations later
        -- (Note: later = never)
    end
}

function Grid:insert(body) _insert_shape[body.collider.shape](body, self) end

function Grid:draw()
    love.graphics.setColor(1, 0.3, 0.3, 0.4)
    for i = 1, self.rows do
        love.graphics.line(0, i * self.cellHeight, GameConstants.SCREEN_WIDTH,
                           i * self.cellHeight)
    end
    for i = 1, self.cols do
        love.graphics.line(i * self.cellWidth, 0, i * self.cellWidth,
                           GameConstants.SCREEN_HEIGHT)
    end
    love.graphics.setColor(1, 0.3, 0.3, 1)
    for i = 1, self.rows do
        for j = 1, self.cols do
            love.graphics.print(#self.cells[i][j], j * self.cellWidth - 300,
                                i * self.cellHeight - 30)
        end
    end
end

function Grid:clear()
    for i = 1, self.rows do
        self.cells[i] = {}
        for j = 1, self.cols do self.cells[i][j] = {} end
    end
end

function updateCell(cell)
    for i = 1, #cell do
        cell[i].collider.pos = cell[i].collider.pos + cell[i].collider.vel
    end
end

function Grid:update(dt)
    for i = 1, self.rows do
        for j = 1, self.cols do updateCell(self.cells[i][j]) end
    end
end

function Grid:query(x, y, width, height)
    -- TODO
end

return Grid
