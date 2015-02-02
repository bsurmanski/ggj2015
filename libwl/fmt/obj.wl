import "file.wl"
import "mesh.wl"

struct ObjPosition {
    float[3] v
    this(float a, float b, float c) {
        .v[0] = a
        .v[1] = b
        .v[2] = c
    }
}

struct ObjUv {
    float[2] v
    this(float a, float b) {
        .v[0] = a
        .v[1] = b
    }
}

struct ObjNormal {
    float[3] v
    this(float a, float b, float c) {
        .v[0] = a
        .v[1] = b
        .v[2] = c
    }
}

struct ObjFace {
    uint16[3] vert
    uint16[3] normal
    uint16[3] uv
    this(uint16[3] v, uint16[3] n, uint16[3] u) {
        .vert = v
        .normal = n
        .uv = u
    }
}

class ObjMesh {
    ObjPosition[] positions
    ObjNormal[] normals
    ObjUv[] uvs
    ObjFace[] faces
}

void countMembers(InputInterface file, int^ nv, int^ nn, int^ nu, int^ nf) {
    while(!file.eof()) {
        int c = file.peek()
        if(c == 'v') {
            file.get()
            c = file.peek()
            if(c == 't') {
                (^nu)++
            } else if(c == 'n') {
                (^nn)++
            } else {
                (^nv)++
            }
        } else if(c == 'f') {
            (^nf)++
        } else if(c == '\n' || c == '\r') {
            file.get()
        }
        file.dropline()
    }

    file.set(0)
}

// load an .obj file format mesh.
// assumes that the .obj file has verts, normals, uvs
// and that all faces are triangulated
Mesh loadObj(InputInterface file) {
    int nverts = 0
    int nnorms = 0
    int nuvs = 0
    int nfaces = 0
    countMembers(file, &nverts, &nnorms, &nuvs, &nfaces)
    ObjMesh mesh = new ObjMesh
    mesh.positions = new ObjPosition[nverts]
    mesh.normals = new ObjNormal[nnorms]
    mesh.uvs = new ObjUv[nuvs]
    mesh.faces = new ObjFace[nfaces]

    nverts = 0
    nnorms = 0
    nuvs = 0
    nfaces = 0


    while(!file.eof()) {
        int c = file.peek()
        if(c == 'v') {
            file.get()
            c = file.peek()
            if(c == 't') {
                file.ignore()
                double x = file.readDouble()
                double y = file.readDouble()
                mesh.uvs[nuvs] = ObjUv(x, y)
                nuvs++
            } else if( c == 'n') {
                file.ignore()
                double x = file.readDouble()
                double y = file.readDouble()
                double z = file.readDouble()
                mesh.normals[nnorms] = ObjNormal(x, y, z)
                nnorms++
            } else {
                double x = file.readDouble()
                double y = file.readDouble()
                double z = file.readDouble()
                mesh.positions[nverts] = ObjPosition(x, y, z)
                nverts++
            }
        } else if(c == 'f') {
            uint16[3] vi
            uint16[3] ni
            uint16[3] ui
            for(int i = 0; i < 3; i++) {
                file.ignore()
                vi[i] = file.readLong()
                file.ignore()
                ni[i] = file.readLong()
                file.ignore()
                ui[i] = file.readLong()
            }
            mesh.faces[nfaces] = ObjFace(vi, ni, ui)
            nfaces++
        } else {
            file.dropline()
        }
    }

    //TODO
    return null 
}
