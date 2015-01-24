use "importc"
import(C) "math.h"

undecorated int printf(char^ fmt, ...);

struct vec4 {
    float[4] v

    this(float x, float y, float z, float w) {
        .v = [x, y, z, w]
    }

    /*
    this(vec4 o) {
        .v = [o.x(), o.y(), o.z(), o.w()]
    }*/

    float get(int i) return .v[i]
    void set(int i, float val) .v[i] = val
    float x() return .v[0]
    float y() return .v[1]
    float z() return .v[2]
    float w() return .v[3]

    float dot(vec4 o) return .v[0] * o.v[0] + .v[1] * o.v[1] + .v[2] * o.v[2] + .v[3] * o.v[3]
    vec4 add(vec4 o) return vec4(.v[0] + o.v[0], .v[1] + o.v[1], .v[2] + o.v[2], .v[3] + o.v[3]);
    vec4 sub(vec4 o) return vec4(.v[0] - o.v[0], .v[1] - o.v[1], .v[2] - o.v[2], .v[3] - o.v[3]);
    vec4 mul(float f) return vec4(.v[0] * f, .v[1] * f, .v[2] * f, .v[3] * f);
    vec4 div(float f) return vec4(.v[0] / f, .v[1] / f, .v[2] / f, .v[3] / f);
    float lensq() return .v[0] * .v[0] + .v[1] * .v[1] + .v[2] * .v[2] + .v[3] * .v[3]
    float len() return sqrt(.lensq())
    vec4 normalized() return .div(.len())

    vec4 cross(vec4 o) {
        vec4 ret;
        ret.v[0] = .y() * o.z() - .z() * o.y()
        ret.v[1] = .z() * o.x() - .x() * o.z()
        ret.v[2] = .x() * o.y() - .y() * o.x()
        ret.v[3] = 0
        return ret
    }

    vec4 proj(vec4 o) {
        float numer = .dot(o)
        float denom = o.dot(o)
        return .mul(numer / denom)
    }

    vec4 orth(vec4 o) {
        vec4 r = .proj(o)
        return .sub(r)
    }

    float^ ptr() {
        return .v.ptr
    }

    void print() {
        printf("%f %f %f %f\n", .v[0], .v[1], .v[2], .v[3])
    }
}

// row major matrix
struct mat4 {
    float[16] v

    this() {
        .v[0] = 1
        .v[1] = 0
        .v[2] = 0
        .v[3] = 0

        .v[4] = 0
        .v[5] = 1
        .v[6] = 0
        .v[7] = 0

        .v[8] = 0
        .v[9] = 0
        .v[10] = 1
        .v[11] = 0

        .v[12] = 0
        .v[13] = 0
        .v[14] = 0
        .v[15] = 1
    }

    float^ ptr() return .v.ptr

    float get(int i, int j) return .v[i+j*4]
    void set(int i, int j, float val) .v[i+j*4] = val

    mat4 mul(mat4 o) {
        mat4 ret
        for(int j = 0; j < 4; j++) {
            for(int i = 0; i < 4; i++) {
                ret.v[j*4+i] = 0.0f
                for(int k = 0; k < 4; k++) {
                    ret.v[j*4+i] += .v[j*4+k] * o.v[k*4+i]
                }
            }
        }
        return ret
    }

    vec4 vmul(vec4 o) {
        vec4 ret
        for(int j = 0; j < 4; j++) {
            ret.v[j] = 0.0f
            for(int i = 0; i < 4; i++) {
                ret.v[j] += .get(i, j) * o.get(i)
            }
        }
        return ret
    }

    mat4 translate(vec4 o) {
        mat4 m = mat4()
        m.set(3,0, o.get(0))
        m.set(3,1, o.get(1))
        m.set(3,2, o.get(2))
        return m.mul(^this)
    }

    mat4 rotate(float angle, vec4 r) {
        mat4 m
        r = r.normalized()
        float c
        float s
        float t
        s = sinf(angle)
        c = cosf(angle)
        t = 1.0f - c

        m.v[0] = t * r.v[0] * r.v[0] + c
        m.v[1] = t * r.v[0] * r.v[1] - s * r.v[2]
        m.v[2] = t * r.v[0] * r.v[2] + s * r.v[1]

        m.v[3] = 0.0f

        m.v[4] = t * r.v[0] * r.v[1] + s * r.v[2]
        m.v[5] = t * r.v[1] * r.v[1] + c
        m.v[6] = t * r.v[1] * r.v[2] - s * r.v[0]

        m.v[7] = 0.0f

        m.v[8]  = t * r.v[0] * r.v[2] - s * r.v[1]
        m.v[9]  = t * r.v[1] * r.v[2] + s * r.v[0]
        m.v[10] = t * r.v[2] * r.v[2] + c

        m.v[11] = 0.0f

        m.v[12] = 0.0f
        m.v[13] = 0.0f
        m.v[14] = 0.0f

        m.v[15] = 1.0f

        return m.mul(^this)
    }

    mat4 scale(float x, float y, float z) {
        mat4 m = mat4()
        m.v[0] = x
        m.v[5] = y
        m.v[10] = z
        return m.mul(^this)
    }

    void print() {
        for(int i = 0; i < 16; i++) {
            printf("%f ", .v[i])
            if((i+1) % 4 == 0) printf("\n")
        }
    }
}

mat4 getFrustumMatrix(float l, float r, float b, float t, float n, float f) {
    mat4 m
    m.v[0] = 2.0f * n / (r - l)
    m.v[1] = 0.0f
    m.v[2] = (r + l) / (r - l)
    m.v[3] = 0.0f

    m.v[4] = 0.0f
    m.v[5] = (2.0f * n) / (t - b)
    m.v[6] = (t + b) / (t - b)
    m.v[7] = 0.0f

    m.v[8]  = 0.0f
    m.v[9]  = 0.0f
    m.v[10] = -(f + n) / (f - n)
    m.v[11] = -(2.0f * f * n) / (f - n)

    m.v[12] = 0.0f
    m.v[13] = 0.0f
    m.v[14] = -1.0f
    m.v[15] = 0.0f

    return m
}
