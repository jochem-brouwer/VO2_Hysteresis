local Lattice = require 'Lattice'
local MyLattice = Lattice:New();

--math.randomseed(os.time())

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(100,100,1);
MyLattice:InitRandomField(10,0);

MyLattice.Temperature = 1;


-- If you want to calculate resistances, also init the RN;

MyLattice:InitRN();

-- Measure from one side to the other.
local INDEX_1 = MyLattice.Grid[math.floor(MyLattice.x/2)][1][1];
local INDEX_2 = MyLattice.Grid[math.floor(MyLattice.x/2)][MyLattice.y][1];

function Model:Measure(Lattice)
	-- Return a table where [ylabel] = measuredpoint.
	local Out = {};

	Out.M = Lattice:GetM();

	Out.Resistance = Lattice.RN:GetResistance(INDEX_1,INDEX_2);
--	Lattice.RN:DumpSystem()
	print(Out.Resistance, Out.M,Lattice.ExternalField)
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

--Field = {-1000,1000,-1000};



local Params = {
	ExternalField = Field;
}

Options = {
	Anim = false;
	Sweeps = MyLattice.x*MyLattice.y*MyLattice.z*100;
}

Model:Run(Params, 'Cycle', Options);



