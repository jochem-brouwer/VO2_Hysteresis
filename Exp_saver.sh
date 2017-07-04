arg_in = $1

mkdir "results_scripts/$arg_in"
cp "$arg_in.lua" results/$arg_in
mv out.gif results/$arg_in
mv output.png results/$arg_in
