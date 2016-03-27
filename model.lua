-- Data model format:
-- subarrays represent columns

local view = require "view"
local util = require "util"

local EMPTY_CELL = ' '

local model_module =
{
    -- Initialize model
    init = function(self, seed)

        -- Initialize random gen
        if (seed == nil) then
            seed = os.time()
        end

        math.randomseed(seed)

        local crystall_types = { 'A', 'B', 'C', 'D', 'E', 'F' }

        for i = 1, util.dimension do
            self._field[i] = {}
            for j = 1, util.dimension do
                self._field[i][j] = crystall_types[math.random(6)]
            end
        end
    end,

    -- Update function returns true if there were changes in model, false if not
    tick = function(self)

        -- Search for same crystall sequences
        local match = self:_findSequences()

        -- Process found matches
        if (#match > 0) then

            -- Destroy
            self:_destroy(match)

            -- Reorder
            for i = 1, #self._field do
                self._field[i] = self:_compress(self._field[i])
            end

            -- Check move availability
            local available = self:_areMovesAvailableInTable()

            -- If move are not available - mix
            if (not available) then
                self:mix()
            end

            -- Redraw view
            view:draw(self._field)
            return true
        else
            return false
        end
    end,

    -- Swap cell contents
    -- Returns true when move was successful, false when was not
    move = function(self, from, to)
        if (self:_canMove(from,to))
        then
            self:_swap(from, to)
            local checkResult = self:_check(to)
            if (#checkResult < 3) then
                -- Can not form and match after this move - move is forbidden
                -- Rollback movement
                self:_swap(from, to)
                return false
            end

            -- Handle changes
            self:tick()
            return true
        else
            -- Invalid action
            return false
        end
    end,

    -- Mix cells so it would be possible to form
    -- matches with at least 1 move
    mix = function(self)

        -- Extract data
        local data = {}
        for _, column in ipairs(self._field) do
            for _, cell in ipairs(column) do
                if (cell ~= EMPTY_CELL) then
                    table.insert(data, cell)
                end
            end
        end

        for i = 1, 10 do
            local newTable = {}

            -- Fill new table
            for i = 1, util.dimension do
                newTable[i] = {}
            end

            math.randomseed(os.time() + i)

            -- Fill columns with data
            while #data > 0 do
                local crystall = table.remove(data)
                local columNumber = math.random(util.dimension)

                if (#newTable[columNumber] < util.dimension) then
                    table.insert(newTable[columNumber], crystall)
                else
                    -- Back to array, column is full
                    table.insert(data, crystall)
                end
            end

            -- Pad columns with empty cells
            for _, column in ipairs(newTable) do
                while #column < util.dimension do
                    table.insert(column, 1, EMPTY_CELL)
                end
            end

            local match = self:_findSequences()

            -- If successfully mixed
            if (#match == 0 and self:_areMovesAvailableInTable()) then
                return
            end
        end

        -- Is mixing failed 10 times - quit
        error("Can not mix")
    end,

    -- Trigger view redraw
    dump = function(self)
        view:draw(self._field)
    end,

    -- Private members

    -- Check if move can be executed
    _canMove = function(self, from, to)
        return  (to[1] > 0) and (to[1] <= util.dimension) and       -- can not move outside of bounds
                (to[2] > 0) and (to[2] <= util.dimension) and
                (self._field[from[1]][from[2]] ~= EMPTY_CELL) and   -- can not move empty cells
                (self._field[to[1]][to[2]] ~= EMPTY_CELL)           -- can not swap pos with empty cell
    end,

    -- Search for same crystall sequences
    _findSequences = function(self)
        local match
        for columnIndex, column in ipairs(self._field) do
            for cellIndex, cell in ipairs(column) do
                if (cell ~= EMPTY_CELL) then
                    match = self:_check({ columnIndex, cellIndex })
                    if (match ~= nil) and (#match > 0) then
                        break
                    end
                end
            end
            if (match ~= nil) and (#match > 0) then
                break
            end
        end
        if (match ~= nil) and (#match > 2) then
            return match
        else
            return {}
        end
    end,

    -- Function finds 3 matching crystalls in a row or column
    _check = function(self, pos)

        local pointer
        local target = self._field[pos[1]][pos[2]]

        -- Return if operation if performed on empty cell
        -- because one can not stack empty cells
        if (target == EMPTY_CELL) then
            return {}
        end

        -- Horizontal check
        local stack = {}
        stack[#stack + 1] = pos

        -- Check left
        pointer = pos[1] - 1
        while (pointer >= 1) and (self._field[pointer][pos[2]] == target) do
            stack[#stack + 1] = { pointer, pos[2] }
            pointer = pointer - 1
        end

        --Check right
        pointer = pos[1] + 1
        while (pointer <= util.dimension) and (self._field[pointer][pos[2]] == target) do
            stack[#stack + 1] = { pointer, pos[2] }
            pointer = pointer + 1
        end

        -- Return matching cells (if 3 or more)
        if (#stack > 2) then
            return stack
        end

        -- Vertical check
        stack = {}
        stack[#stack + 1] = pos

        -- Check up
        pointer = pos[2] - 1
        while (pointer >= 1) and (self._field[pos[1]][pointer] == target) do
            stack[#stack + 1] = { pos[1], pointer }
            pointer = pointer - 1
        end

        --Check down
        pointer = pos[2] + 1
        while (pointer <= util.dimension) and (self._field[pos[1]][pointer] == target) do
            stack[#stack + 1] = { pos[1], pointer }
            pointer = pointer + 1
        end

        -- Return matching cells
        if (#stack > 2) then
            return stack
        else
            return {}
        end
    end,

    -- Simply swaps crystalls in supplied positions
    _swap = function(self, from, to)
        local temp = self._field[to[1]][to[2]]
        self._field[to[1]][to[2]] = self._field[from[1]][from[2]]
        self._field[from[1]][from[2]] = temp
    end,

    -- Destroy supplied cells
    _destroy = function(self, cells)
        for _, pos in ipairs(cells) do
            self._field[pos[1]][pos[2]] = EMPTY_CELL
        end
    end,

    -- Reorder cells so it would look like upper cells fall down
    _compress = function(self, column)
        local compressed = {}
        local pointer = util.dimension

        for i = util.dimension, 1, -1 do
            if (column[i] ~= EMPTY_CELL) then
                compressed[pointer] = column[i]
                pointer = pointer - 1
            end
        end

        for i = 1, util.dimension do
            if (compressed[i] == nil) then
                compressed[i] = EMPTY_CELL
            end
        end

        return compressed
    end,

    -- Check if moves are available in whole table
    _areMovesAvailableInTable = function(self)
        local available
        for columnIndex, column in ipairs(self._field) do
            for cellIndex, cell in ipairs(column) do
                if (cell ~= EMPTY_CELL) then
                    available = self:_areMovesAvailable({ columnIndex, cellIndex })
                    if (available) then
                        break
                    end
                end
            end
            if ((available ~= nil) and available) then
                break
            end
        end
        return available
    end,

    -- Check if move available for a particular point
    _areMovesAvailable = function(self, pos)
        return  self:_checkMove(pos, { pos[1] + 1, pos[2] }) or
                self:_checkMove(pos, { pos[1] - 1, pos[2] }) or
                self:_checkMove(pos, { pos[1], pos[2] + 1 }) or
                self:_checkMove(pos, { pos[1], pos[2] - 1 })
    end,

    -- Checks move for one direction (also this method does not trigger tick)
    _checkMove = function(self, oldPos, newPos)
        if (self:_canMove(oldPos, newPos))
        then
            self:_swap(oldPos,newPos)
            local checkResult = self:_check(newPos)

            -- Restore pos
            self:_swap(newPos, oldPos)
            if (#checkResult > 2) then
                return true
            end
        end
        return false
    end,

    -- Field model
    _field = {}
}

-- Interface to prevent access to private data from outside of module
local model_module_interface =
{
    init = function(self, seed)
        return model_module:init(seed)
    end,
    tick = function(self)
        return model_module:tick()
    end,
    move = function(self, from, to)
        return model_module:move(from, to)
    end,
    mix = function(self)
        return model_module:mix()
    end,
    dump = function(self)
        return model_module:dump()
    end
}


return model_module_interface