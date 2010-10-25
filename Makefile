SRC 	= f1.asm

%: %.asm
	wine ML $<
	dosbox $(<:asm=exe)
clean:
	rm -f $(SRC:asm=exe) $(SRC:asm=obj)

