SDCC=sdcc
CPU=z80
CODE=boot_rom
OBJ=boot_rom.rel font.rel

all: $(CODE).bin

%.rel: %.c
	$(SDCC) -m$(CPU) -c $<
	
%.ihx: $(OBJ)
	$(SDCC) -m$(CPU) $(OBJ)
 
%.hex: %.ihx
	mv $< $@

%.bin: %.hex
	srec_cat $< -intel -o $@ -binary

disasm: $(CODE).bin
	z80dasm -a -t -g 0 $<

clean:
	rm -rf *~ *.asm *.ihx *.lk *.lst *.map *.noi *.rel *.sym *.hex *.bin
