#!/bin/sh

INPUT="$1"

ca65 $INPUT.asm -o $INPUT.o --debug-info

echo "NES file generated: $INPUT.o"
ld65 $INPUT.o -o $INPUT.nes -t nes --dbgfile $INPUT.dbg
echo "NES file generated: $INPUT.nes"
echo "NES file generated: $INPUT.dbg"
