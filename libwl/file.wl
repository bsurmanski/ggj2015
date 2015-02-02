use "importc"

import(C) "stdio.h"
import(C) "string.h"

interface InputInterface {
    long size();
    int seek(long sval);
    int set(long sval);
    int rset(long sval);
    long tell();
    int get();
    int peek();
    void dropline();
    long read(void^ buf, long sz, long nmem);
    bool eof();
}

int ignore(InputInterface input) {
    input.get()
    return input.peek()
}

bool isalpha(int c) {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')
}

bool isdigit(int c) {
    return c >= '0' and c <= '9'
}

double readDouble(InputInterface input) {
    int c = 0
    double val = 0.0
    double frac = 0.0
    double fracExp = 1.0
    int sign = 1

    c = input.peek()

    // ignore whitespace
    while(c == ' ' or c == '\n' or c == '\r' or c == '\t') {
        c = input.ignore()
    }

    // read sign
    if(c == '+') {
        c = input.ignore()
    }
    else if(c == '-') {
        sign = -1
        c = input.ignore()
    }

    while(isdigit(c)) {
        val *= 10.0
        val += (c - '0')
        c = input.ignore()
    }

    if(c == '.') {
        c = input.ignore()
        while(isdigit(c)) {
            fracExp /= 10.0
            frac += (double: (c - '0')) * fracExp
            c = input.ignore()
        }
        val += frac
    }

    val = sign * val
    return val
}

long readLong(InputInterface input) {
    int c = 0
    long val = 0
    int sign = 1

    c = input.peek()

    // ignore whitespace
    while(c == ' ' or c == '\n' or c == '\r' or c == '\t') {
        c = input.ignore()
    }

    // read sign
    if(c == '+') {
        c = input.ignore()
    }
    else if(c == '-') {
        sign = -1
        c = input.ignore()
    }

    while(isdigit(c)) {
        val *= 10
        val += (c - '0')
        c = input.ignore()
    }

    return val
}

class File {
    FILE^ file
    long sz

    this(char^ filenm) {
        .file = fopen(filenm, "r")
        .sz = 0
    }

    ~this() {
        fclose(.file)
    }

    long size() {
        if(!.sz) {
            long sk = .tell()
            .rset(0)
            .sz = .tell()
            .set(sk)
        }
        return .sz
    }

    int flush() {
        return fflush(.file)
    }

    int seek(long sval) {
        return fseek(.file, SEEK_CUR, sval)
    }

    int set(long sval) {
        return fseek(.file, SEEK_SET, sval)
    }

    int rset(long sval) {
        return fseek(.file, SEEK_END, sval)
    }

    long tell() {
        return ftell(.file)
    }

    int get() {
        return getc(.file)
    }

    int peek() {
        int ret = .get()
        ungetc(ret, .file)
        return ret
    }

    void dropline() {
        while(!.eof() && .get() != '\n');
    }

    long read(void^ buf, long sz, long nmem) {
        return fread(buf, sz, nmem, .file)
    }

    bool eof() {
        return feof(.file)
    }
}

class StringFile {
    char^ str
    long len
    long index

    this(char^ str, int len) {
        .str = str
        .len = len
        .index = 0
    }

    this(char[] str) {
        .str = str.ptr
        .len = str.size
        .index = 0
    }

    long size() {
        return .len
    }

    int seek(long sval) {
        if(sval + .index < 0) return -1
        if(sval + .index > .len) return -1
        .index += sval
        return 0
    }

    int set(long sval) {
        if(sval < 0 || sval > .len) return -1
        .index = sval
        return 0
    }

    int rset(long sval) {
        .index = .len - sval - 1
        return 0
    }

    long tell() {
        return .index
    }

    int get() {
        if(.eof()) return -1
        int c = .str[.index]
        .index++
        return c
    }

    int peek() {
        if(.index >= .len) return -1
        return .str[.index]
    }

    void dropline() {
        while(!.eof() && .get() != '\n');
    }

    long read(void^ buf, long sz, long nmem) {
        long n = sz * nmem
        if(n > .len - .index) n = .len - .index
        memcpy(buf, &.str[.index], n)
        .index += n
        return n / sz
    }

    bool eof() {
        return .index >= .len
    }
}
