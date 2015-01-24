#version 130

smooth in vec2 texco;
uniform sampler2D tex;

uniform float tick;

void main(void) {
    gl_FragColor = texture2D(tex, 
        vec2(texco.x + (-pow(texco.x*2-1,10)+1) * sin(tick*20 + texco.y*20)/100, texco.y));
}
