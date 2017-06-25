cd('~/Documents/Bacheloropdracht/Model/Ising2')

while (1) 

	result_wait = 10;
	while (result_wait >= 3)
		result_wait = fopen('matlab_workdir/result.txt');
		if (result_wait >= 3)
			fclose(result_wait)
		end
		pause(.01);
	end

	result = -1;
	while (result == -1)
		pause(.01);
		result = fopen('matlab_workdir/work.txt');
	end
	
	resultr = matlab_lu('matlab_workdir/matlab.dat');
	
	fileid = fopen('matlab_workdir/result_.txt','w');
	fprintf(fileid, '%d\n', resultr)

	movefile('matlab_workdir/result_.txt', 'matlab_workdir/result.txt')

	fclose(fileid);
	fclose(result);

end 