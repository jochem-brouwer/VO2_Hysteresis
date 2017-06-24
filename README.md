VO_2 Model: Modelling the structural phase transition of Vanadium Dioxide
======


Requirements:

The model can run by only using Lua, which can be downloaded from lua.org (lua version 5.1.5 is supported, later versions are not supported)

However, the extended features of the model, such as graphics, plotting, require external libraries:

Creating gifs: requires gd and lua-gd 

Creating plots: requires gnuplot

Calculating resistances: SPECIAL INSTRUCTIONS. 

The first thing to do is to edit the matlab_lu_driver.m file in order for it to reflect the right directory. Second, the lua file Matrix.lua might also be edited when on a Windows system due to another type of file location descriptions. To run the matlab way of calculating resistances (this is currently the only fast way tested) run, BEFORE starting a simulation, matlab from the command line (you can also start matlab and run the matlab_lu_driver.m file). To do this do matlab -nojvm -nodisplay -nosplash and type run "matlab_lu_driver.m".

For speedup, luajit can be used. This fails to work when creating gifs for some reason.
