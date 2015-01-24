
undecorated float floorf(float f);

uint32 randomInt() {
    MersenneTwister MT = MersenneTwister.getInstance()
    return MT.getInt()
}

uint32 randomInt(uint max) {
    MersenneTwister MT = MersenneTwister.getInstance()
    return MT.getInt(max)
}

// float between [0, 1]
float randomFloat() {
    MersenneTwister MT = MersenneTwister.getInstance()
    return MT.getFloat()
}

float randomFloat(float min, float max) {
    MersenneTwister MT = MersenneTwister.getInstance()
    return MT.getFloat(min, max)
}

class MersenneTwister {
    static MersenneTwister instance

    static const int MT_LEN = 624
    static const int MT_GENPARAM = 397
    static const int MT_DEFAULTSEED = 5489
    static const int MT_INIT_CONST = 0x6c078965
    static const int MT_GENODDMASK = 0x9908b0df
    static const int MT_32BITMASK = 0xffffffff
    static const int MT_HIGHBIT = 0x80000000
    static const int MT_LOWBITS = 0x7fffffff
    static const int MT_TEMPERCONST1 = 0x9d2c5680
    static const int MT_TEMPERCONST2 = 0xefc60000

    uint32[MT_LEN] MT
    int index

    static MersenneTwister getInstance() {
        if(!instance) 
            instance = new MersenneTwister(MT_DEFAULTSEED)
        return instance
    }

    this(uint32 s) {
        .index = MT_LEN + 1
        .seed(s)
        .generateNewValues()
    }

    void seed(uint32 seed) {
        .MT[0] = seed
        for(int i = 1; i < MT_LEN; i++) {
            .MT[i] = (MT_INIT_CONST * (.MT[i - 1] ^ ((.MT[i - 1] >> 30) + i))) & MT_32BITMASK
        }
    }

    void generateNewValues() {
        static uint32[] GENMASK = [0, MT_GENODDMASK]

        uint32 y
        int i
        for(i = 0; i < MT_LEN - MT_GENPARAM; i++) {
            y = (.MT[i] & MT_HIGHBIT) | (.MT[i+1] & MT_LOWBITS)
            .MT[i] = .MT[i + MT_GENPARAM] ^ (y >> 1) ^ (GENMASK[y & 0x1])
        }

        for(; i < MT_LEN - 1; i++) {
            y = (.MT[i] & MT_HIGHBIT) | (.MT[i+1] & MT_LOWBITS)
            .MT[i] = .MT[i + MT_GENPARAM - MT_LEN] ^ (y >> 1) ^ (GENMASK[y & 0x1])
        }

        y = (.MT[MT_LEN - 1] & MT_HIGHBIT) | (.MT[0] & MT_LOWBITS)
        .MT[MT_LEN - 1] = .MT[MT_GENPARAM - 1] ^ (y >> 1) ^ (GENMASK[y & 0x1])
        .index = 0
    }


    uint32 getInt() {
        if(.index >= MT_LEN) {
            .generateNewValues()
        }
        uint32 y = .MT[.index]
        .index++
        y ^= (y >> 11)
        y ^= (y << 7) & MT_TEMPERCONST1
        y ^= (y << 15) & MT_TEMPERCONST2
        y ^= (y >> 18)
        return y
    }

    uint32 getInt(uint max) {
        return floorf(.getFloat() * max)
    }

    // float between [0, 1]
    float getFloat() {
        return float: .getInt() * (1.0f / float: long: 0xffffffff)
    }

    float getFloat(float min, float max) {
        return min + (max - min) * .getFloat()
    }
}

