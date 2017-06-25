local Resistance = {};

-- Assume no exp dependence on the resistances;
-- IF resistances are NOT constants, then the algorithm should be modified; the Setup function should be used
-- for every case that the resistor network will be updated as the updating of the A/C matrix per spin change
-- is not very straightforward. This is MUCH slower though as we will need to loop over the entire grid.
-- We might want to create a new Setup function after the initial setup, as we already have the neighbours which
-- need to be taken into account.


Resistance.Resistances = {
	[-1] = 10^5;-- Semiconducting;
	[1] = 10^2;
}


Resistance.Resistances = {
	[-1] = 100;-- Semiconducting;
	[1] = 1;
}

-- Both;
local rr= Resistance.Resistances;
Resistance.Resistances[0] = 1/(1/rr[1]+1/rr[-1]);

-- NOTE: Why are these parallel?
-- Because in parallel the voltage is the same over both resistors - this makes sense.


-- Calculate the resistance of a given network of resistors (actually a Lattice object)

local Matrix = require 'Matrix' 



function Resistance:New()
	return setmetatable({A={}, C={}}, {__index=self})
end  

function Resistance:GetC(s1,s2)
	if s1 == s2 then 
		return 1/(self.Resistances[s1])
	else 
		return 1/(self.Resistances[0])
	end 
end 


-- Todo: Add an update mode wether or not we update C/A matrices
-- This is to make it easier to add new methods like resistances which scale with temperature
-- Or to implement something else like 
function Resistance:Update(Grain)
	-- Grain is flipped. Update neighbours.
	local Lattice=self.Lattice;
	local iSelf = Grain.Index;

	local A = self.A;

	for i,Grain2 in pairs(Grain.ResistanceNeighbours) do 
		local iGrain = Grain2.Index;
		local C = self:GetC(Grain.Spin,Grain2.Spin)

--		C[iSelf][iGrain] = C;
--		C[iGrain][iSelf] = C;

		local C_OLD = -(A[iSelf][iGrain]);
		local Delta = C - C_OLD;

		A[iSelf][iGrain] = -C; 
		A[iGrain][iSelf] = -C;

		A[iSelf][iSelf] = A[iSelf][iSelf] + Delta; 
		A[iGrain][iGrain] = A[iGrain][iGrain] + Delta;
	end 

end 

function Resistance:Setup(Lattice)
	self.Lattice = Lattice;
	--[[if not Lattice.IndexFromGrain then 
		Lattice.IndexFromGrain = {};
		for i,v in pairs(Lattice.Grains) do 
			Lattice.IndexFromGrain[v] = i;
		end
	end --]]
	local num_resistors = 0;
	local max_i = 0;
	for x=1,Lattice.x do 
		for y=1,Lattice.y do
			for z=1,Lattice.z do 
				-- NONPERIODIC
				local Neighbours = Lattice:GetNeighbours(x,y,z,true);
				local Grain1 = Lattice.Grid[x][y][z];
				Grain1.ResistanceNeighbours = {};

				local i1 = Grain1.Index

				for _, Neighbour in pairs(Neighbours) do 
					local Grain2 = Lattice.Grid[Neighbour[1]][Neighbour[2]][Neighbour[3]]	
					table.insert(Grain1.ResistanceNeighbours, Grain2);		
					local i2 = Grain2.Index

					local C = self:GetC(Grain1.Spin,Grain2.Spin);
					if not self.C[i1] then self.C[i1] = {} end;
					if not self.C[i2] then self.C[i2] = {} end;
					self.C[i1][i2] = C;
					self.C[i2][i1] = C;
					max_i = math.max(max_i, i1,i2)
				end
				num_resistors = num_resistors + #Grain1.ResistanceNeighbours;
			end 
		end 
	end 

	-- Make A
	local C = self.C;
	local A = self.A; 
	for i = 1, max_i do 
		for j = 1, max_i do 
			local Cij = C[i][j];
			if not A[i] then 
				A[i] = {};
			end 
			if i ~= j then 
				if Cij then 
					A[i][j] = -Cij
				end
			else 
				local sum = 0;
				for k = 1, max_i do 
					sum = sum + (C[i][k] or 0)
				end 
				A[i][j] = sum;
		
			end 
		end 
	end 

	num_resistors = num_resistors/2;

