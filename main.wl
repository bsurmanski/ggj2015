//XXX it errors if out of order
use "importc"
import(C) "SDL/SDL.h"
import "image.wl"
import "fmt/tga.wl"
import "file.wl"
import "gl.wl"
import "sdl.wl"
import "mesh.wl"
import "fmt/mdl.wl"
import "collision.wl"
import "random.wl"

import "man.wl"


undecorated int printf(char^ fmt, ...);

bool running = true
GLDrawDevice glDevice
GLTexture tex

DuckMan man

void init() {
    SDLWindow window = new SDLWindow(640, 480, "test")
    Image i = loadTGA(new StringFile(pack "res/test.tga"))
    tex = new GLTexture(i)
    glDevice = new GLDrawDevice(640, 480)
    man = new DuckMan()
}

void input() {
    SDL_PumpEvents()
    uint8^ keystate = SDL_GetKeyState(null)

    if(keystate[SDLK_SPACE]) {
        running = false
    }

    if(keystate[SDLK_LEFT]) {
        man.rotate(0.25)
    }

    if(keystate[SDLK_RIGHT]) {
        man.rotate(-0.25)
    }

    if(keystate[SDLK_UP]) {
        man.step()
    }
}

void update(float dt) {
    man.update(dt)
}

void draw() {
    glClear(GL_COLOR_BUFFER_BIT)
    glClear(GL_DEPTH_BUFFER_BIT)

    tex.bind()
    man.draw()
    //glDevice.drawQuad()

    SDL_GL_SwapBuffers()
}

int main(int argc, char^^ argv) 
{
    init()
    float dt = 0
    while(running) {
        input()
        update(dt)
        draw()
        SDL_Delay(32)
        dt += 0.03
    }

    return 0
}
