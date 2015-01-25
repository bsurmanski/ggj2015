#version 130

smooth in vec2 texco;
uniform sampler2D tex;

uniform bool crazy;
uniform float tick;

void main(void) {
    if(crazy) {
        vec4 color = texture2D(tex, vec2(texco.x + (-pow(texco.x*2-1,10)+1) * sin(tick*20 + texco.y*20)/100, texco.y));
        color.r = color.g + color.b;
        color.g = sin(tick * 23) * color.r + sin(tick * 5) * color.g + sin(tick * 11) * color.b;

        if(color.r < 0.5) color.b = 0.2;
        else color.b = 0.7f;
        gl_FragColor = color;
    } else {
        gl_FragColor = texture2D(tex, 
            vec2(texco.x + (-pow(texco.x*2-1,10)+1) * sin(tick*20 + texco.y*20)/100, texco.y));
    }
}
