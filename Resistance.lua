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

-- Both;
local rr= Resistance.Resistances;
Resistance.Resistances[0] = 1/(1/rr[1]+1/rr[-1]);

-- NOTE: Why are these parallel?
-- Because in parallel the voltage is the same over both resistors - this makes sense.


-- Calculate the resistance of a given network of resistors (actually a Lattice object)

local Matrix = {};

function Matrix:New();
	return setmetatable({}, {__index=self})
end 

function Resistance:New()
	return setmetatable({A={}, C={}, {__index=self}})
end  

function Resistance:GetC(s1,s2)
	if s1 == s2 then 
		return 1/(self.Resistances[s1])
	else 
		return 1/(self.Resistances[0])
	end 
end 

function Resistance:Update(Grain)
	-- Grain is flipped. Update neighbours.
	local Lattice=self.Lattice;
	local iSelf = Lattice.IndexFromGrain[Grain];



	for i,Grain2 in pairs(Grain.ResistanceNeighbours) do 
		local iGrain = Lattice.IndexFromGrain[Grain2];
		local C = GetC(Grain.Spin,Grain2.Spin)
		C[iSelf][iGrain] = C;
		C[iGrain][iSelf] = C;

		local C_OLD = -A[iSelf][iGrain];
		local Delta = C - C_OLD;

		A[iSelf][iGrain] = -C; 
		A[iGrain][iSelf] = -C;

		A[iSelf][iSelf] = A[iSelf][iSelf] + Delta; 
		A[iGrain][iGrain] = A[iGrain][iGrain] + Delta;
	end 

end 

function Resistance:Setup(Lattice)
	self.Lattice = Lattice;
	if not Lattice.IndexFromGrain then 
		Lattice.IndexFromGrain = {};
		for i,v in pairs(Lattice.Grains) do 
			Lattice.IndexFromGrain[v] = i;
		end
	end 
	for x=1,Lattice.x do 
		for y=1,Lattice.y do
			for z=1,Lattice.z do 
				-- NONPERIODIC
				local Neighbours = Lattice:GetNeighbours(x,y,z,true);
				local Grain1 = Lattice.Grid[x][y][z];
				Grain1.ResistanceNeighbours = {};

				local i1 = Lattice.IndexFromGrain[Grain1]

				for _, Neighbour in pairs(Neighbours) do 
					local Grain2 = Lattice.Grid[Neighbour[1]][Neighbour[2]][Neighbour[3]]	
					table.insert(Grain1.ResistanceNeighbours, Grain2);		
					local i2 = Lattice.IndexFromGrain[Grain2];

					local C = self:GetC(Grain1.Spin,Grain2.Spin);

					self.C[i1][i2] = C;
					self.C[i2][i1] = C;
				end
			end 
		end 
	end 

	-- Make A
	local C = self.C;
	local A = self.A; 
	for i = 1, #C[1] do 
		for j, Cij in pairs(C[i]) do 
			if not A[i] then 
				A[i] = {};
			end 
			if i ~= j then 
				A[i][j] = -Cij 
			else 
				local sum = 0;
				for k = 1, #A[i] do 
					sum = sum + A[i][k]
				end 
				A[i][j] = sum;
			end 
		end 
	end 


end 


function Resistance:GetResistance(Lattice,Grain1,Grain2)
	local i1 = Lattice.IndexFromGrain[Grain1];
	local i2 = Lattice.IndexFromGrain[Grain2];


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