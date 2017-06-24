
PWD=`pwd`
MATLAB='/Applications/MATLAB_R2014b.app/bin/matlab -nojvm -nodisplay -nosplash -r'
ARGS="\"cd '$PWD'; run('matlab_lu_driver.m')\""

eval $MATLAB $ARGS