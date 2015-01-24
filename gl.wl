use "importc"

import(C) "SDL/SDL.h"
import(C) "GL/gl.h"

import "vec.wl"
import "image.wl"
import "mesh.wl"
import "fmt/mdl.wl"
import "file.wl"
import "vec.wl"

char[] vsrc_deferred = pack "glsl/deferred.vs"
char[] fsrc_deferred = pack "glsl/deferred.fs"


class GLProgram {
    GLuint program
    GLuint vshader
    GLuint fshader

    this(char^ vsrc, char^ fsrc) {
        .program = glCreateProgram()
        .vshader = glCreateShader(GL_VERTEX_SHADER)
        .fshader = glCreateShader(GL_FRAGMENT_SHADER)
        glShaderSource(.vshader, 1, &vsrc, null)
        glShaderSource(.fshader, 1, &fsrc, null)
        glCompileShader(.vshader)
        glCompileShader(.fshader)

        int err
        char[512] buf
        glGetShaderiv(.vshader, GL_COMPILE_STATUS, &err)
        if(err != GL_TRUE) {
            glGetShaderInfoLog(.vshader, 512, null, buf.ptr)
            printf("VS ERR: %s\n", buf.ptr)
        }

        glGetShaderiv(.fshader, GL_COMPILE_STATUS, &err)
        if(err != GL_TRUE) {
            glGetShaderInfoLog(.fshader, 512, null, buf.ptr)
            printf("FS ERR: %s\n", buf.ptr)
        }

        glAttachShader(.program, .vshader)
        glAttachShader(.program, .fshader)
        glLinkProgram(.program)

        glGetProgramiv(.program, GL_LINK_STATUS, &err)
        if(err != GL_TRUE) {
            glGetProgramInfoLog(.program, 512, null, buf.ptr)
            printf("GLProgram Link Error: %s\n", buf.ptr)
        }
    }

    void bind() {
        glUseProgram(.program)
    }
}

class GLTexture {
    GLuint id
    int kind
    int w
    int h

    static int RGBA8 = 0
    static int RGBA8I = 1
    static int RGBA32F = 2
    static int DEPTH32 = 3
    static int DEPTHSTENCIL = 4

    this(Image img) {
        glGenTextures(1, &.id)
        glBindTexture(GL_TEXTURE_2D, .id)
        .w = img.width()
        .h = img.height()
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 
        img.width(), img.height(), 0, GL_BGRA, GL_UNSIGNED_BYTE, 
        img.pixels)
        .kind = RGBA8
    }

    // XXX workaround. function overloading on constructor not done yet
    static GLTexture create(int w, int h, int kind) {
        int format = GL_RGBA
        int type = GL_UNSIGNED_BYTE
        int iformat = GL_RGBA8
        if(kind == RGBA8I) {
            type = GL_BYTE
        } else if(kind == RGBA32F) {
            type = GL_FLOAT
        } else if(kind == DEPTH32) {
            type = GL_FLOAT
            format = GL_DEPTH_COMPONENT
            iformat = GL_DEPTH_COMPONENT32
        } else if(kind == DEPTHSTENCIL) {
            type = GL_FLOAT
            format = GL_DEPTH_STENCIL
            iformat = GL_DEPTH24_STENCIL8
        }

        GLTexture tex = new GLTexture
        tex.kind = kind
        glGenTextures(1, &tex.id)
        glBindTexture(GL_TEXTURE_2D, tex.id)
        tex.w = w
        tex.h = h
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
        glTexImage2D(GL_TEXTURE_2D, 0, iformat, 
        w, h, 0, format, type, 
        null)
        return tex
    }

    void bind() {
        glBindTexture(GL_TEXTURE_2D, .id)
    }
}

class GLMesh {
    GLuint vbuffer
    GLuint ibuffer
    uint nelems

    this(Mesh mesh) {
        glGenBuffers(1, &.vbuffer)
        glGenBuffers(1, &.ibuffer)
        glBindBuffer(GL_ARRAY_BUFFER, .vbuffer)

        glBufferData(GL_ARRAY_BUFFER, 
            MeshVertex.sizeof * mesh.verts.size,
            mesh.verts.ptr, 
            GL_STATIC_DRAW)

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, .ibuffer)

        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
            MeshFace.sizeof * mesh.faces.size,
            mesh.faces.ptr, 
            GL_STATIC_DRAW)

        .nelems = mesh.faces.size * 3
    }

    void bind() {
        glBindBuffer(GL_ARRAY_BUFFER, .vbuffer)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, .ibuffer)
    }

    void draw() {
        //glBindBuffer(GL_ARRAY_BUFFER, .vbuffer)
        //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, .ibuffer)
        glDrawElements(GL_TRIANGLES, .nelems, GL_UNSIGNED_SHORT, null)
    }
}

class GLFramebuffer {
    GLuint id
    int ntargets

    uint[10] TARGETS 

