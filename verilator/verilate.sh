
set -e
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
verilator \
--cc \
--compiler msvc +define+SIMULATION=1 \
-O3 --x-assign fast --x-initial fast --noassert \
-Wno-TIMESCALEMOD \
--converge-limit 6000 \
--top-module emu sim.v \
-I../rtl \
-I../rtl/JTFRAME \
-I../rtl/tv80
    else
	        echo "not running on windows"
fi
