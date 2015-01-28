import "file.wl"
import "image.wl"

const int CMAP_TRUE = 1
const int CMAP_FALSE = 0

const int ITYPE_NONE = 0
const int ITYPE_UCCM = 1
const int ITYPE_UCTC = 2
const int ITYPE_UCBW = 3
const int ITYPE_RLECM = 9
const int ITYPE_RLETC = 10
const int ITYPE_RLEBW = 11

const int DISCR_ALPHA_MASK = 0x0F
const int DISCR_DIREC_MASK = 0x40

const int RLE_REPEAT_MASK = 0x7f
const int RLE_FLAG_MASK = 0x80

struct TGAImageSpec {
    uint16 xorigin;
    uint16 yorigin;
    uint16 width;
    uint16 height;
    uint8 depth;
    uint8 descriptor;
}

struct TGAHeader {
    uint8 idlen;
    uint8 cmap;
    uint8 itype;
    uint8[5] cmap_spec;
    TGAImageSpec ispec;

    bool isValid() {
        if(.cmap != CMAP_TRUE && .cmap != CMAP_FALSE) return false
        if( .itype != ITYPE_NONE and
            .itype != ITYPE_UCCM and
            .itype != ITYPE_UCTC and
            .itype != ITYPE_UCBW and
            .itype != ITYPE_RLECM and
            .itype != ITYPE_RLETC and
            .itype != ITYPE_RLEBW) return false
        return true;
    }

    bool hasColorMap() {
        return .cmap == CMAP_TRUE
    }

    bool hasRLE() {
        return .itype >= 9 && .itype <= 11
    }

    int width() { 
        return .ispec.width
    }

    int height() {
        return .ispec.height
    }

    int pixelSize() {
        return .ispec.depth / 8;
    }

    int imageSize() {
        return .width() * .height() * .pixelSize()
    }
};

bool loadTGAHeader(InputInterface file, TGAHeader^ head) {
    file.read(head, TGAHeader.sizeof, 1)
    return head.isValid()
}

undecorated int printf(char^ fmt, ...);

Image loadTGA(InputInterface file) {
    TGAHeader head
    if(loadTGAHeader(file, &head)) {
        file.seek(head.idlen)
        if(head.hasColorMap()) {
            //ERROR
            printf("TGA: Color Map not yet supported\n")
            return null
        }

        uint8 nrepeat = 0
        uint8 rle_flag = 0
        int bpp = head.pixelSize()
        int sz = head.imageSize() //XXX error if inlined in new uint8[sz]
        uint8^ pixels = new uint8[sz]

        int pixelid = 0
        for(int j = 0; j < head.height(); j++) {
            for(int i = 0; i < head.width(); i++) {
                if(nrepeat == 0 && head.hasRLE()) {
                    uint8 rle_pkt;
                    file.read(&rle_pkt, 1, 1)
                    rle_flag = rle_pkt & RLE_FLAG_MASK
                    nrepeat = rle_pkt & RLE_REPEAT_MASK
                    file.read(&pixels[pixelid], head.pixelSize(), 1)
                    pixelid += bpp
                    continue
                }

                if(rle_flag) {
                    memcpy(&pixels[pixelid], &pixels[pixelid-bpp], bpp)
                } else {
                    file.read(&pixels[pixelid], head.pixelSize(), 1)
                }

                nrepeat--
                pixelid += bpp
            }
        }

        Image ret = new Image(pixels, head.width(), head.height(), head.pixelSize())
        delete pixels
        return ret
    }

    return null
}