    this() {
        glGenFramebuffers(1, &.id)
        .ntargets = 0

        for(int i = 0; i < 10; i++) {
            .TARGETS[i] = GL_COLOR_ATTACHMENT0 + i
        }
    }

    void bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, .id)
        glDrawBuffers(.ntargets, .TARGETS.ptr)
    }

    void addTarget(GLTexture t) {
        glBindFramebuffer(GL_FRAMEBUFFER, .id)

        if(t.kind == 0 or t.kind == 1 or t.kind == 2) {
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + .ntargets,
                GL_TEXTURE_2D, t.id, null)
            .ntargets++
        } else if(t.kind == 3) {
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                GL_TEXTURE_2D, t.id, null)
        } else if(t.kind == 4) {
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT,
                GL_TEXTURE_2D, t.id, null)
        }
    }
}

class GLDrawDevice {

    static GLMesh quad
    static GLDrawDevice instance

    int w
    int h
    float tick
    
    GLFramebuffer mainBuffer 
    GLTexture colorTexture
    GLTexture normalTexture
    GLTexture depthTexture

    static GLDrawDevice getInstance() {
        return instance
    }

    this(int w, int h) {
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

        glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        glEnable(GL_TEXTURE_2D)
        glDisable(GL_BLEND)
        //glEnable(GL_CULL_FACE)
        glEnable(GL_DEPTH_TEST)
        glDisable(GL_SCISSOR_TEST)

    }

    GLMesh getQuad() return .quad

    void update(float dt) {
        .tick += dt
    }

    void bindStandardAttributes(GLProgram program) {
        GLint pos = glGetAttribLocation(program.program, "position")
        GLint norm = glGetAttribLocation(program.program, "normal")
        GLint uv = glGetAttribLocation(program.program, "uv")
        if(pos >= 0) {
            glEnableVertexAttribArray(pos)
            glVertexAttribPointer(pos, 3, GL_FLOAT, GL_FALSE, 32, null)
        }

        if(norm >= 0) {
            glEnableVertexAttribArray(norm)
            glVertexAttribPointer(norm, 3, GL_SHORT, GL_TRUE, 32, void^: 12)
        }

        if(uv >= 0) {
            glEnableVertexAttribArray(uv)
            glVertexAttribPointer(uv, 2, GL_UNSIGNED_SHORT, GL_TRUE, 32, void^: 18)
        }
    }

    void runMeshProgram(GLMesh mesh, GLTexture tex, mat4 matrix) {
        static GLProgram program 

        glViewport(0, 0, .w/4, .h/4)
        .mainBuffer.bind()

        if(!program) {
            program = new GLProgram(pack "glsl/mesh.vs", pack "glsl/mesh.fs")
        }

        program.bind()
        mesh.bind()
        if(tex) tex.bind()

        .bindStandardAttributes(program)

        glUniform1i(glGetUniformLocation(program.program, "t_color"), 0)

        mat4 persp = getFrustumMatrix(-1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 10000)
        mat4 matrix = persp.mul(matrix)

        glUniformMatrix4fv(glGetUniformLocation(program.program, "matrix"), 1, GL_TRUE, matrix.ptr())

        mesh.draw()
    }

    void runSimpleProgram(GLMesh mesh, GLTexture tex, mat4 mat) {
        glViewport(0, 0, .w, .h)
        static GLProgram program

        if(!program) {
            program = new GLProgram(pack "glsl/simple.vs", pack "glsl/simple.fs")
        }

        glBindFramebuffer(GL_FRAMEBUFFER, 0)

        program.bind()
        mesh.bind()

        if(tex) tex.bind()
        
        .bindStandardAttributes(program)

        glUniform1i(glGetUniformLocation(program.program, "tex"), 0)

        mat4 persp = getFrustumMatrix(-1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 10000)
        mat4 matrix = persp.mul(mat)

        glUniformMatrix4fv(glGetUniformLocation(program.program, "matrix"), 1, GL_TRUE, matrix.ptr())
        glUniform1f(glGetUniformLocation(program.program, "tick"), .tick)

        mesh.draw()
    }

    void drawQuad() {
        .runSimpleProgram(.quad, .colorTexture, mat4())
    }

    void clearBuffer() {
        .mainBuffer.bind()
        glClear(GL_COLOR_BUFFER_BIT)
        glClear(GL_DEPTH_BUFFER_BIT)
    }

    void clear() {
        glBindFramebuffer(GL_FRAMEBUFFER, 0)
        glClear(GL_COLOR_BUFFER_BIT)
        glClear(GL_DEPTH_BUFFER_BIT)
    }

    void clearDepth() {
        glClear(GL_DEPTH_BUFFER_BIT)
    }
}

class Model {
    GLMesh mesh
    GLTexture texture

    this(GLMesh m, GLTexture t) {
        .mesh = m
        .texture = t
    }

    void draw(GLDrawDevice dev, mat4 mat) {
        dev.runSimpleProgram(.mesh, .texture, mat)
    }
}
