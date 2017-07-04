local m = require'Matrix';

--[[
local SIZE = 100;
local TEST = {};
local RES = 3;
for i = 1, SIZE do 
	TEST[i] = {};
	for y = 1,SIZE do 
		if y==i then
			TEST[i][y] = (SIZE-1)*RES;
		else 
			TEST[i][y] = -RES;
		end 
	end
end 
--]]

local Matrix = {};

Matrix[1] = {3,-1,0,-1,-1,0,0,0};
Matrix[2] = {-1,3,-1,0,0,-1,0,0};
Matrix[3] = {0,-1,3,-1,0,0,-1,0};
Matrix[4] = {-1,0,-1,3,0,0,0,-1};
Matrix[5] = {-1,0,0,0,3,-1,0,-1};
Matrix[6] = {0,-1,0,0,-1,3,-1,0};
Matrix[7] = {0,0,-1,0,0,-1,3,-1};
Matrix[8] = {0,0,0,-1,-1,0,-1,3};



Rkl = m:Det(Matrix,{[1] = true, [7] = true});
Rl = m:Det(Matrix, {[1] = true});
print(Rkl,Rl)
print(Rkl/Rl)