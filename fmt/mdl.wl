import "file.wl"
import "mesh.wl"

struct MdlHeader {
    uint8[3] magic
    uint8 version
    uint32 nverts
    uint32 nfaces
    uint8 nbones
    uint8[16] name
    uint8[3] padding
}

undecorated int printf(char^ fmt, ...);

Mesh loadMdl(InputInterface file) {
    MdlHeader head
    file.read(&head, MdlHeader.sizeof, 1)

    if(head.magic[0] != 'M' or 
       head.magic[1] != 'D' or
       head.magic[2] != 'L') {
        printf("ERROR: invalid MDL file format\n")
    }

    Mesh mesh = new Mesh
    mesh.verts = new MeshVertex[head.nverts]
    mesh.faces = new MeshFace[head.nfaces]
    file.read(mesh.verts.ptr, MeshVertex.sizeof, head.nverts)
    file.read(mesh.faces.ptr, MeshFace.sizeof, head.nfaces)

    return mesh
}
