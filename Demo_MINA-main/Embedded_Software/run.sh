#!/bin/bash
clear && printf '\033[3J'
# Compile and run the main program
gcc ECG_Embedded_Software.c -o main $(pkg-config --cflags --libs sdl2 SDL2_ttf) -O2 -lm
./main
rm -f main
