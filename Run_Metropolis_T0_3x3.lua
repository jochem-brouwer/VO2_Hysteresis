local Lattice = require 'Lattice'
local MyLattice = Lattice:New();

MyLattice.ExternalField = 0

--math.randomseed(os.time())

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(3,3,1);
--MyLattice:InitRandomField(8,0);

-- If you want to calculate resistances, also init the RN;

--MyLattice:InitRN();

function Model:Measure(Lattice)
	-- Return a table where [ylabel] = measuredpoint.
	local Out = {};

	Out.E = Lattice:U();
	print(Out.E)
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


local t = 1000;
local Time = linspace(0,t+1,t)

Field = linspace(0,21,20)

local Params = {
	ExternalField = Field;
}

Model:Run(Params, 'Metropolis', {Sweeps = 3*3*1*10});



