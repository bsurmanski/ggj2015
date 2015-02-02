undecorated void^ memcpy(void^ dst, void^ src, long n);

class Image {
    uint32^ pixels;
    int32 w;
    int32 h;

    this(int w, int h) {
        .pixels = new uint32[w * h]
        .w = w
        .h = h
    }

    this(uint8^ pxl, int w, int h, int depth) {
        .pixels = new uint32[w * h]

        if(depth == uint32.sizeof) {
            undecorated int printf(char^ fmt, ...);
            memcpy(.pixels, pxl, w * h * uint32.sizeof)
        } else {
            for(int i = 0; i < w * h; i++) {
                .pixels[i] = 0
                memcpy(&.pixels[i], &pxl[i * depth], depth)
            }
        }

        .w = w
        .h = h
    }

    ~this() {
        delete .pixels
    }

    int width()  return .w
    int height()  return .h
    uint32^ pixelRef(int x, int y) return &.pixels[x + y * .w]
    int getPixel(int x, int y) return .pixels[x + y * .w]
    void setPixel(int x, int y, uint32 val) .pixels[x + y * .w] = val
}
