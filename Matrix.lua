local Matrix = {}

local function set(Matrix,TransposedMatrix,r,c,val)
	Matrix[c][r]=val;
	TransposedMatrix[r][c]=val;
end

-- add row from row_from to row_to, multiplying with mult, from the normal matrix nm and transposed matrix tm
local function AddRow(row_from, row_to, mult, nm,tm)
	local Target = nm[row_to];
	local Source = nm[row_from];

	print("TARGET", table.concat(Target, ", "));
	print("SOURCE", table.concat(Source, ", "));

	for Column, Number in pairs(Source) do 
		print("Column",Column, row_from)
		if Column < row_from then
			-- this is the uppert part of the matrix, don't care about it.
		else 

			local newval = (Target[Column] or 0) + mult*Number
			print("oldval", Target[Column],newval,mult)
			Target[Column] = newval;
			tm[Column][row_to] = newval;
		end 
	end 
end 

function MATDUMP(M)
	for Row, Data in pairs(M) do 
		print(table.concat(Data, ", "))
	end 
end 

function Matrix:Det(A)
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
		print("Row", Row)
		-- Loop over 
		local DiagVal = NewMatrix[Row][Row];
		for Row2, Number in pairs(TransposedMatrix[Row]) do 
			if Row2 > Row then
				local AddVal = -NewMatrix[Row2][Row]/DiagVal;
				AddRow(Row,Row2,AddVal,NewMatrix,TransposedMatrix);
			end
				MATDUMP(NewMatrix)
		end 
	end 
	-- huh is this it?!

	for i,v in pairs(NewMatrix) do 
		for ind, val in pairs(v) do 
			io.write(val .. " ")
		end 
		io.write("\n")
	end

	local out = 1;
	for i=1,size do
		out = out * NewMatrix[i][i];
	end
	print(out)
end 


return Matrix;