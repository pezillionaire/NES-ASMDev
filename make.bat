ca65 nestest.asm -o nestest.o --debug-info
ld65 nestest.o -o nestest.nes -t nes --dbgfile nestest.dbgfile
