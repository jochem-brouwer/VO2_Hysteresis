local Lattice = require 'Lattice'
local MyLattice = Lattice:New();
local seed = os.time();

--1497362237-33
math.randomseed(1239)
MyLattice.ExternalField = 0
MyLattice.Temperature = 1;

--math.randomseed(os.time())

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(100,100,1);


MyLattice.Temperature = 1.5;
--MyLattice:InitRandomField(8,0);

-- If you want to calculate resistances, also init the RN;

--MyLattice:InitRN();

function Model:Measure(Lattice)
	-- Return a table where [ylabel] = measuredpoint.
	local Out = {};

	Out.M = Lattice:GetM();
	print(Out.M)
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


local T = linspace(-1,100,1);
local T2 = linspace(1,100,-1);
local T = tjoin(T,T2);

local Params = {
	ExternalField = T;
}
local latvol = MyLattice.x*MyLattice.y*MyLattice.z;
local DataOut = Model:Run(Params, 'HeatBath', {Sweeps = MyLattice.x*MyLattice.y*MyLattice.z*100, Plot = false, Save = true});

local Plotter = require 'Plotter';


local M = DataOut.ExternalField.M.y;
for i,v in pairs(M) do 
	M[i] = M[i]/latvol;
end
local Temperature = DataOut.ExternalField.M.x;

local TempUp = {};
local TempDown = {};

MUp = {};
MDown = {};

local using = TempUp;
local using2 = MUp;
local old = -1000
for i,v in pairs(Temperature) do 
	if v < old then 
		using = TempDown
		using2 = MDown;
	else 
		old = v 
	end 
	table.insert(using, v);
	table.insert(using2, M[i])
end 



--[[local NewPlot = Plotter:New();
local Data = Data;
print(Temperature, 1) 
NewPlot:SetData("xdata", TempUp,true);
NewPlot:SetData("ydata", MUp);
NewPlot:SetData({pt=7, ps=3});
NewPlot:SetData("ptype" , 7)
NewPlot:SetData("psize", 1)
NewPlot:SetData("linewidth", 0)
NewPlot:SetData("title", "Increasing")

NewPlot:SetData("xdata", TempDown,true);
NewPlot:SetData("ydata", MDown);
NewPlot:SetData({pt=7, ps=3});
NewPlot:SetData("ptype" , 7)
NewPlot:SetData("psize", 1)
NewPlot:SetData("linewidth", 0)
NewPlot:SetData("title", "Decreasing")

NewPlot:SetData("__gptype", "func",true)
NewPlot:SetData(1, "(1-sinh(2/x)^(-4))^(1/8)")

NewPlot:SetData("__gptype", "func",true)
NewPlot:SetData(1, "-(1-sinh(2/x)^(-4))^(1/8)")

NewPlot:Set("xlabel", "Temperature") -- Create a new plot. 
NewPlot:Set("ylabel", "Magnetization (normalized)");

NewPlot:Set("key", "bmargin left horizontal Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid")

	
NewPlot:Set("title font", "\",20\"")

NewPlot:Set("title", "Magnetization as a function of temperature")
NewPlot:Plot("Metropolis_output_MvsT.png")--]]

local gp = require('lgnuplot')

local Tc = 2/math.log(1+math.sqrt(2))

local g = gp{    
	width  = 640,
    height = 480,
    xlabel = "Field strength",
    ylabel = "Magnetization (Normalized)",
    key    = "bmargin left horizontal Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid",
    terminal = "png";
    ["title  font"] = "\",20\"";
    title = "Magnetization as a function of field strength";

    data = {

       
    gp.array {  -- plot from an 'array-like' thing in memory. Could be a
                    -- numlua matrix, for example.
            {
              	TempUp,
              	MUp
            },
            
            title = "Increasing Field",          -- optional
            using = {1,2},              -- optional
    		ptype = 9;
    		psize = 1;
    		linewidth = 0;

   
        },
    gp.array {  -- plot from an 'array-like' thing in memory. Could be a
                    -- numlua matrix, for example.
            {
              	TempDown,
              	MDown
            },
            
            title = "Decreasing Field",          -- optional
            using = {1,2},              -- optional
    		ptype = 11;
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
}:plot('output2.png')
