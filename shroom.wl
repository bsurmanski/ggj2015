import "entity.wl"
import "gl.wl"
import "drawDevice.wl"
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

class Shroom : Entity {
    static GLMesh mesh
    static GLTexture texture

    bool dead
    
    bool isDead() return .dead

    this() {
        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/mushroom.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/mushroom.tga"))
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
            if(d.scale * 2.2 > 1.5)  {
                d.eat(this)
                .dead = true
            } else {
            }
        }
    }

    float nummies() return 0.01

    Box3 getHitbox() {
        vec4 dim = vec4(3.3, 0.98, 0.86, 0)
        return Box3(.position, dim)
    }

    GLMesh getMesh() return .mesh
    GLTexture getTexture() return .texture
}
