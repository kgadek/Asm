SRC 	= f1.asm ra.asm

.PHONY: clean
%: %.asm
	wine ML $<
	dosbox $(<:asm=exe)

clean:
	rm -f $(SRC:asm=exe) $(SRC:asm=obj)