end 

-- Per det formula
function Resistance:GetResistance(Grain1_Index,Grain2_Index)
	local Out1 = Matrix:Det(self.A, {[Grain1_Index]=true; [Grain2_Index]=true});
	local Out2 = Matrix:Det(self.A, {[Grain1_Index]=true});
--	print(Out1,Out2)
	return Out1/Out2;
end 



-- NEW VERSION HERE

function Resistance:New()
	return setmetatable({System={}, IndexList={Current=0}, EqList = {KCL={}, Ohm = {}, ResistanceEquation = {}}}, {__index=self})
end  

function Resistance:GetGrainResistance(s1,s2)
	if s1 == s2 then 

		return (self.Resistances[s1])
	else 

		return (self.Resistances[0])
	end 
end 




function Resistance:Setup(Lattice)
	self.Lattice=Lattice;
	local function getcolumn(vname)
		local t = self.IndexList;
		r = t[vname];
		if r then 
			return r 
		else 
			t[vname] = t.Current + 1;
			t.Current = t.Current + 1;
			return t.Current;
		end 
	end 
	-- Let's start by writing down the KCL;
	local row = 1
	local colmax = 0;
	for x=1,Lattice.x do 
		for y=1,Lattice.y do
			for z=1,Lattice.z do 
				local Grain1 = Lattice.Grid[x][y][z];
				local Neighbours = Lattice:GetNeighbours(x,y,z,true);
				Grain1.ResistanceNeighbours = {};

				self.System[row] = {};

				local i1 = Grain1.Index

				--print(#Neighbours)

				for _, Neighbour in pairs(Neighbours) do 
					local Grain2 = Lattice.Grid[Neighbour[1]][Neighbour[2]][Neighbour[3]]	
					table.insert(Grain1.ResistanceNeighbours, Grain2);		
					local i2 = Grain2.Index

					--local C = self:GetC(Grain1.Spin,Grain2.Spin);
					local varname = "I"..math.min(i1,i2) .. "_"..math.max(i1,i2);
					local column = getcolumn(varname);
					colmax = math.max(column, colmax);

					local sign = ((i1 > i2) and -1) or 1;

					self.System[row][column] = sign;


				end

				self.EqList.KCL[i1] = row;
				row = row + 1;
			end 
		end 
	end 

	for _, Grain1 in pairs(Lattice.Grains) do 
		local i1 = Grain1.Index; 
		for _, Grain2 in pairs(Grain1.ResistanceNeighbours) do 
			
			local i2 = Grain2.Index; 

			if i2 > i1 then 
				self.System[row] = {}
				local var1 = getcolumn("V"..i1);
				local var2 = getcolumn("V"..i2);

				local sign1 = ((i1 > i2) and -1) or 1;
				local sign2 = -sign1;

				self.System[row][var1] = sign1;
				self.System[row][var2] = sign2;

				local varname = "I"..math.min(i1,i2) .. "_"..math.max(i1,i2);
				local R = self:GetGrainResistance(Grain1.Spin, Grain2.Spin);

				colmax = math.max(var1, colmax);
				colmax = math.max(var2, colmax);


				self.System[row][getcolumn(varname)] = -R;

				self.EqList.ResistanceEquation[varname] = row;
				row = row + 1;
			end

		end 
		self.EqList.Ohm[i1] = row;

	end 

	-- Add the solutions to these equations!

	for row in pairs(self.System) do 
		self.System[row][colmax+2] = nil;
	end 

	self.Colmax = colmax;
	

end 

function Resistance:GetResistance(Grain1, Grain2)
	-- Add the Iext to the KCL ;


	local i1 = Grain1.Index;
	local i2 = Grain2.Index;

	local row1 = self.EqList.KCL[i1];
	local column1 = self.Colmax+1;

	local row2 = self.EqList.KCL[i2]
	local column2 = self.Colmax+1;

	self.System[row1][column1] = 1;
	self.System[row2][column2] = -1;

	local eq1 = #self.System+1;
	local eq2 = #self.System+2;
	self.System[eq1] = {};

	self.System[eq2] = {};

	-- Add v1 = 1 and v2 = 0 to the equations.

	local v1 = self.IndexList["V"..i1];
	local v2 = self.IndexList["V"..i2];

	self.System[eq1][v1] = 1;
	self.System[eq2][v2] = 1;

	self.System[eq1][self.Colmax+2] = 1; 
	self.System[eq2][self.Colmax+2] = nil; -- 0

	-- V2 = 0. So we can immediately remove all columns of v2.

	local saved = {};

	for Row, Data in pairs(self.System) do 
		if Data[v2] and Row ~= eq2 then 
			saved[Row] = Data[v2]
			Data[v2] = nil;
		end 
	end 

--	local Out, Sol = Matrix:Solve(self.System);

	local IExt = Matrix:ToUpper_Matlab_LastSol(self.System);

--[[	print('wat')
	for row = 1,#Out do 
		for column = 1,self.Colmax+2 do 
			io.write((Out[row][column] or 0).. " ") 
		end 
		io.write("\n")
	end --]]

--	print(self.Colmax, #self.System)

--	print("COLUMN DATA")

--[[	for i,v in pairs(self.IndexList) do 
		print(i,v)
	end --]]


--	local V = Out[v1][self.Colmax+2];
--	local V2 = Out[v2][self.Colmax+2];
--	local I = Out[self.Colmax+1][self.Colmax+2];

--	local V = Sol[v1];
--	local I = Sol[self.Colmax+1]

	local V = 1;
	local I = IExt;


--[[
	for varname, i in pairs(self.IndexList) do 
		if varname ~= "Current" then 
	--		print(Out[i])
			print(varname .. ": " .. (Sol[i] or 0))
		end
	end --]]
--[[	print(Sol[self.Colmax+1])

	print("Equation dump")

	local function getvar(i) 
		if i == self.Colmax + 1 then 
			return "Iext"
		end 
		for ind, val in pairs(self.IndexList) do 
			--print(val, i, ind)
			if val == i and ind ~= "Current" then 
				return ind
			end 
		end 
	end --]]

	

	--[[for row, data in pairs(self.System) do 
		local eq = ""
		for column, n in pairs(data) do 
			if column == self.Colmax + 2 then 
				eq = eq .. " = " .. n
			else 
				local varname = getvar(column);
				eq = eq .. " + "  .. n ..varname
			end
		end 
		print(eq)
	end 
--]]



	table.remove(self.System);
	table.remove(self.System);

	self.System[row1][column1] = nil;
	self.System[row2][column2] = nil;
	--print(V,I,V2)


	for Row, Data in pairs(saved) do 
		self.System[Row][v2] = Data;
	end 



	return math.abs(V/I);
end 

function Resistance:Update(Grain)
	-- Update the corresponding Ohms law.
	local i1 = Grain.Index;
	local sp = Grain.Spin;
	for _, Grain2 in pairs(Grain.ResistanceNeighbours) do 
		local i2 = Grain2.Index; 
		local varname = "I"..math.min(i1,i2) .. "_"..math.max(i1,i2);

		local row = self.EqList.ResistanceEquation[varname];
		local column = self.IndexList[varname];

		local R = self:GetGrainResistance(sp, Grain2.Spin);
		--print(type(R))
		self.System[row][column] = -R;
	end 
end 

function Resistance:DumpSystem()

	Matrix:DumpMatrix(self.System);
end




--[[function Resistance:GetResistance(Lattice, Grain1, Grain2);
	-- Create a LUT if not there.
	if not Lattice.IndexFromGrain then 
		Lattice.IndexFromGrain = {};
		for i,v in pairs(Lattice.Grains) do 
			Lattice.IndexFromGrain[v] = i;
		end
	end 

	local C = Matrix:New();

	for Index1, Grain in pairs(Lattice.Grains) do;
		local State1 = Grain.Spin;
		for Index2, Neighbour in pairs(Grain.Neighbours) do 
			local State2 = Neighbour.Spin; 
			local C 
			if State1 == State2 then 
				C = 1/self.Resistances[State1]
			else 
				C = 1/self.Resistances[0]
			end
			if not C[Index1] then 
				C[Index1] = {};
			end 
			C[Index1][Index2] = C;
			if not C[Index2] then 
				C[Index2] = {};
			end 
			C[Index2][Index1] = C;
		end 
	end 



end --]]





return Resistance