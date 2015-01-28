all:
	wlc main.wl -c -o output.o
	gcc -c port.c -lGL -lGLEW -o port.o
	gcc output.o port.o -lSDL -lSDL_mixer -lGL -l:libGLEW.so.1.10 -lc -lm

old:
	wlc main.wl -lGL -lSDL -lSDL_mixer -lglew

ll:
	wlc main.wl -S
