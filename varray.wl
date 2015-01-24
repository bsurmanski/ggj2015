use "importc"

import(C) "stdlib.h"
import(C) "string.h"
import(C) "math.h"

class VArray {
    void^ data 
    long len 
    long max
    long elemsz 

    this(long elemsz) {
        .len = 0
        .max = 10
        .elemsz = elemsz
        .data = malloc(.max * .elemsz)
    }

    ~this() {
        free(.data)
    }

    bool empty() {
        return .len <= 0
    }

    long length() {
        return .len
    }

    void^ ptr() {
        return .data
    }

    void resize(int n) {
        .max = n
        .data = realloc(.data, .max * .elemsz)

        //XXX any items after .max will be lost
        if(.len > .max) .len = .max
    }

    int append(void^ elem) {
        memcpy(&.data[.len * .elemsz], elem, .elemsz)
    }

    void^ get(int i) {
        return &.data[i * .elemsz]
    }

    void swap(int i, int j) {
    }

    //void remove(int i, void function(void^ v) finalizer) {
    //}
}
