import "libwl/file.wl"
import "libwl/vec.wl"
import "entity.wl"
import "mouse.wl"

class Scene {
    this() {
    }
}

struct SceneHeader {
    char[3] magic
    uint8 version
    uint16 nentities
    char[10] padding
    char[16] name
}

struct SceneEntity {
    uint16 pid
    char[2] padding1
    float[3] position
    float[3] scale
    float[4] rotation
    char[4] padding2
    char[16] name
}

undecorated int printf(char^ fmt, ...);
undecorated int strcmp(void^ v1, void^ v2);

Scene loadScene(InputInterface file) {
    SceneHeader head
    file.read(&head, SceneHeader.sizeof, 1)
    if( head.magic[0] != 'S' or
        head.magic[1] != 'C' or
        head.magic[2] != 'N') {
        printf("ERROR: invalid SCN file format\n")
    }

    Scene scene = new Scene()
    for(int i = 0; i < head.nentities; i++) {
        SceneEntity ent
        file.read(&ent, SceneEntity.sizeof, 1)
        if(!strcmp("Mouse".ptr, ent.name.ptr)) {
            Mouse m = new Mouse()
            m.position = vec4(ent.position[0], ent.position[1], ent.position[2], 0)
            Entity.add(m)
        } else if(!strcmp("Camera".ptr, ent.name.ptr)) {
            //printf("Camera FOUND\n")
        }
    }
    return scene
}
