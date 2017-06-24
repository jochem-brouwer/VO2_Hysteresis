local Lattice = require 'Lattice'
local MyLattice = Lattice:New();

--math.randomseed(os.time())

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(50,50,1);
--MyLattice:InitRandomField(8,0);

-- If you want to calculate resistances, also init the RN;

MyLattice:InitRN();

function Model:Measure(Lattice)
	-- Return a table where [ylabel] = measuredpoint.
	local Out = {};

	Out.M = Lattice:GetM();

	return Out;
end 






local function linspace(startn,num,endn)
	local step = (endn-startn) / (num-1);
	local out = {}

	for i = 1, num do 
		local val = startn + (i-1)*step 
		table.insert(out, val) 
	end 
	return out
end ;

local function tjoin(t1, t2)
	local out = {};
	for i,v in pairs(t1) do
		table.insert(out,v)
	end 
	for i,v in pairs(t2) do 
		table.insert(out,v)
	end 
	return out ;
end 


local Field = linspace(-3,550,2.5);
local Field2 = linspace(2.5,400,-1.5);
local Field3 = linspace(-1.5,450,3);
local Field4 = linspace(3,550,-2.5);
local Field5 = linspace(-2.5,400,1.5);
local Field6 = linspace(1.5,450,-3);

local Field = tjoin(Field,Field2);
local Field = tjoin(Field,Field3);
local Field = tjoin(Field,Field4);
local Field = tjoin(Field,Field5);
local Field = tjoin(Field,Field6);


local Params = {
	ExternalField = Field;
}

--Model:Run(Params, 'Cycle');
local g1 = MyLattice.Grid[1][1][1];
local g2 = MyLattice.Grid[50][50][1];
local x = os.clock()
print(MyLattice.RN:GetResistance(g1,g2))
print(os.clock()-x)

local Matrix = {{1,2,3,5},{1,-1,9,2}, {5,2,6,3}}

a = require 'Matrix'

--a:Solve(Matrix)

