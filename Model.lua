local Model = {};

local Plotter = require 'Plotter'

Model.Lattice = nil;

function Model:New()
	local obj = {};
	setmetatable(obj, {__index=self})
	return obj
end

-- Helper functions, get min/max val of a table.
local function mint(t)
	cmin = math.huge;
	for i,v in pairs(t) do 
		if v < cmin then 
			cmin = v 
		end 
	end 
	return cmin
end 

local function maxt(t)
	cmax = -math.huge 
	for i,v in pairs(t) do 
		if v > cmax then 
			cmax = v 
		end 
	end
	return cmax 
end 

-- 
function Model:Run(PList, SweepMode)
	local index = next(PList)
	local DataOut = {};


	if SweepMode == "Cycle" then 
		for i = 1, #PList[index] do 
			-- Set vars.
			for ParamName, Params in pairs(PList) do 
				self.Lattice[ParamName] = Params[i];

			end 
			local rep = true;
			while rep do 
				rep=false;
			-- Sweep over grain.
				for _, Grain in pairs(self.Lattice.Grains) do 
					--print(self.Lattice:GetDeltaU(Grain))
					if self.Lattice:GetDeltaU(Grain) < 0 then 
						self.Lattice:FlipSpin(Grain);
						rep=true;
					end 
				end
			end
--			self.Lattice:Show() 
			print(self.Lattice:GetM(), PList.ExternalField[i])
--			self.Lattice:Dump("tmp.lat")
		
			local Measure = self:Measure(self.Lattice);

			for ParamName, Data in pairs(PList) do 
				if not DataOut[ParamName]then 
					DataOut[ParamName] = {};
				end 
				local xValue = Data[i]; 

				for index, yValue in pairs(Measure) do 
					if not (DataOut[ParamName][index]) then 
						DataOut[ParamName][index] = {x = {}, y = {}};
					end 
					table.insert(DataOut[ParamName][index].x, xValue);
					table.insert(DataOut[ParamName][index].y, yValue);
				end 
			end 

		end 
--		self.Lattice:ToAnim("tmp.lat", "out.gif",4,5,1)

		-- Plot this data.

		for xLabel, Contents in pairs(DataOut) do 
			for yLabel, Data in pairs(Contents) do 
				local NewPlot = Plotter:New();
				NewPlot:Set("xlabel", xLabel) -- Create a new plot. 
				NewPlot:Set("ylabel", yLabel);
				local Data = Data;
				if yLabel == "M" and xLabel == "ExternalField" then 
					local new = {};
					new.x = {};
					new.y = {};
					local min_x = mint(Data.x);
					local max_x = maxt(Data.x);
					for ind, val in pairs(Data.x) do 
						table.insert(new.x, (val - min_x)/(max_x - min_x));
					end 
					local min_y = mint(Data.y);
					local max_y = maxt(Data.y);
					for ind, val in pairs(Data.y) do 
						table.insert(new.y, (val - min_y)/(max_y - min_y));
					end 

					NewPlot:SetData("xdata", new.x,true);
					NewPlot:SetData("ydata", new.y);
				else 
					NewPlot:SetData("xdata", Data.x,true);
					NewPlot:SetData("ydata", Data.y);
				end 
				NewPlot:SetData("title", yLabel .. " vs " .. xLabel)
				NewPlot:Plot(yLabel.."vs"..xLabel..".png")
			end 
		end 

	elseif SweepMode == "Metropolis" then  

	end


end 


return Model 