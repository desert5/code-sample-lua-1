local model = require "model"
local controller = require "controller"
local util = require "util"

--
-- Remove model protection interface in order to use tests
--
function functionalTest()
    controller:run()
end

function initialization()
    model:init(1234)
    model:dump()
    assert(#model._field == util.dimension and
            model._field[5][1] and model._field[5][1] ~= ' ', "Compression does not work")
end

function tickTest()
    model:init(1234)
    model:dump()
    model:tick()
    model:tick()
    model:tick()
    model:tick()
end

function compression()
    local compressed = model:_compress({'B','A','K','A',' ','A','K',' ','B','A'})
    util.print_r(compressed)
    assert(compressed[1] == ' ' and compressed[2] == ' ', "Compression does not work")
end

function movesAvailability()
    model:init(1234);
    model:dump()
    assert(model:_areMovesAvailableInTable(), "Move are not available in newly created table")
end