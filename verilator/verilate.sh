
set -e
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
$VERILATOR_ROOT/bin/verilator \
-cc \
-exe \
--public \
--compiler msvc +define+SIMULATION=1 \
-O3 --x-assign fast --x-initial fast --noassert \
--converge-limit 6000 \
--top-module emu sim.v \
../rtl/dpram.v \
../rtl/spram.v \
../rtl/JTFRAME/jtframe_vtimer.v \
../rtl/JTFRAME/jtframe_cen24.v \
../rtl/system.v \
../rtl/tv80/tv80_core.v \
../rtl/tv80/tv80_alu.v \
../rtl/tv80/tv80_mcode.v \
../rtl/tv80/tv80_reg.v \
../rtl/tv80/tv80n.v \
../rtl/tv80/tv80s.v
    else
	        echo "not running on windows"
fi
