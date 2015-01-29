#include "port.h"
#include <GL/gl.h>

void GLPinit() {
    glewInit();
}

void GLPViewport(int x, int y, int w, int h) {
    glViewport(x, y, w, h);
}

int GLPCreateProgram() {
    return glCreateProgram();
}

void GLPGetProgramInfoLog(int prg, int max, int *len, char *log) {
    glGetProgramInfoLog(prg, max, len, log);
}

int GLPCreateShader(int t) {
    return glCreateShader(t);
}

void GLPShaderSource(int sh, int c, const char **str, const int *len) {
    glShaderSource(sh, c, str, len);
}

void GLPCompileShader(int s) {
    glCompileShader(s);
}

void GLPGetShaderiv(int sh, int pnm, int *p) {
    glGetShaderiv(sh, pnm, p);
}

void GLPGetShaderInfoLog(int sh, int max, int *len, char *log) {
    glGetShaderInfoLog(sh, max, len, log);
}


void GLPAttachShader(int prog, int sdr) {
    glAttachShader(prog, sdr);
}

void GLPLinkProgram(int prog) {
    glLinkProgram(prog);
}

void GLPGetProgramiv(int prg, int pnm, int *prm) {
    glGetProgramiv(prg, pnm, prm);
}

void GLPUseProgram(int prg) {
    glUseProgram(prg);
}

void GLPGenTextures(int n, unsigned *t) {
    glGenTextures(n, t);
}

void GLPBindTexture(int targ, int tex) {
    glBindTexture(targ, tex);
}

void GLPTexParameteri(int targ, int pnm, int param) {
    glTexParameteri(targ, pnm, param);
}

void GLPTexImage2D(int targ, int lvl, int ifmt, int w, int h, int border, int format, int type, const void *data) {
    glTexImage2D(targ, lvl, ifmt, w, h, border, format, type, data);
}

void GLPGenBuffers(int n, unsigned *b) {
    glGenBuffers(n, b);
}

void GLPBindBuffer(int n, int b) {
    glBindBuffer(n, b);
}

void GLPBufferData(int t, int s, const void *d, int u) {
    glBufferData(t, s, d, u);
}

void GLPDrawElements(int m, int c, int t, const void *ind) {
    glDrawElements(m, c, t, ind);
}

void GLPGenFramebuffers(int n, unsigned *ids) {
    glGenFramebuffers(n, ids);
}

void GLPBindFramebuffer(int t, int fb) {
    glBindFramebuffer(t, fb);
}

void GLPDrawBuffers(int n, unsigned *buf) {
    glDrawBuffers(n, buf);
}

void GLPFramebufferTexture2D(int fb, int attach, int textarg, int tex, int lvl) {
    glFramebufferTexture2D(fb, attach, textarg, tex, lvl);
}

void GLPFrontFace(int m) {
    glFrontFace(m);
}

void GLPEnable(int n) {
    glEnable(n);
}

void GLPDisable(int n) {
    glDisable(n);
}

int GLPGetAttribLocation(int prg, const char *nm) {
    return glGetAttribLocation(prg, nm);
}

void GLPEnableVertexAttribArray(int i) {
    glEnableVertexAttribArray(i);
}

void GLPVertexAttribPointer(int i, int sz, int ty, int norm, int stride, const void *ptr) {
    glVertexAttribPointer(i, sz, ty, norm, stride, ptr);
}

void GLPUniform1i(int loc, int v) {
    glUniform1i(loc, v);
}

void GLPUniform1f(int loc, float v) {
    glUniform1f(loc, v);
}

void GLPUniformMatrix4fv(int loc, int cnt, int trans, const float *val) {
    glUniformMatrix4fv(loc, cnt, trans, val);
}

int GLPGetUniformLocation(int prg, const char *nm) {
    return glGetUniformLocation(prg, nm);
}

void GLPClear(int msk) {
    glClear(msk);
}


void GLPClearColor(float r, float g, float b, float a) {
    glClearColor(r, g, b, a);
}

int GLPGetError() {
    return glGetError();
}

void GLPPolygonMode(int f, int m) {
    glPolygonMode(f, m);
}
