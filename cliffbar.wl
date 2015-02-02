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

class Cliffbar : Entity {
    static GLMesh mesh
    static GLTexture texture

    bool dead
    
    bool isDead() return .dead

    float yummyNummies() return 10.0f
    float nummies() return 0.1

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
        if(dhit.collides(.getHitbox()) and d.scale > 0.4) {
            d.eat(this)
            .dead = true
        }
        .rotation += 0.1
        .position.v[1] = (sin(.rotation) / 2.0f + 0.5) / 10.0f
    }

    Box3 getHitbox() {
        vec4 dim = vec4(0.5, 0.5, 0.5, 0)
        return Box3(.position, dim)
    }

    GLMesh getMesh() return mesh
    GLTexture getTexture() return texture
}

void initCliffbars() {
    for(int i = 0; i < 2; i++) {
        (Entity.add(new Cliffbar()))
    }
}
