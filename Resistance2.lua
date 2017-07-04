local Resistance = {};

-- Assume no exp dependence on the resistances;
-- IF resistances are NOT constants, then the algorithm should be modified; the Setup function should be used
-- for every case that the resistor network will be updated as the updating of the A/C matrix per spin change
-- is not very straightforward. This is MUCH slower though as we will need to loop over the entire grid.
-- We might want to create a new Setup function after the initial setup, as we already have the neighbours which
-- need to be taken into account.




Resistance.Conductances = {
	[-1] = 1;-- Semiconducting;
	[1] = 100;
}

-- Both;
local rr= Resistance.Conductances;
Resistance.Conductances[0] =rr[1] + rr[-1];

-- NOTE: Why are these parallel?
-- Because in parallel the voltage is the same over both resistors - this makes sense.


-- Calculate the resistance of a given network of resistors (actually a Lattice object)

local Matrix = require 'Matrix' 

function Resistance:New()
	return setmetatable({System={}, SolVec = {}, RLinker = {}; IndexList={Current=0}, EqList = {KCL={}, Ohm = {}, ResistanceEquation = {}}}, {__index=self})
end


function Resistance:GetGrainConductance(s1,s2)
	if s1 == s2 then 

		return (self.Conductances[s1])
	else 

		return (self.Conductances[0])
	end 
end 


function Resistance:Setup(Lattice)
	local Lattice = self.Lattice or Lattice;
	-- Setups the KCL / Ohm laws
	self.Lattice=Lattice;
	self.System = {};
	self.SolVec = {};
	self.RLinker = {};
	self.Sources = 0;
	self.NumGrains = #Lattice.Grains;
	self.IEq1 = {};
	self.IEq2 = {};
	local row = 0;
	for x=1,Lattice.x do 
		for y = 1,Lattice.y do 
			for z = 1,Lattice.z do 

				local Grain1 = Lattice.Grid[x][y][z];
				local Neighbours = Grain1.ResistanceNeighbours or Lattice:GetNeighbours(x,y,z,true);
				local make = false;
				if not Grain1.ResistanceNeighbours then 
					Grain1.ResistanceNeighbours = {};	
					make = true;
				end 

				local i1 = Grain1.Index
		
				self.System[i1] = {};

				--print(#Neighbours)

				local RSelfTot = 0;

				row = row + 1;
		

				for _, Neighbour in pairs(Neighbours) do 
				
				
					local Grain2 = (make and Lattice.Grid[Neighbour[1]][Neighbour[2]][Neighbour[3]]) or Neighbour
					if make then 
						table.insert(Grain1.ResistanceNeighbours, Grain2);		
					end 

					local i2 = Grain2.Index


					local sign = ((i1 > i2) and -1) or 1;

	

					local C = self:GetGrainConductance(Grain1.Spin,Grain2.Spin)

					if i1 < i2 then 
						self.System[i1][i2] = (self.System[i1][i2] or 0 )+C;
						self.System[i1][i1] = (self.System[i1][i1] or 0 ) - C
					else 
						self.System[i1][i2] = (self.System[i1][i2] or 0 )+C;
						self.System[i1][i1] = (self.System[i1][i1] or 0 ) - C

					end 
	

				--	RSelfTot = RSelfTot + sign*C;
			
				end
				--self.System[row][i1] = (self.System[row][i1] or 0 ) + RSelfTot;
			
				table.insert(self.SolVec, 0);
			end 
		end 
	end 
end  



function Resistance:AddSource(Grain, IsSource)
	local SourceEQ = #self.Lattice.Grains+1;
	local IExtcolumn = SourceEQ;
	local GroundEQ = #self.Lattice.Grains+2;
	self.SolVec[SourceEQ] = 0;
	self.SolVec[GroundEQ] = 0;

	--self.System[Grain.Index] = {};
	if not self.System[SourceEQ] then 
		self.System[SourceEQ] = {};
	end 
	if not self.System[GroundEQ] then 
		self.System[GroundEQ] = {};
	end



	local i1 = Grain.Index

	for _, Neighbour in pairs(Grain.ResistanceNeighbours) do 
		local Grain2 = Neighbour 


		local i2 = Grain2.Index

		local sign = ((i1 > i2) and -1) or 1;



		local C = self:GetGrainConductance(i1,i2)

		local target;
		if IsSource then 			
			target = self.System[SourceEQ] 
			
		else 
			target = self.System[GroundEQ]
		end 

		local C = self:GetGrainConductance(Grain.Spin,Grain2.Spin);
		target[i1] = (target[i1] or 0 ) + C;
		target[i2] = (target[i2] or 0 ) - C;
		if i1 < i2 then 
			target[i1] = (target[i1] or 0 ) + C;
			target[i2] = (target[i2] or 0 ) - C; 
		else 
			target[i1] = (target[i1] or 0 ) + C;
			target[i2] = (target[i2] or 0 ) - C; 
		end 
		target[IExtcolumn] = (IsSource and -1) or 1;
	end 

	local V = (IsSource and 1) or 0; 
	local eq = {};
	eq[Grain.Index] = 1;
	
	table.insert(self.System, eq);
	table.insert(self.SolVec, V);
end 

function Resistance:AddSource(Grain, IsSource)
	self.Sources = self.Sources + 1;


	local Target_Equation = self.System[Grain.Index];
	Target_Equation[self.NumGrains+self.Sources] = (IsSource and 1) or -1;


	local eq = {};
	eq[Grain.Index] = 1;
	table.insert(self.System, eq)
	table.insert(self.SolVec, (IsSource and 1) or 0)

	local targ = self.IEq1;

	targ[self.NumGrains+self.Sources] = (IsSource and 1) or -1;

	if IsSource then 
		self.IEq2[self.NumGrains+self.Sources] = 1;
	end 
end

function Resistance:MatrixSol()
	table.insert(self.System, self.IEq1)


	table.insert(self.SolVec, 0)
	self.IEq2[self.NumGrains+self.Sources+1] = -1;
	table.insert(self.System, self.IEq2)
	table.insert(self.SolVec, 0)

	local column = #self.Lattice.Grains+self.Sources+2; -- after the Iext column
	for i,v in pairs(self.SolVec) do 
		self.System[i][column] = v;
	end 

	--[[for i,v in pairs(self.System) do 
		for i = 1, column do 
			io.write(v[i] or 0)
			io.write(" ")
		end 
		io.write("\n")
	end --]]

	local V = 1;
	local IExt = Matrix:ToUpper_Matlab_LastSol(self.System);
	--print(IExt)
	return math.abs(V/IExt);
end 

function Resistance:GetResistance(Grain1,Grain2)
	self:Setup();
	self:AddSource(Grain1,true);
	self:AddSource(Grain2, false);
	-- library? ok sure
	--local IExt = Matrix:ToUpper_Matlab_LastSol(self.System)

	return self:MatrixSol();
end 

-- scans the left and right edges of the lattice.
function Resistance:GetEdgeResistance()
	self:Setup();
	local Lattice = self.Lattice;
	-- left edge = source
	local x,y,z = Lattice.x, Lattice.y, Lattice.z; 

	local row = self.Lattice.Grid[1];

	for yr = 1, y do 
		for zr = 1, z do 
			local Grain = row[yr][zr];
			self:AddSource(Grain,true);
		end 
	end 

	local row2 = self.Lattice.Grid[x];

	for yr = 1, y do 
		for zr = 1, z do 
			local Grain = row2[yr][zr];
			self:AddSource(Grain,false);
		end 
	end 


	return self:MatrixSol();

end 




return Resistance