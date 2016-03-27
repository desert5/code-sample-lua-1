--
-- Created by IntelliJ IDEA.
-- User: Desert
-- Date: 21.03.2016
-- Time: 21:24
-- To change this template use File | Settings | File Templates.
--
util =
{
    print_r = function(t)
        local print_r_cache = {}
        local function sub_print_r(t, indent)
            if (print_r_cache[tostring(t)]) then
                print(indent .. "*" .. tostring(t))
            else
                print_r_cache[tostring(t)] = true
                if (type(t) == "table") then
                    for pos, val in pairs(t) do
                        if (type(val) == "table") then
                            print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                            sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                            print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                        elseif (type(val) == "string") then
                            print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                        else
                            print(indent .. "[" .. pos .. "] => " .. tostring(val))
                        end
                    end
                else
                    print(indent .. tostring(t))
                end
            end
        end

        if (type(t) == "table") then
            print(tostring(t) .. " {")
            sub_print_r(t, "  ")
            print("}")
        else
            sub_print_r(t, "  ")
        end
        print()
    end,

    split = function(self, inputString)
        local stringList = {}
        for i in string.gmatch(inputString, "%S+") do
            stringList[#stringList + 1] = i
        end
        return stringList
    end,

    -- Settings
    dimension = 10
}

return util