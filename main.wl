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
import "title.wl"
import "vec.wl"


undecorated int printf(char^ fmt, ...);

bool running = true
GLDrawDevice glDevice
GLTexture tex

DuckMan man
Title title

GLMesh house_inside_mesh
GLTexture house_inside_tex

void init() {
    SDLWindow window = new SDLWindow(640, 480, "test")
    Image i = loadTGA(new StringFile(pack "res/test.tga"))
    tex = new GLTexture(i)
    glDevice = new GLDrawDevice(640, 480)
    man = new DuckMan()
    title = new Title()

    i = loadTGA(new StringFile(pack "res/house_inside.tga"))
    house_inside_tex = new GLTexture(i)
    Mesh m = loadMdl(new StringFile(pack "res/house_inside.mdl"))
    house_inside_mesh = new GLMesh(m)
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
    glDevice.update(dt)
    man.update(dt)
}

void draw() {
    glDevice.clearBuffer()
    glDevice.clear()
    tex.bind()
    //title.draw()
    glDevice.runMeshProgram(house_inside_mesh, house_inside_tex, mat4())
    man.draw()
    glDevice.drawQuad()

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
