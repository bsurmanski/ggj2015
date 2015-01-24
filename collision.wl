import "vec.wl"

undecorated float fabsf(float x);

float box_dim_mtd(float apos, float adim, float bpos, float bdim) {
    float d1 = apos - (bpos + bdim / 2.0f) //dist of A's left point to B center
    float d2 = (apos + adim) - (bpos + bdim / 2.0f) // dist of A's right point to B center
    if(fabsf(d1) > fabsf(d2)) {
        return (bpos + bdim) - apos
    }
    //else
    return bpos - (apos + adim)
}

float box_dim_overlap(float apos, float adim, float bpos, float bdim) {
    return ((apos + adim > bpos) and (apos + adim < bpos + bdim)) or
           ((bpos + bdim > apos) and (bpos + bdim < apos + adim))
        
}

struct Box2 {
    float[2] pos
    float[2] dim

    this(float[2] p, float[2] d) {
        .pos = p
        .dim = d
    }

    this(vec4 p, vec4 d) {
        .pos[0] = p.v[0]
        .pos[1] = p.v[1]

        .dim[0] = d.v[0]
        .dim[1] = d.v[1]
    }

    void setPosition(float[2] p) {
        .pos = p
    }

    void setDimension(float[2] d) {
        .dim = d
    }

    void setCenter(float[2] c) {
        for(int i = 0; i < 2; i++) {
            .pos[i] = c[i] - .dim[i] / 2.0f
        }
    }

    void move(float[2] dv) {
        for(int i = 0; i < 2; i++) {
            .pos[i] += dv[i]
        }
    }

    bool collides(Box2 o) {
        for(int i = 0; i < 2; i++) {
            if(!box_dim_overlap(.pos[i], .dim[i], o.pos[i], o.dim[i]))
                return false
        }

        // all dimensions overlap, therefore, they collide
        return true
    }

    float[2] minTranslation(Box2 o) {
        float[2] ret
        for(int i = 0; i < 2; i++) {
            ret[i] = box_dim_mtd(.pos[i], .dim[i], o.pos[i], o.dim[i])
        }
        return ret
    }
}

struct Box3 {
    float[3] pos
    float[3] dim

    this(float[3] p, float[3] d) {
        .pos = p
        .dim = d
    }

    this(vec4 p, vec4 d) {
        .pos[0] = p.v[0]
        .pos[1] = p.v[1]
        .pos[2] = p.v[2]

        .dim[0] = d.v[0]
        .dim[1] = d.v[1]
        .dim[2] = d.v[2]
    }

    void setPosition(float[3] p) {
        .pos = p
    }

    void setDimension(float[3] d) {
        .dim = d
    }

    void setCenter(float[3] c) {
        for(int i = 0; i < 3; i++) {
            .pos[i] = c[i] - .dim[i] / 3.0f
        }
    }

    void move(float[3] dv) {
        for(int i = 0; i < 3; i++) {
            .pos[i] += dv[i]
        }
    }

    bool collides(Box3 o) {
        for(int i = 0; i < 3; i++) {
            if(!box_dim_overlap(.pos[i], .dim[i], o.pos[i], o.dim[i]))
                return false
        }

        // all dimensions overlap, therefore, they collide
        return true
    }

    float[3] minTranslation(Box3 o) {
        float[3] ret
        for(int i = 0; i < 3; i++) {
            ret[i] = box_dim_mtd(.pos[i], .dim[i], o.pos[i], o.dim[i])
        }
        return ret
    }
}

struct Ball2 {
    float[2] center
    float radius

    this(float[2] c, float r) {
        .center = c
        .radius = r
    }

    bool collides(Ball2 o) {
        vec4 c1 = vec4(.center[0], .center[1], 0, 0)        
        vec4 c2 = vec4(o.center[0], o.center[2], 0, 0)
        vec4 diff = c1.sub(c2)
        float rdsq = (.radius + o.radius) * (.radius + o.radius)
        return rdsq > diff.lensq()
    }

    void scale(float f) {
        .radius *= f
    }

    void setCenter(float[2] c) {
        .center = c
    }

    void setRadius(float r) {
        .radius = r
    }
}

struct Ball3 {
    float[3] center
    float radius

    this(float[3] c, float r) {
        .center = c
        .radius = r
    }

    bool collides(Ball3 o) {
        vec4 c1 = vec4(.center[0], .center[1], .center[2], 0)        
        vec4 c2 = vec4(o.center[0], o.center[2], o.center[3], 0)
        vec4 diff = c1.sub(c2)
        float rdsq = (.radius + o.radius) * (.radius + o.radius)
        return rdsq > diff.lensq()
    }

    void scale(float f) {
        .radius *= f
    }

    void setCenter(float[3] c) {
        .center = c
    }

    void setRadius(float r) {
        .radius = r
    }
}
