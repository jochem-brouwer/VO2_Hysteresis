local Matrix = {}

--[[local bc = require 'bc'
bc.digits(1000);--]]

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
			--print(type(Number),type(mult),type(Target[Column]))
			--print(mult)
			local newval = (Target[Column] or 0) + mult*Number
			if newval == 0 then 
				newval = nil
			end
			Target[Column] = newval;
			tm[Column][row_to] = newval;

		end 
	end 
end 

-- no skip
local function AddRow_ns(row_from, row_to, mult, nm,tm,skip)
	local Target = nm[row_to];
	local Source = nm[row_from];


	for Column, Number in pairs(Source) do 

 
			--print(type(Number),type(mult),type(Target[Column]))
			--print(mult)
			local newval = (Target[Column] or 0) + mult*Number
			if newval == 0 then 
				newval = nil
			end
			Target[Column] = newval;
			tm[Column][row_to] = newval;


	end 
end 

-- swap row1 and row2
local function SwapRow(row1, row2, nm, tm)
	local r1 = nm[row1];
	local r2 = nm[row2];

	print(row1,row2)
	nm[row1] = r2;
	nm[row2] = r1;

	for column, data in pairs(r1) do 
		tm[column][row2] = data; 
	end 

	for column, data in pairs(r2) do 
		tm[column][row1] = data 
	end 

end 





function Matrix:Det(A, skip_cr)
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
			TransposedMatrix[Column][Row] = Number;--bc.number(Number);
			NewMatrix[Row][Column] = Number; --bc.number(Number);
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
					--print(AddVal,DiagVal,NewMatrix[Row2][Row])
					AddRow(Row,Row2,AddVal,NewMatrix,TransposedMatrix, skip_cr);
				end
			end 
		end 
	end 

	--print("EIG")
	local out = 1;
	for i=1,size do
		if not skip_cr[i] then 
			out = out * NewMatrix[i][i];
		--	print(out)
		end
	end

	return out 
end 

function Matrix:ToUpper(A)
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
			TransposedMatrix[Column][Row] = Number;--bc.number(Number);
			NewMatrix[Row][Column] = Number; --bc.number(Number);
		end 
	end 


	-- Terminology doesnt matter
	for Row, Data in pairs(NewMatrix) do 
		local pivot_i 
		local max = -math.huge
		 for check_row, number in pairs(TransposedMatrix[Row]) do 
     	--	print(check_row)
     		if math.abs(number) > max then 
     			max = math.abs(number);
     			pivot_i = check_row 
     		else
     	--		print("there")
     		end
     	end 

     --	if check_row ~= Row then 
     --		SwapRow(pivot_i, Row, NewMatrix, TransposedMatrix);
     --	end 

		local DiagVal = NewMatrix[Row][Row];
		for Row2, Number in pairs(TransposedMatrix[Row]) do 
			if Row2 > Row and NewMatrix[Row2][Row] then
				local AddVal = -NewMatrix[Row2][Row]/DiagVal;
				--print(AddVal,DiagVal,NewMatrix[Row2][Row])
				AddRow(Row,Row2,AddVal,NewMatrix,TransposedMatrix, skip_cr);
			end
		end      	
	end 

	return 
end 

function Matrix:ToFile(A, fname)
	local f,err = io.open(fname, 'w');
	if not f then 
		print(err)
	end 
	local rsize = #A;
	local csize = 0;
	for Row, Data in pairs(A) do 
		for Column, Number in pairs(Data) do
			f:write(Row .. "\t" .. Column .. "\t" .. Number .. "\n")
			csize = math.max(csize,Column)
		end 
	end 
	if not A[rsize][csize] then 
		f:write( rsize.. "\t" .. csize .. "\t" .. (A[rsize][csize] or 0) .. "\n")
	end
	f:close()
end 

function Matrix:ToUpper_Matlab_LastSol(A)
	self:ToFile(A, 'matlab_workdir/matlab.dat')
	this,err = io.open('matlab_workdir/work.txt','w')
	if not this then
		print(err)
	end
	this:close()
	local f 
	repeat
		os.execute("sleep 0.01")
		f = io.open('matlab_workdir/result.txt')
	until f 



	os.remove('matlab_workdir/work.txt');
	os.remove('matlab_workdir/result.txt');

	result = tonumber(f:read("*all") or 0);
	f:close()
	return result
end

