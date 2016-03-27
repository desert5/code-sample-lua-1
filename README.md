# code-sample-lua-1
This is a simple match-3 game, implemented in LUA with command line interface. 
Player must move cells in order to create 3 or more cells of the same kind in a row or column.  
The game is started by executing **main.lua**.  
Tests are in test.lua and require to remove pretecting interface from model.  
  
Commands:  
q             - quit  
m (x) (y) (d) - move  
where:  
x - x coordinate of target cell  
y - y coordinate of target cell  
d - direction in which cell needs to be moved (possible values: l(left), r(right), u(up), d(down)  
