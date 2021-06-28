# Make C code
cd src
make clean
make all
cd ..

# Verilate HDL
#cd verilator
#./verilate.sh
#cd ..

# Hexify roms
od -An -t x1 -v src/os.bin > verilator/rom.hex
od -An -t x1 -v src/os.bin > rtl/rom.hex
od -An -t x1 -v MiSTer.pf > verilator/font.hex
od -An -t x1 -v MiSTer.pf > rtl/font.hex

