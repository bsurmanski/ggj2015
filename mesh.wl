struct MeshVertex {
    float[3] position
    int16[3] normal
    uint16[2] uv
    uint16 material
    uint8[2] boneid
    uint8[2] boneweight
    uint8[4] padding
}

struct MeshFace {
    uint16[3] vertexIds
}

class Mesh {
    MeshVertex[] verts
    MeshFace[] faces
}
