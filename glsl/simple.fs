#version 130

smooth in vec2 texco;
uniform sampler2D tex;

uniform bool crazy;
uniform bool boring;
uniform float tick;

void main(void) {
    float PI = 3.14159265358979323846264;
    vec4 color = vec4(1);

    // used in place of 'pow' function, since it is undefined if x < 0
    // I am doing this so then the screen wavy stops at the edge of the screen.
    // this prevents the output from looping from left side to right and back during the sin wiggles
    float x = texco.x*2.0f-1.0f;
    float xx = x * x;
    float xxxx = xx * xx;
    float texcox = -xxxx+1.0f;

    if(crazy) {
        color = texture2D(tex, vec2(texco.x + texcox * sin(tick*PI*16 + texco.y*16)/100, texco.y));
        color.r = color.g + color.b;
        color.g = sin(tick * 23) * color.r + sin(tick * 5) * color.g + sin(tick * 11) * color.b;

        if(color.r < 0.5) color.b = 0.2;
        else color.b = 0.7f;
    } else if(boring) {
        color = texture2D(tex, texco);
    } else {
        color = texture2D(tex, 
            vec2(texco.x + texcox * sin(tick*20 + texco.y*20)/100, texco.y));
    }


    gl_FragColor = color;
}
