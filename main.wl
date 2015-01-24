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
import "cookie.wl"
import "grub.wl"
import "mouse.wl"

import "man.wl"
import "title.wl"
import "vec.wl"


undecorated int printf(char^ fmt, ...);

bool running = true
GLDrawDevice glDevice
GLTexture tex

DuckMan man
Title title
mat4 view

GLMesh house_inside_mesh
GLTexture house_inside_tex
Cookie cookie

void init() {
    SDLWindow window = new SDLWindow(640, 480, "test")
    Image i = loadTGA(new StringFile(pack "res/test.tga"))
    tex = new GLTexture(i)
    glDevice = new GLDrawDevice(640, 480)
    man = new DuckMan()
    title = new Title()
    cookie = new Cookie()

    initMice()
    initGrubs()

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

    cookie.update(dt)

    updateMice(dt)
    updateGrubs(dt)

    view = mat4()
    view = view.translate(vec4(-man.position.v[0], 
                            -6.0f * man.scale - 1, 
                            -8.0f * man.scale - man.position.v[2] - 1, 0))
    view = view.rotate(0.5, vec4(1, 0, 0, 0))
}

void draw_house() {
    glFrontFace(GL_CW)
    glEnable(GL_CULL_FACE)
    glDevice.runMeshProgram(house_inside_mesh, house_inside_tex, view)
    glDisable(GL_CULL_FACE)
}

void draw() {
    glDevice.clearBuffer()
    glDevice.clear()
    tex.bind()
    //title.draw()
    draw_house()
    man.draw(view)

    drawMice(view)
    drawGrubs(view)

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
        dt = 0.03
    }

    return 0
}
