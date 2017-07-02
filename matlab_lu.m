% MATLAB driver for LU

% get a tmpname 

function out = matlab_lu(fname);

	test = load(fname);
	sp = spconvert(test);
	[l,u] = lu(sp);

	
	sizeof = size(u);
	colsize = sizeof(2);

%	full(u)


	sol = u(colsize-1,end);
	mul = u(colsize-1,end-1);

	out = full(sol/mul)
end 