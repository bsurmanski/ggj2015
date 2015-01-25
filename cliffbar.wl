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

class Cliffbar : Entity {
    static GLMesh mesh
    static GLTexture texture

    bool dead
    
    bool isDead() return .dead

    float yummyNummies() return 10.0f

    this() {
        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/cliffbar.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/cliffbar.tga"))
            .texture = new GLTexture(i)
        }
        .rotation = randomFloat() * 6 // 6 = 2PI (close enough)
        .position.v[0] = randomFloat() * 18.0f - 9.0f
        .position.v[2] = randomFloat() * 18.0f - 9.0f
    }

    void update(float dt) {
        DuckMan d = DuckMan.getInstance()
        Box3 dhit = d.getHitbox()
        if(dhit.collides(.getHitbox())) {
            d.eat(this)
            .dead = true
        }
        .rotation += 0.1
        .position.v[1] = (sin(.rotation) / 2.0f + 0.5) / 10.0f
    }

    Box3 getHitbox() {
        vec4 dim = vec4(0.2, 0.2, 0.2, 0)
        return Box3(.position, dim)
    }

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()
        mat4 mat = mat4()
        mat = mat.rotate(.rotation, vec4(0, 1, 0, 0))
        mat = mat.translate(.position)
        mat = view.mul(mat)
        dev.runMeshProgram(.mesh, .texture, mat)
    }
}

void initCliffbars() {
    for(int i = 0; i < 2; i++) {
        (Entity.add(new Cliffbar()))
    }
}