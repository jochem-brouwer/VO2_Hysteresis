% MATLAB driver for LU

% get a tmpname 

function out = matlab_lu(fname);

	test = load(fname);
	sp = spconvert(test);
	l = lu(sp);

	sol = l(end-1,end);
	mul = l(end-1,end-1);

	out = full(sol/mul)
end 