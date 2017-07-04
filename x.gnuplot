set terminal png enhanced size 640, 480 font "Arial,12"
set key top left
set ylabel "Y axis"
set xlabel "X axis"
set terminal png
set output "output.png"
gamma = 2.5
plot "x.gnuplot" u 1:2:3 w  yerrorbars lc rgb "black" t "Error bars"