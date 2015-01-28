use "importc"

import(C) "SDL/SDL.h"
import(C) "port.h"

import "vec.wl"
import "image.wl"
import "mesh.wl"
import "fmt/mdl.wl"
import "file.wl"
import "vec.wl"

class GLProgram {
    GLuint program
    GLuint vshader
    GLuint fshader

    this(char^ vsrc, char^ fsrc) {
        .program = GLPCreateProgram()
        .vshader = GLPCreateShader(GL_VERTEX_SHADER)
        .fshader = GLPCreateShader(GL_FRAGMENT_SHADER)
        GLPShaderSource(.vshader, 1, &vsrc, null)
        GLPShaderSource(.fshader, 1, &fsrc, null)
        GLPCompileShader(.vshader)
        GLPCompileShader(.fshader)

        int err
        char[512] buf
        GLPGetShaderiv(.vshader, GL_COMPILE_STATUS, &err)
        if(err != GL_TRUE) {
            GLPGetShaderInfoLog(.vshader, 512, null, buf.ptr)
            printf("VS ERR: %s\n", buf.ptr)
        }

        GLPGetShaderiv(.fshader, GL_COMPILE_STATUS, &err)
        if(err != GL_TRUE) {
            GLPGetShaderInfoLog(.fshader, 512, null, buf.ptr)
            printf("FS ERR: %s\n", buf.ptr)
        }

        GLPAttachShader(.program, .vshader)
        GLPAttachShader(.program, .fshader)
        GLPLinkProgram(.program)

        GLPGetProgramiv(.program, GL_LINK_STATUS, &err)
        if(err != GL_TRUE) {
            GLPGetProgramInfoLog(.program, 512, null, buf.ptr)
            printf("GLProgram Link Error: %s\n", buf.ptr)
        }
    }

    void bind() {
        GLPUseProgram(.program)
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
        GLPGenTextures(1, &.id)
        GLPBindTexture(GL_TEXTURE_2D, .id)
        .w = img.width()
        .h = img.height()
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
        GLPTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 
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
        GLPGenTextures(1, &tex.id)
        GLPBindTexture(GL_TEXTURE_2D, tex.id)
        tex.w = w
        tex.h = h
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
        GLPTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
        GLPTexImage2D(GL_TEXTURE_2D, 0, iformat, 
        w, h, 0, format, type, 
        null)
        return tex
    }

    void bind() {
        GLPBindTexture(GL_TEXTURE_2D, .id)
    }
}

class GLMesh {
    GLuint vbuffer
    GLuint ibuffer
    uint nelems

    this(Mesh mesh) {
        GLPGenBuffers(1, &.vbuffer)
        GLPGenBuffers(1, &.ibuffer)
        GLPBindBuffer(GL_ARRAY_BUFFER, .vbuffer)

        GLPBufferData(GL_ARRAY_BUFFER, 
            MeshVertex.sizeof * mesh.verts.size,
            mesh.verts.ptr, 
            GL_STATIC_DRAW)

        GLPBindBuffer(GL_ELEMENT_ARRAY_BUFFER, .ibuffer)

        GLPBufferData(GL_ELEMENT_ARRAY_BUFFER, 
            MeshFace.sizeof * mesh.faces.size,
            mesh.faces.ptr, 
            GL_STATIC_DRAW)

        .nelems = mesh.faces.size * 3
    }

    void bind() {
        GLPBindBuffer(GL_ARRAY_BUFFER, .vbuffer)
        GLPBindBuffer(GL_ELEMENT_ARRAY_BUFFER, .ibuffer)
    }

    void draw() {
        //GLPBindBuffer(GL_ARRAY_BUFFER, .vbuffer)
        //GLPBindBuffer(GL_ELEMENT_ARRAY_BUFFER, .ibuffer)
        GLPDrawElements(GL_TRIANGLES, .nelems, GL_UNSIGNED_SHORT, null)
    }
}

class GLFramebuffer {
    GLuint id
    int ntargets

    uint[10] TARGETS 

    this() {
        GLPGenFramebuffers(1, &.id)
        .ntargets = 0

        for(int i = 0; i < 10; i++) {
            .TARGETS[i] = GL_COLOR_ATTACHMENT0 + i
        }
    }

    void bind() {
        GLPBindFramebuffer(GL_FRAMEBUFFER, .id)
        GLPDrawBuffers(.ntargets, .TARGETS.ptr)
    }

    void addTarget(GLTexture t) {
        GLPBindFramebuffer(GL_FRAMEBUFFER, .id)

        if(t.kind == 0 or t.kind == 1 or t.kind == 2) {
            GLPFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + .ntargets,
                GL_TEXTURE_2D, t.id, null)
            .ntargets++
        } else if(t.kind == 3) {
            GLPFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                GL_TEXTURE_2D, t.id, null)
        } else if(t.kind == 4) {
            GLPFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT,
                GL_TEXTURE_2D, t.id, null)
        }
    }
}
