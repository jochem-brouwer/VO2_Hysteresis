local Matrix = {}

local function set(Matrix,TransposedMatrix,r,c,val)
	Matrix[c][r]=val;
	TransposedMatrix[r][c]=val;
end

-- add row from row_from to row_to, multiplying with mult, from the normal matrix nm and transposed matrix tm
local function AddRow(row_from, row_to, mult, nm,tm,skip)
	local Target = nm[row_to];
	local Source = nm[row_from];


	for Column, Number in pairs(Source) do 

		if Column < row_from or skip[Column] then
			-- this is the uppert part of the matrix, don't care about it.
		else 

			local newval = (Target[Column] or 0) + mult*Number
			if newval == 0 then 
				newval = nil
			end
			Target[Column] = newval;
			tm[Column][row_to] = newval;

		end 
	end 
end 



function Matrix:Eig(A, skip_cr)
	local skip_cr = skip_cr or {};
	local NewMatrix = {};
	local TransposedMatrix = {};
	local size = #A;
	for Row, Data in pairs(A) do 
		NewMatrix[Row] = {}
		for Column, Number in pairs(Data) do 
			if not TransposedMatrix[Column] then
				TransposedMatrix[Column] = {}
			end 
			TransposedMatrix[Column][Row] = Number;
			NewMatrix[Row][Column] = Number;
		end 
	end 


	-- Terminology doesnt matter
	for Row, Data in pairs(NewMatrix) do 
		if not skip_cr[Row] then 
			-- Loop over 
			local DiagVal = NewMatrix[Row][Row];
			for Row2, Number in pairs(TransposedMatrix[Row]) do 
				if Row2 > Row and not skip_cr[Row2] then
					local AddVal = -NewMatrix[Row2][Row]/DiagVal;

					AddRow(Row,Row2,AddVal,NewMatrix,TransposedMatrix, skip_cr);
				end
			end 
		end 
	end 


	local out = 1;
	for i=1,size do
		if not skip_cr[i] then 
			out = out * NewMatrix[i][i];
		end
	end

	return out 
end 


return Matrix;