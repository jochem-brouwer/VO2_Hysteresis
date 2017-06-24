cd('~/Documents/Bacheloropdracht/Model/Ising2')

while (1) 

	while (fopen('matlab_workdir/result.txt') >= 3)
		pause(.01);
	end

	result = -1;
	while (result == -1)
		pause(.01);
		result = fopen('matlab_workdir/work.txt');
	end
	
	result = matlab_lu('matlab_workdir/matlab.dat');
	
	fileid = fopen('matlab_workdir/result_.txt','w');
	fprintf(fileid, '%d\n', result)

	movefile('matlab_workdir/result_.txt', 'matlab_workdir/result.txt')
end 