import "entity.wl"
import "gl.wl"
import "mesh.wl"
import "image.wl"
import "fmt/tga.wl"
import "fmt/mdl.wl"
import "vec.wl"
import "file.wl"
import "random.wl"
import "collision.wl"

import "man.wl"

use "importc"
import(C) "math.h"
import(C) "SDL/SDL_mixer.h"

Mix_Chunk^ girlDead 

class GirlDuck : Entity {
    static const int STATE_ROTATE = 0
    static const int STATE_MOVE = 1
    static GLMesh mesh
    static GLTexture texture
    float scale
    int state
    int spin
    bool dead
    float timer

    bool isDead() return .dead

    this() {
        .scale = 1.5f
        .spin = 1
        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/pillduck.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/girlduck.tga"))
            .texture = new GLTexture(i)
        }

        if(!girlDead)
            girlDead = Mix_LoadWAV_RW(SDL_RWFromFile("res/girldead.wav", "rb"), 1)

        .rotation = randomFloat() * 6 // 6 = 2PI (close enough)
        .position.v[0] = randomFloat() * 20.0f - 10.0f
        .position.v[2] = randomFloat() * 20.0f - 10.0f
    }

    float nummies() return 0.07f

    void update(float dt) {
        static float tick
        bool inflection = cos(tick * 20.0f) < 0.0f and cos((tick + dt) * 20.0f) > 0.0f
        float targety = fabsf(sin(tick * 10.0f)) / 4.0f
        tick += dt

        .timer -= dt

        if(.timer <= 0) {
            .state = !.state //swap tween rotate/move
            if(randomFloat() > 0.4) .spin = -.spin

            if(.state == 0) {
                .timer = randomFloat() 1.5f
            } else {
                .timer = randomFloat() * 3.0f
            }
        }

        DuckMan d = DuckMan.getInstance()
        Box3 dhit = d.getHitbox()
        if(dhit.collides(.getHitbox())) {
            if(d.scale > .scale) {
                d.eat(this)
                .dead = true

                Mix_PlayChannelTimed(-1, girlDead, 0, -1) 
            } else {
                d.dead = true
            }
        }
        
        if(.state == 0) {
            .rotation += 0.25 * .spin
            if(randomFloat() > 0.95) .spin = -.spin
        } else if(.state == 1) {
            .rotation += 0.1 * .spin
            if(randomFloat() > 0.96) .spin = -.spin
            vec4 dv = vec4(0, 0, -0.05 * sqrt(.scale), 0)

            mat4 matrix = mat4()
            matrix = matrix.rotate(.rotation, vec4(0, 1, 0, 0))
            dv = matrix.vmul(dv)

            if(.position.v[0] < -9.0f || .position.v[0] > 9.0f ||
                .position.v[2] < -9.0f || .position.v[2] > 9.0f) {
                if(dv.dot(.position) > 0) {
                    .state = 0
                    .timer /= 2.0f
                    return
                }
            }

            .position = .position.add(dv)
            .position.v[1] = (.position.v[1] + (targety - .position.v[1]) * 0.6f)
        } else {
            .state = 0
        }
    }

    Box3 getHitbox() {
        vec4 dim = vec4(1.5, 2.5, 1.5, 0)
        dim.mul(.scale)
        return Box3(.position, dim)
    }

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()
        mat4 mat = mat4()
        mat = mat.scale(.scale, .scale, .scale)
        mat = mat.rotate(.rotation, vec4(0, 1, 0, 0))
        mat = mat.translate(.position)
        mat = view.mul(mat)
        dev.runMeshProgram(.mesh, .texture, mat)
    }
}
