local Lattice = require 'Lattice'
local MyLattice = Lattice:New();

math.randomseed(12832);

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(100,100,1);
MyLattice:InitRandomField(8,0);
MyLattice.J = 2;
MyLattice.Temperature = 1;
-- If you want to calculate resistances, also init the RN;

 MyLattice:InitRN();

local vol = MyLattice.x * MyLattice.y * MyLattice.z

local MVals = {}
local TVals = {};

function Model:Measure(Lattice)
	-- Return a table where [ylabel] = measuredpoint.
	local Out = {};

	Out.M = (Lattice:GetM()/vol + 1)/2;
    --Out.Time = Lattice.Time;
    -- UPDATE the resistances;
    Lattice.RN.Conductances[-1] = 0.1*math.exp(Lattice.ExternalField/10); -- NO minus sign! We are using conductances
    Lattice.RN.Conductances[0] = Lattice.RN.Conductances[1] + Lattice.RN.Conductances[-1];
   -- Out.R = Lattice.RN:GetEdgeResistance();

--    print("M = " .. Out.M .. " R = " .. Out.R)
  --  print(Out.M)
    table.insert(MVals,Out.M);
    table.insert(TVals, Lattice.Time)
   -- table.insert(RVals, Out.R);

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

local mul = 1

--[[local Field = linspace(-3*mul,450/2,1.5*mul);
local Field2 = linspace(1.5*mul,200/2,-0.5*mul);
local Field3 = linspace(-0.5*mul,350/2,3*mul);
local Field4 = linspace(3*mul,450/2,-1.5*mul);
local Field5 = linspace(-1.5*mul,200/2,0.5*mul);
local Field6 = linspace(0.5*mul,350/2,-3*mul);

local Field = tjoin(Field,Field2);
local Field = tjoin(Field,Field3);
local Field = tjoin(Field,Field4);
local Field = tjoin(Field,Field5);
local Field = tjoin(Field,Field6);--]]

local Field = linspace(-3.5, 600,2.5);
local Field2 = linspace(2.5,300,-1.5)
local Field3 = linspace(-1.5,500,3.5);
local Field4 = linspace(3.5,1000,-2.5)
local Field5 = linspace(-2.5,400,1.5);
local Field6 = linspace(1.5,500,-3.5)

local Field = tjoin(Field,Field2);
local Field = tjoin(Field,Field3);
local Field = tjoin(Field,Field4);
local Field = tjoin(Field, Field5);
local Field = tjoin(Field, Field6);

local Params = {
	ExternalField = {2.5};
}

-- Bring to init.
DataOut = Model:Run(Params, 'Cycle',{Sweeps = MyLattice.x*MyLattice.y*MyLattice.z*1000, Plot = false, Save = true,});

DataOut = Model:Run({}, "RFKMC", {Thresh = 0.66});

local Plotter = require 'Plotter';

local gp = require'lgnuplot'

local M = MVals;

local Time = TVals;




local g = gp{    
	width  = 640,
    height = 480,
    --logscale = "y",
    xlabel = "Time (arb. units)",
    ylabel = "Volume fraction metal",
    key    = "bmargin left horizontal Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid",
    terminal = "png";
    ["title  font"] = "\",18\"";
    title = "Volume fraction metal as a function of time";

    data = {
           	
       
    gp.array {  -- plot from an 'array-like' thing in memory. Could be a
                    -- numlua matrix, for example.
            {
              	Time,
              	M
            },
            
           -- title = "Increasing field",          -- optional
            using = {1,2},              -- optional
    		ptype = 9;
    		psize = 1;
    		linewidth = 0;

   
        },

        
 --[[       gp.func {   -- plot from a Lua function
            function(x)                 -- function to plot
                return 3* math.sin(2*x) + 4
            end,
            
            range = {-2, 10, 0.01},     -- optional
            width = 3,                  -- optional
            title = '3sin(2x) + 4',     -- optional
            with  = 'lines',
        },
        
        gp.gpfunc { -- plot from a native gnuplot function
            "gamma*sin(1.8*x) + 3",
            width = 2,
            title = 'gamma sin(1.8x) + 3',
        },--]]
        

    }    
}:plot('output.png')



