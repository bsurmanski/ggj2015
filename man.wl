import "gl.wl"
import "entity.wl"
import "fmt/tga.wl"
import "fmt/mdl.wl"
import "mesh.wl"
import "image.wl"
import "file.wl"
import "vec.wl"

use "importc"
import(C) "math.h"

class DuckMan : Entity {
    static GLMesh mesh
    static GLTexture texture
    float bounce
    bool moved

    this() {
        Image img = loadTGA(new StringFile(pack "res/pillduck.tga"))
        .texture = new GLTexture(img)
        Mesh m = loadMdl(new StringFile(pack "res/pillduck.mdl"))
        .mesh = new GLMesh(m)

        .position = vec4(0, 0, -5, 1)
    }

    void update(float dt) {
        float targety = 0.0f
        if(.moved) {
            targety = fabsf(sin(dt * 10.0f)) / 4.0f
        }
        .position.v[1] = (.position.v[1] + (targety - .position.v[1]) * 0.6f)
        .moved = false
    }

    void rotate(float f) {
        .rotation += f
    }

    void step() {
        vec4 axis = vec4(0, 1, 0, 0)
        vec4 dv = vec4(0, 0, -0.08, 0)
        mat4 matrix = mat4()
        matrix = matrix.rotate(.rotation, axis)
        dv = matrix.vmul(dv)

        .position = .position.add(dv)
        .moved = true
    }

    void draw() {
        GLDrawDevice dev = GLDrawDevice.getInstance()

        mat4 mat = mat4()
        vec4 axis = vec4(0, 1, 0, 0)
        mat = mat.rotate(.rotation, axis)
        mat = mat.translate(.position)

        dev.runSimpleProgram(.mesh, .texture, mat)
    }
}
