import "entity.wl"
import "libwl/gl.wl"
import "drawDevice.wl"
import "libwl/mesh.wl"
import "libwl/image.wl"
import "libwl/fmt/tga.wl"
import "libwl/fmt/mdl.wl"
import "libwl/vec.wl"
import "libwl/file.wl"
import "libwl/random.wl"
import "libwl/collision.wl"

import "man.wl"

use "importc"
import(C) "math.h"

class Carrot : Entity {
    static GLMesh mesh
    static GLTexture texture

    bool dead
    
    bool isDead() return .dead

    this() {
        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/carrot.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/carrot.tga"))
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

    float nummies() return 0.15

    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture

    Box3 getHitbox() {
        vec4 dim = vec4(1.0, 0.98, 0.86, 0)
        return Box3(.position, dim)
    }
}

void initCarrots() {
    for(int i = 0; i < 3; i++) {
        (Entity.add(new Carrot()))
    }
}
