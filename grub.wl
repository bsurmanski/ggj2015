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

class Grub : Entity {
    static const int STATE_ROTATE = 0
    static const int STATE_MOVE = 1
    static GLMesh mesh
    static GLTexture texture
    float timer
    int state

    static Grub first
    Grub prev
    Grub next

    this() {
        if(!mesh) {
            Mesh m = loadMdl(new StringFile(pack "res/grub.mdl"))
            .mesh = new GLMesh(m)
        }

        if(!texture) {
            Image i = loadTGA(new StringFile(pack "res/grub.tga"))
            .texture = new GLTexture(i)
        }
        .rotation = randomFloat() * 6 // 6 = 2PI (close enough)
    }

    void update(float dt) {
        .timer -= dt
        if(.timer <= 0) {
            .state = !.state //swap tween rotate/move
            .timer = randomFloat() * 3
        }
        
        if(.state == 0) {
            .rotation += 0.333
        } else if(.state == 1) {
            vec4 dv = vec4(0, 0, -0.25, 0)

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
        } else {
            .state = 0
        }
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

void initGrubs() {
    Grub g = Grub.first = new Grub()

    for(int i = 1; i < 5; i++) {
        g.next = new Grub()
        g.next.prev = g
        g = g.next
    }
}

void drawGrubs(mat4 view) {
    Grub g = Grub.first
    while(g) {
        g.draw(view)
        g = g.next
    }
}

void updateGrubs(float dt) {
    Grub g = Grub.first
    while(g) {
        g.update(dt)
        g = g.next
    }
}
