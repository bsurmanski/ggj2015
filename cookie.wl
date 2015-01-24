import "gl.wl"
import "mesh.wl"
import "image.wl"
import "file.wl"
import "vec.wl"
import "fmt/mdl.wl"
import "fmt/tga.wl"
import "entity.wl"

class Cookie : Entity {
    static GLMesh mesh
    static GLTexture texture
    float tick

    this() {
        if(!.mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/cookie.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!.texture) {
            Image i = loadTGA(new StringFile(pack "res/cookie.tga"))
            .texture = new GLTexture(i)
        }
    }

    void update(float t) {
        .tick = t
    }

    void draw(mat4 view) {
        GLDrawDevice dev = GLDrawDevice.getInstance()
        mat4 mat = mat4()
        mat = mat.scale(2, 2, 2)
        mat = mat.rotate(0.71, vec4(1, 0, 0, 0))
        mat = mat.rotate(.tick * 2, vec4(0, 1, 0, 0))
        mat = view.mul(mat)
        dev.runMeshProgram(.mesh, .texture, mat)
    }
}
