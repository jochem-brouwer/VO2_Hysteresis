local Lattice = require 'Lattice'
local MyLattice = Lattice:New();
local seed = os.time();

--1497362237-33
math.randomseed(1497362237-33)
MyLattice.ExternalField = 3.5;
MyLattice.Temperature = 1;

--math.randomseed(os.time())

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(5,5,1);
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


local t = 520;
local Time = linspace(0,t+1,t)

Field = linspace(0,21,20)

local Params = {
	Time = Time;
}

Model:Run(Params, 'Metropolis', {Sweeps = 3*3*1*10});

print(seed)

