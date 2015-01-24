#version 130

smooth in vec2 texco;
uniform sampler2D tex;

uniform float tick;

void main(void) {
    gl_FragColor = texture2D(tex, vec2(texco.x + sin(tick*20 + texco.y*20)/40, texco.y));
}
