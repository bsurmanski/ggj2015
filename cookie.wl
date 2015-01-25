import "gl.wl"
import "mesh.wl"
import "image.wl"
import "file.wl"
import "vec.wl"
import "fmt/mdl.wl"
import "fmt/tga.wl"
import "entity.wl"
import "collision.wl"
import "man.wl"

class Cookie : Entity {
    static GLMesh mesh
    static GLMesh monkey
    static GLTexture texture
    float tick
    bool dead

    bool isDead() return .dead
    bool areYouCookie() return true

    this() {
        if(!.mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/cookie.mdl"))
            .mesh = new GLMesh(m)

            m = loadMdl(new StringFile(pack "res/monkey.mdl"))
            .monkey = new GLMesh(m)
        }

        if(!.texture) {
            Image i = loadTGA(new StringFile(pack "res/cookie.tga"))
            .texture = new GLTexture(i)
        }
    }

    void update(float dt) {
        .tick += dt

        DuckMan d = DuckMan.getInstance()
        Box3 dhit = d.getHitbox()
        if(dhit.collides(.getHitbox())) {
            //WIN
            d.eat(this)
            .dead = true
        }
    }

    Box3 getHitbox() {
        return Box3(.position, vec4(0.25, 0.25, 0.25, 0))
    }

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()
        mat4 mat = mat4()
        mat = mat.scale(2, 2, 2)
        mat = mat.rotate(0.71, vec4(1, 0, 0, 0))
        mat = mat.rotate(.tick * 2, vec4(0, 1, 0, 0))
        mat = mat.translate(.position)
        mat = view.mul(mat)

        if(dev.crazy) {
            dev.runMeshProgram(.monkey, .texture, mat)
        } else {
            dev.runMeshProgram(.mesh, .texture, mat)
        }
    }
}
