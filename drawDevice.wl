use "importc"
import(C) "port.h"
import "gl.wl"
import "vec.wl"
import "mesh.wl"
import "fmt/mdl.wl"
import "file.wl"

class GLDrawDevice {

    static GLMesh quad
    static GLDrawDevice instance

    int w
    int h
    float tick
    bool crazy
    bool boring

    GLFramebuffer mainBuffer 
    GLTexture colorTexture
    GLTexture normalTexture
    GLTexture depthTexture

    static GLDrawDevice getInstance() {
        return instance
    }

    this(int w, int h) {
        GLPinit();

        if(!instance) instance = this

        if(!.quad) {
            Mesh mesh = loadMdl(new StringFile(pack "res/quad2.mdl"))
            .quad = new GLMesh(mesh)
        }

        .w = w
        .h = h

        .mainBuffer = new GLFramebuffer()
        .colorTexture = GLTexture.create(w/4, h/4, 0) // 0 = RGBA8
        .normalTexture = GLTexture.create(w/4, h/4, 0) // 0 = RGBA8
        .depthTexture = GLTexture.create(w/4, h/4, 3) // 3 = DEPTH
        .mainBuffer.addTarget(.colorTexture)
        .mainBuffer.addTarget(.normalTexture)
        .mainBuffer.addTarget(.depthTexture)

        GLPFrontFace(GL_CW)

        GLPClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        GLPEnable(GL_TEXTURE_2D)
        GLPDisable(GL_BLEND)
        //GLPEnable(GL_CULL_FACE)
        GLPEnable(GL_DEPTH_TEST)
        GLPDisable(GL_SCISSOR_TEST)

    }

    void cullFaces(bool b) {
        if(b) GLPEnable(GL_CULL_FACE)
        else GLPDisable(GL_CULL_FACE)
    }

    GLMesh getQuad() return .quad

    void update(float dt) {
        .tick += dt
    }

    void bindStandardAttributes(GLProgram program) {
        GLint pos = GLPGetAttribLocation(program.program, "position")
        GLint norm = GLPGetAttribLocation(program.program, "normal")
        GLint uv = GLPGetAttribLocation(program.program, "uv")
        if(pos >= 0) {
            GLPEnableVertexAttribArray(pos)
            GLPVertexAttribPointer(pos, 3, GL_FLOAT, GL_FALSE, 32, null)
        }

        if(norm >= 0) {
            GLPEnableVertexAttribArray(norm)
            GLPVertexAttribPointer(norm, 3, GL_SHORT, GL_TRUE, 32, void^: 12)
        }

        if(uv >= 0) {
            GLPEnableVertexAttribArray(uv)
            GLPVertexAttribPointer(uv, 2, GL_UNSIGNED_SHORT, GL_TRUE, 32, void^: 18)
        }
    }

    void runMeshProgram(GLMesh mesh, GLTexture tex, mat4 matrix) {
        static GLProgram program 

        .mainBuffer.bind()
        GLPViewport(0, 0, .w/4, .h/4)

        if(!program) {
            program = new GLProgram(pack "glsl/mesh.vs", pack "glsl/mesh.fs")
        }

        program.bind()
        mesh.bind()
        if(tex) tex.bind()

        .bindStandardAttributes(program)

        GLPUniform1i(GLPGetUniformLocation(program.program, "t_color"), 0)

        mat4 persp = getFrustumMatrix(-1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 10000)
        mat4 matrix = persp.mul(matrix)

        GLPUniformMatrix4fv(GLPGetUniformLocation(program.program, "matrix"), 1, GL_TRUE, matrix.ptr())

        mesh.draw()
    }

    void runSimpleProgram(GLMesh mesh, GLTexture tex, mat4 mat) {
        GLPBindFramebuffer(GL_FRAMEBUFFER, 0)
        GLPViewport(0, 0, .w, .h)
        static GLProgram program

        if(!program) {
            program = new GLProgram(pack "glsl/simple.vs", pack "glsl/simple.fs")
        }

        program.bind()
        mesh.bind()

        if(tex) tex.bind()
        
        .bindStandardAttributes(program)

        GLPUniform1i(GLPGetUniformLocation(program.program, "tex"), 0)
        GLPUniform1i(GLPGetUniformLocation(program.program, "crazy"), .crazy)
        GLPUniform1i(GLPGetUniformLocation(program.program, "boring"), .boring)

        mat4 persp = getFrustumMatrix(-1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 10000)
        mat4 matrix = persp.mul(mat)

        GLPUniformMatrix4fv(GLPGetUniformLocation(program.program, "matrix"), 1, GL_TRUE, matrix.ptr())
        GLPUniform1f(GLPGetUniformLocation(program.program, "tick"), .tick)

        mesh.draw()
    }

    void runTitleProgram(GLMesh mesh, GLTexture tex, mat4 mat) {
        .mainBuffer.bind()
        GLPViewport(0, 0, .w/4, .h/4)
        static GLProgram program

        if(!program) {
            program = new GLProgram(pack "glsl/title.vs", pack "glsl/title.fs")
        }


        program.bind()
        mesh.bind()

        if(tex) tex.bind()
        
        .bindStandardAttributes(program)

        GLPUniform1i(GLPGetUniformLocation(program.program, "tex"), 0)
        GLPUniform1i(GLPGetUniformLocation(program.program, "crazy"), .crazy)

        mat4 persp = getFrustumMatrix(-1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 10000)
        mat4 matrix = persp.mul(mat)

        GLPUniformMatrix4fv(GLPGetUniformLocation(program.program, "matrix"), 1, GL_TRUE, matrix.ptr())
        GLPUniform1f(GLPGetUniformLocation(program.program, "tick"), .tick)

        mesh.draw()
    }

    void drawQuad() {
        .runSimpleProgram(.quad, .colorTexture, mat4())
    }

    void clearBuffer() {
        static int err
        if(!err) {
            err = GLPGetError()
            if(err) printf("GLERROR: %d\n", err)
        }
        .mainBuffer.bind()
        GLPViewport(0, 0, .w/4, .h/4)
        GLPClear(GL_COLOR_BUFFER_BIT)
        GLPClear(GL_DEPTH_BUFFER_BIT)
    }

    void clear() {
        GLPBindFramebuffer(GL_FRAMEBUFFER, 0)
        GLPViewport(0, 0, .w, .h)
        GLPClear(GL_COLOR_BUFFER_BIT)
        GLPClear(GL_DEPTH_BUFFER_BIT)
    }
}
