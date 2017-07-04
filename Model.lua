local Model = {};

local Plotter = require 'Plotter'

Model.Lattice = nil;

Model.k = 1; -- boltzmann

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
function Model:Run(PList, SweepMode, Options)
	if SweepMode == "SmartCycle" then 
		self.Lattice.ExternalField = -math.huge 
	end
	local index = next(PList)
	local DataOut = {};

	local ANIM = Options and Options.Anim;
	local SAVE = Options and Options.Save;
	local PLOT = Options and Options.Plot;

	local Mode 
	local TOGGLE = false;
	local iter = 0
	local ln = (index and #(PList[index] or {1})) or 1
	print(ln)
		for i = 1, ln do 
			-- Set vars.
			if SweepMode ~= "RFKMC" then 
				print(i/#PList[index])
			end
			if SweepMode ~= "SmartCycle" then 
				for ParamName, Params in pairs(PList) do 
					self.Lattice[ParamName] = Params[i];

				end
			end 
			if SweepMode == "Cycle" then 
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
			elseif SweepMode == "SmartCycle" then 
				-- ONLY USED TO SWEEP THE EXTERNAL FIELD!
				
				if Mode then 
					if Mode == "Up" then 
						Mode = "Down"
					else 
						Mode = "Up"
					end 
				end 
				Mode = Mode or "Up";
			--[[	if Mode == "Down" then 
					print(math.abs(self.Lattice.ExternalField - 2.2449268469436) < 10^(-6), 'extfield',iter)
					if math.abs(self.Lattice.ExternalField - 2.2449268469436) < 10^(-6) then 
					
						TOGGLE = true;
					end 
				end--]]



				local Thresh 
				local eps = 10^(-8) -- Variation in the field to flip a spin... (otherwise it will keep flipping)
				local found = true;
				while found do 
				found = false;
				local targetindex 
				if Mode == "Up" then 
					local bval = math.huge;
					
					for _, Grain in pairs(self.Lattice.Grains) do 
						if Grain.Spin == -1 then 
							local tval = self.Lattice:GetThreshField(Grain)/-1;
							if tval > self.Lattice.ExternalField and tval < bval then 
								bval = math.min(bval, tval)

								targetindex = Grain.Index;
								found = true;
							end
						end 
					end 
					Thresh = bval + eps;

					if Thresh > (PList.TurnPoints[i]) then 
						found=false;
					end 
				else 
					local bval = -math.huge;
					
					for _, Grain in pairs(self.Lattice.Grains) do 
						if Grain.Spin == 1 then 
							local tval = self.Lattice:GetThreshField(Grain)/1;
							if tval < self.Lattice.ExternalField and tval > bval then 
								bval = math.max(bval, tval)
								targetindex = Grain.Index;
								found = true;
							end
						end 
					end 
					Thresh = bval - eps;
					if Thresh < (PList.TurnPoints[i]) then 
						found=false;
					end 
				end 
			--	print(found)
				if found then 
					self.Lattice.ExternalField = Thresh;
				--[[if math.abs(self.Lattice.ExternalField - 2.2382797090124) < 10^(-2) and TOGGLE then 
						print("FOUND", self.Lattice.ExternalField, self.Lattice:GetM(),iter)
							self.Lattice:Dump("tmp.lat")
					end--]]
					local rep = true;
					iter=iter+1;
					while rep do 
						rep=false;
					-- Sweep over grain.
						for _, Grain in pairs(self.Lattice.Grains) do 
							--print(self.Lattice:GetDeltaU(Grain))
							if self.Lattice:GetDeltaU(Grain) < 0 then 
								--print('flip')
								if Mode == "Up" and Grain.Spin == 1 then 
									print("Backflip")
								elseif Mode == "Down" and Grain.Spin == -1 then 
									print("Backflip")
								end
								self.Lattice:FlipSpin(Grain);
								--[[if not rep then 
									print(Grain.Index, targetindex, Grain.Index==targetindex)
								end--]]

								rep=true;
							end 
						end
					end

					local Measure = self:Measure(self.Lattice);

					if ANIM or SAVE then 
						self.Lattice:Dump("tmp3.lat")
					end

					for ParamName, Data in pairs(PList) do 
						local xValue 
						if ParamName == "TurnPoints" then 
							ParamName = "ExternalField"
							xValue = self.Lattice.ExternalField;
						end
						if not DataOut[ParamName]then 
							DataOut[ParamName] = {};
						end 
						xValue = xValue or Data[i]; 

						for index, yValue in pairs(Measure) do 
							if not (DataOut[ParamName][index]) then 
								DataOut[ParamName][index] = {x = {}, y = {}};
							end 
							table.insert(DataOut[ParamName][index].x, xValue);
							table.insert(DataOut[ParamName][index].y, yValue);
						end 
					end
				else 
					-- go to next mval
				end 
				end	 




			elseif SweepMode == "Metropolis" then 
				local Sweeps = Options.Sweeps
				for Sweep = 1,Sweeps do 
					-- Pick a random grain; 
					local Grain = self.Lattice:GetRandomLatticeSite();
					local dU = self.Lattice:GetDeltaU(Grain);
			--		print(dU, dU/(self.k*self.Lattice.Temperature), math.exp(-dU/(self.k*self.Lattice.Temperature)))
					if dU <= 0 then 
						self.Lattice:FlipSpin(Grain) 
					elseif math.exp(-dU/(self.k*self.Lattice.Temperature)) > math.random() then 
						self.Lattice:FlipSpin(Grain)
					end 
				end
			elseif SweepMode == "HeatBath" then 
				local Sweeps = Options.Sweeps
				local Beta = 1/(self.k*self.Lattice.Temperature);
				for Sweep = 1,Sweeps do 
					-- Pick a random grain; 
					local Grain = self.Lattice:GetRandomLatticeSite();
					local dU = self.Lattice:GetDeltaU(Grain);
					local UOld = -dU/2;
					local UNew = UOld + dU;
					local exp_new = math.exp(-Beta*UNew)
					local Z = exp_new + math.exp(-Beta*UOld);
					flip_chance = exp_new/Z;
					local num = math.random();
					if num < flip_chance then 
						self.Lattice:FlipSpin(Grain);
					end
				end
			elseif SweepMode == "RFKMC" then -- Rejection free kinetic monte carlo.
				self.Lattice.Time = self.Lattice.Time or 0; -- Set time.
				local Thresh = Options.Thresh or 0;
				local n = 0;
				while true do 
					local MaxRate = 0;
					n = n + 1 
					if n > 10000 then
						return DataOut
					end
					print(n, self.Lattice:GetM())
					local Nk = {};
					local Tot = 0;
					local Beta = 1/(self.k*self.Lattice.Temperature);
					local found = false;
					local rep = true;
					while rep do 
						rep = false;
					for _, Grain in pairs(self.Lattice.Grains) do 
						local dU = self.Lattice:GetDeltaU(Grain);
						if dU < 0 then 
							local Rate =1;
							MaxRate = math.max(Rate, MaxRate)
							Tot = Tot + Rate;
							table.insert(Nk, {Tot, Grain});
							found = true;
						else 
							local Rate = math.exp(-Beta*dU);
							MaxRate = math.max(Rate, MaxRate)
							Tot = Tot + Rate;
							table.insert(Nk, {Tot, Grain});
							found = true;
						end 
					end 
					end
					if not found then -- no more candidate flips.
						break 
					end 
					if MaxRate < Thresh then 
						return DataOut
					end 
					local num = math.random() * Tot;
					-- Find the grain to flip;
					local toflip;
					local prev = 0;
					local prevg 
					local rate 

					for _, Data in pairs(Nk) do 
						if Data[1] > num and prev <= num then 
							toflip = Data[2]
							rate = Data[1] - prev
							break
						else 
							prev = Data[1];
							prevg = Data[2];
						end 
					end 
					local toflip = toflip or prevg;

					local dt = 1/Tot-- * math.log(1/math.random());
					--print(dt,Tot)
					self.Lattice.Time = self.Lattice.Time + dt;

					self.Lattice:FlipSpin(toflip)
					local Measure = self:Measure(self.Lattice);
					local PList = {Time = {self.Lattice.Time}}
					--print(self.Lattice.Time, MaxRate, Thresh)
					for ParamName, Data in pairs(PList) do 
						if not DataOut[ParamName]then 
							DataOut[ParamName] = {};
						end 
						local xValue = Data[1]; 

						for index, yValue in pairs(Measure) do 
							if not (DataOut[ParamName][index]) then 
								DataOut[ParamName][index] = {x = {}, y = {}};
							end 
							table.insert(DataOut[ParamName][index].x, xValue);
							table.insert(DataOut[ParamName][index].y, yValue);
						end 
					end
				end 
			end 
--			self.Lattice:Show() 
--			print(self.Lattice:GetM(), PList.ExternalField[i])
			if ANIM or SAVE and not SweepMode == "SmartCycle" then 
				self.Lattice:Dump("tmp.lat")
			end 
			if SweepMode ~= "RFKMC" and SweepMode ~= "SmartCycle" then 
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

		end 
		if ANIM then 
			self.Lattice:ToAnim("tmp.lat", "out.gif",4,5,1)
		end
		-- Plot this data.
		if PLOT then 
		for xLabel, Contents in pairs(DataOut) do 
			for yLabel, Data in pairs(Contents) do 
				local NewPlot = Plotter:New();
				NewPlot:Set("xlabel", "Normalized temperature") -- Create a new plot. 
				NewPlot:Set("ylabel", "Volume fraction metal");
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
		end 
		return DataOut;



end 


return Model 