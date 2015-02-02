use "importc"

import(C) "SDL/SDL.h"

bool initialized = false

void initSDL() {
    SDL_Init(SDL_INIT_VIDEO)
    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8)
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8)
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8)
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8)
}

class SDLWindow {
    SDL_Surface^ screen

    this(int w, int h, char^ name) {
        if(initialized) {
            initSDL()
            initialized = true
        }

        .screen = SDL_SetVideoMode(w, h, 32, SDL_OPENGL)
        SDL_WM_SetCaption(name, null)
    }

    ~this() {
    }

    void swapBuffers() {
        SDL_GL_SwapBuffers()
        SDL_Flip(.screen)
    }
    
    void tick() {
        SDL_Delay(32)
    }

    void clear() {
        SDL_FillRect(.screen, null, 0)
    }
}
