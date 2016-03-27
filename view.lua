-- Data format - subarrays - columns

local util = require "util"

-- Module responsible for rendering model to user
local view_module =
{
    draw = function(self, data)

        local stdout = io.stdout

        -- Delimiter
        stdout:write("\n")
        -- Header
        stdout:write("   ")
        for i = 0, util.dimension - 1 do
            stdout:write(" " .. i)
        end
        stdout:write("\n")

        stdout:write("   ")
        for i = 0, util.dimension - 1 do
            stdout:write("--")
        end
        stdout:write("\n")

        -- Data
        for row = 1, util.dimension do
            stdout:write(row - 1 .. " |")
            for column = 1, util.dimension do
                stdout:write(" " .. data[column][row])
            end
            stdout:write("\n")
        end

        -- Render
        stdout:flush()
    end
}

return view_module