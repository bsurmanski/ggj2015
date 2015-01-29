import "gl.wl"
import "drawDevice.wl"
import "entity.wl"
import "fmt/tga.wl"
import "fmt/mdl.wl"
import "mesh.wl"
import "image.wl"
import "file.wl"
import "vec.wl"
import "collision.wl"

use "importc"
import(C) "math.h"
import(C) "SDL/SDL_mixer.h"

class DuckMan : Entity {
    static GLMesh mesh
    static GLTexture texture
    static Mix_Chunk^ hop
    static Mix_Chunk^ munch
    bool moved
    float scale
    bool dead
    float nummyTimer

    static DuckMan instance
    static DuckMan getInstance() {
        return instance
    }

    bool isDead() return .dead

    this() {
        instance = this

        Image img = loadTGA(new StringFile(pack "res/pillduck.tga"))
        .texture = new GLTexture(img)
        Mesh m = loadMdl(new StringFile(pack "res/pillduck.mdl"))
        .mesh = new GLMesh(m)
        hop = Mix_LoadWAV_RW(SDL_RWFromFile("res/hop.wav", "rb"), 1)
        munch = Mix_LoadWAV_RW(SDL_RWFromFile("res/munch.wav", "rb"), 1)
        Mix_VolumeChunk(hop, 30)
        Mix_VolumeChunk(munch, 70)

        .scale = 0.1
        .position = vec4(0, 0, 0, 1)
    }

    void reset() {
        .dead = false
        .nummyTimer = 0
        .scale = 0.1
        .position = vec4(0, 0, 0, 1)
    }

    Box3 getHitbox() {
        vec4 dim = vec4(1.8, 2.5, 1.8, 0)
        return Box3(.position, dim.mul(.scale))
    }

    void eat(Entity e) {
        Mix_PlayChannelTimed(-1, .munch, 0, -1)
        .scale += e.nummies()
        .nummyTimer += e.yummyNummies()

        printf("%f\n", .scale)
        //win
        if(e.areYouCookie()) {
        }
    }

    void update(float dt) {
        static float tick

        // cos is derivitive of sin; and *2 frequency since func is abs(sin)
        bool inflection = cos(tick * 20.0f) < 0.0f and cos((tick + dt) * 20.0f) > 0.0f

        tick += dt

        float targety = 0.0f
        if(.moved) {
            targety = fabs(sin(tick * 10.0f)) / 4.0f
        }
        .position.v[1] = (.position.v[1] + (targety - .position.v[1]) * 0.6f)
        if(inflection and .moved) {
            Mix_PlayChannelTimed(-1, .hop, 0, -1)
        }
        .moved = false

        if(.nummyTimer > 0.0f) {
            .nummyTimer -= dt
        }

        // keep the dude in the boundaries
        if(.position.v[0] > 10 - .scale/2) .position.v[0] = 10 - .scale/2
        if(.position.v[0] < -10 + .scale/2) .position.v[0] = -10 + .scale/2
        if(.position.v[2] > 10 - .scale/2) .position.v[2] = 10 - .scale/2
        if(.position.v[2] < -10 + .scale/2) .position.v[2] = -10 + .scale/2
    }

    void rotate(float f) {
        .rotation += f
    }

    void step() {
        vec4 axis = vec4(0, 1, 0, 0)
        vec4 dv = vec4(0, 0, -0.2 * sqrtf(.scale), 0)
        mat4 matrix = mat4()
        matrix = matrix.rotate(.rotation, axis)
        dv = matrix.vmul(dv)

        if(.nummyTimer > 0.0f) {
            dv = dv.mul(1.5f)
        }

        .position = .position.add(dv)
        .moved = true
    }

    float getScale() return .scale

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()

        float scale = .getScale()

        mat4 mat = mat4()
        vec4 axis = vec4(0, 1, 0, 0)
        mat = mat.rotate(.rotation, axis)
        mat = mat.scale(scale, scale, scale)
        mat = mat.translate(.position)
        mat = view.mul(mat)

        dev.runMeshProgram(.getMesh(), .getTexture(), mat)

        if(dev.drawHitbox) dev.drawBoundingBox(.getHitbox(), view)
    }

    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture
}
