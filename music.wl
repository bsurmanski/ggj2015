use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_mixer.h"

import "random.wl"

Mix_Chunk^ boop1
Mix_Chunk^ boop2
Mix_Chunk^ boop3
Mix_Chunk^ boop4
Mix_Chunk^ boop5
Mix_Chunk^ bonk1 

Mix_Chunk^ Mix_LoadWAV(char ^filenm) {
    return Mix_LoadWAV_RW(SDL_RWFromFile(filenm, "rb"), 1)
}

void musicInit() {
    boop1 = Mix_LoadWAV("res/music/boop1.wav")
    boop2 = Mix_LoadWAV("res/music/boop2.wav")
    boop3 = Mix_LoadWAV("res/music/boop3.wav")
    boop4 = Mix_LoadWAV("res/music/boop4.wav")
    boop5 = Mix_LoadWAV("res/music/boop5.wav")
    bonk1 = Mix_LoadWAV("res/music/bonk1.wav")
}

void musicUpdate(float dt) {
    static int last
    static float musicTimer
    static int hitCount

    musicTimer -= dt
    if(musicTimer < 0) {
        hitCount++

        musicTimer = 0.5
        
        if(hitCount % 2) {
            Mix_PlayChannelTimed(-1, bonk1, 0, -1) 
        } else {
            int i = randomInt(5)
            if(i <= 0) {
                Mix_PlayChannelTimed(-1, boop1, 0, -1) 
            } else if(i <= 1) {
                Mix_PlayChannelTimed(-1, boop2, 0, -1) 
            } else if(i <= 2) {
                Mix_PlayChannelTimed(-1, boop3, 0, -1) 
            } else if(i <= 3) {
                Mix_PlayChannelTimed(-1, boop4, 0, -1) 
            } else if(i <= 4) {
                Mix_PlayChannelTimed(-1, boop5, 0, -1) 
            }
            last = i
        }
    }

}
