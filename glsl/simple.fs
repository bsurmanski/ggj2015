#version 130

smooth in vec2 texco;
uniform sampler2D tex;

void main(void) {
    gl_FragColor = texture2D(tex, texco);
}
