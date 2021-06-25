SDCC=sdcc
CPU=z80
CODE=os
OBJ=os.rel
DATALOC=0xC000

all: $(CODE).bin

%.rel: %.c
	$(SDCC) -m$(CPU) -c --data-loc $(DATALOC) $<
	
%.ihx: $(OBJ)
	$(SDCC) -m$(CPU) --data-loc $(DATALOC) $(OBJ)
 
%.hex: %.ihx
	mv $< $@

%.bin: %.hex
	srec_cat $< -intel -o $@ -binary

disasm: $(CODE).bin
	z80dasm -a -t -g 0 $<

clean:
	rm -rf *~ *.asm *.ihx *.lk *.lst *.map *.noi *.rel *.sym *.hex *.bin
