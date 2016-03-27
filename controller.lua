local model = require "model"
local util = require "util"

local dirLookupTable

local controller_module =
{
    run = function(self)

        print("Game started")

        model:init()
        while model:tick() do
        end

        while self._gameInProgress do
            print("   ")
            print("Please input command:")

            local input = io.stdin:read();
            if (input == "q") then
                break
            else
                local parts = util:split(input)
                if (parts[1] == 'm') then
                    local x = tonumber(parts[2]) + 1
                    local y = tonumber(parts[3]) + 1
                    dirLookupTable[parts[4]](self, {x,y})
                end

                while model:tick() do
                end
            end
        end

        print("Game is over")
    end,
    moveRight = function(self, pos)
        if (pos[1] < util.dimension) then
            model:move(pos, { pos[1] + 1, pos[2] })
        end
    end,
    moveLeft = function(self, pos)
        if (pos[1] > 1) then
            model:move(pos, { pos[1] - 1, pos[2] })
        end
    end,
    moveUp = function(self, pos)
        if (pos[2] > 1) then
            model:move(pos, { pos[1], pos[2] - 1 })
        end
    end,
    moveDown = function(self, pos)
        if (pos[2] < util.dimension) then
            model:move(pos, { pos[1], pos[2] + 1 })
        end
    end,
    stopGame = function(self)
        self._gameInProgress = false
    end,

    _gameInProgress = true
}

-- Table sets correlation between text command and function
dirLookupTable =
{
    l = controller_module.moveLeft,
    r = controller_module.moveRight,
    u = controller_module.moveUp,
    d = controller_module.moveDown
}

return controller_module