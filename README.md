VO_2 Model: Modelling the structural phase transition of Vanadium Dioxide
======


Requirements:

The model can run by only using Lua, which can be downloaded from lua.org (lua version 5.1.5 is supported, later versions are not supported)

However, the extended features of the model, such as graphics, plotting, require external libraries:

Creating gifs: requires gd and lua-gd 

Creating plots: requires gnuplot

Calculating resistances: requires lbc (lua library)

For speedup, luajit can be used. This fails to work when creating gifs for some reason.
