import "gl.wl"
import "fmt/tga.wl"
import "image.wl"
import "file.wl"
import "vec.wl"

import "cookie.wl"

use "importc"
import(C) "GL/gl.h"

class Title {
    GLTexture titleName
    Cookie cookie
    this() {
        Image i = loadTGA(new StringFile(pack "res/title.tga"))
        .titleName = new GLTexture(i)
        .cookie = new Cookie()
    }

    void update(float dt) {
        .cookie.update(dt)
    }

    void draw() {
        GLDrawDevice dev = GLDrawDevice.getInstance()
        dev.runTitleProgram(dev.getQuad(), .titleName, mat4())
        glClear(GL_DEPTH_BUFFER_BIT)
        mat4 view = mat4()
        view = view.translate(vec4(0, 0, -5, 0))
        .cookie.draw(view)
    }

}