-- Only care about last solution.
function Matrix:ToUpper_LastSol(A)
	local o = os.clock();
	local PRINT
	local function timer(str)
		print(str .. (os.clock() - o));
		o = os.clock();
	end 
	local function reset()
		o = os.clock() 
	end
	local skip_cr = skip_cr or {};
	local NewMatrix = {};
	local TransposedMatrix = {};
	local size = #A;
	local colsize=0;
	for Row, Data in pairs(A) do 
		NewMatrix[Row] = {}
		for Column, Number in pairs(Data) do 
			colsize=math.max(colsize,Column)
			if not TransposedMatrix[Column] then
				TransposedMatrix[Column] = {}
			end 
			TransposedMatrix[Column][Row] = Number;--bc.number(Number);
			NewMatrix[Row][Column] = Number; --bc.number(Number);
		end 
	end 

	local Skips = {};

	local p = 0;
	local lim=math.min(colsize,size)-1;
	local last 
	for Column = 1, lim do

		local ColData = TransposedMatrix[Column];
		local pivot_i
		local max = 0
		for Row, Number in pairs(ColData) do 
			--pivot_i = Row; do break end;
			if not Skips[Row] and math.abs(Number) > max then 
				max = math.abs(Number);
				pivot_i = Row 
			end 
		end 

		
		Skips[pivot_i] = true;

		local ThisVal = NewMatrix[pivot_i][Column];
		local rsize = 0;
		for Row, Number in pairs(ColData) do 
			if not Skips[Row] then 
				rsize=rsize+1;
				local AddVal = -Number/ThisVal;
				AddRow_ns(pivot_i, Row, AddVal,NewMatrix,TransposedMatrix)
			end 
		end 

		--Remove pivot row 

	--[[	if not (Column == math.min(colsize,size)-1) then 
			--NewMatrix[pivot_i] = nil;
			NewMatrix[pivot_i] = nil;
			for Column, Data in pairs(TransposedMatrix) do 
				Data[pivot_i] = nil; 
			end
		else 
			last = NewMatrix[pivot_i]
		end --]]
		last = NewMatrix[pivot_i]

		local p2 = math.floor(Column/colsize*100);

		if p2 > p then 
			p=p2;
			print(p .. "%",rsize,size,colsize)
			timer('')
			PRINT=true 
		else
			PRINT=false;
		end
	end 

	--local Multiplier = NewMatrix[size][colsize-1]; 
	--local Solution   = NewMatrix[size][colsize];

	local Multiplier = last[colsize-1];
	local Solution = last[colsize];

	print(Multiplier/Solution, Multiplier,Solution)



	return Solution/Multiplier
end 

local function showm(M,s)
	--do return end
	for row = 1,#M do 
		for column = 1,s do 
			--print(row,column, M[row][column])
			io.write(((M[row][column] or 0)).. " ") 
		end 
		io.write("\n")
	end 
end

function Matrix:DumpMatrix(A)
	local colsize=0;
	for Row, Data in pairs(A) do 
		--NewMatrix[Row] = {}
		for Column, Number in pairs(Data) do 
			colsize=math.max(colsize,Column)
		end 
	end 
	showm(A,colsize)
end

function Matrix:Solve(A)

	local NewMatrix = {};
	local TransposedMatrix = {};
	local size = #A;
	local colsize = 0;

	local pivots = {};

	for Row, Data in pairs(A) do 
		NewMatrix[Row] = {}
		for Column, Number in pairs(Data) do 
			if not TransposedMatrix[Column] then
				TransposedMatrix[Column] = {}
			end 
			TransposedMatrix[Column][Row] = Number;--bc.number(Number);
			NewMatrix[Row][Column] = Number; --bc.number(Number);
			colsize = math.max(Column,colsize)
		end 
	end 

	--showm(NewMatrix,colsize)


     local function addrow(row, row2,mul,column0)
     	local r = NewMatrix[row];
     	for i,v in pairs(r) do 
     		local result = (NewMatrix[row2][i] or 0) + mul*r[i];
			if result == 0 then result = nil end;
			if v == column0 then result = nil end 
     		NewMatrix[row2][i] = result;
     		TransposedMatrix[i][row2] = result;
     	end 
     end 

     local function mulrow(row, number) 
     	local r = NewMatrix[row];
     	for i,v in pairs(r) do 
     		r[i] = v*number;
     		TransposedMatrix[i][row] = r[i];
     	end 
     end 

     local c = os.clock()
     for row = 1, #NewMatrix-1 do 
     	print(row/(#NewMatrix-1),colsize, os.clock() - c)
     	c = os.clock();
     	local max = -math.huge;
     	local pivot_i 

     	-- Find largest pivot;
     --	print("FINDING PIVOT")
     	for check_row, number in pairs(TransposedMatrix[row]) do 
     	--	print(check_row)
     		if not pivots[check_row] and math.abs(number) > max then 
     			max = math.abs(number);
     			pivot_i = check_row 
     		else
     	--		print("there")
     		end
     	end 
		if not pivot_i then 
     	--	showm(NewMatrix,colsize)
     	--	print(row, #NewMatrix)
     	--	print(#NewMatrix, colsize)
     		break 
     	end

     	pivots[pivot_i] = true;

  		local pivot = pivot_i; 
  		--print("Multiplying row " .. pivot_i ..1/NewMatrix[pivot_i][row])
  		mulrow(pivot_i, 1/NewMatrix[pivot_i][row]);

  		for check_row, number in pairs(TransposedMatrix[row]) do 
  			if check_row ~= pivot then 
  				--print("Adding row " .. pivot_i .. " to " .. check_row .." w ".. -number)
  				addrow(pivot, check_row, -number/NewMatrix[pivot_i][row], check_row)
  			end
  		end 
-- 		showm(NewMatrix,colsize)


     end 

     -- Create the solution vector

     local SolVec = {};

     for Column, Data in pairs(TransposedMatrix) do 

     	--print(Column)
     	if column ~= colsize then 
     		for Row, Number in pairs(Data) do 
     			SolVec[Column] = NewMatrix[Row][colsize];
     		end 
     	end
     end 

     return NewMatrix, SolVec
end 


return Matrix;