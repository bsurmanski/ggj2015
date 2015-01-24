import "gl.wl"
import "fmt/tga.wl"
import "image.wl"
import "file.wl"
import "vec.wl"

class Title {
    GLTexture titleName
    this() {
        Image i = loadTGA(new StringFile(pack "res/title.tga"))
        .titleName = new GLTexture(i)
    }

    void draw() {
        GLDrawDevice dev = GLDrawDevice.getInstance()
        dev.runSimpleProgram(dev.getQuad(), .titleName, mat4())
    }

}
