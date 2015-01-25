#version 130

smooth in vec2 texco;
uniform sampler2D tex;

uniform float tick;
uniform bool crazy;

void main(void) {
    float PI = 3.14159265358979323846264;
    vec4 color = texture2D(tex, vec2(texco.x + sin(tick * (8 * PI) + texco.y*10)/100, texco.y));

    if(crazy) {
        color = vec4(abs(color.x * sin(tick * 19 + texco.y * 13)),
                            abs(color.y * sin(tick * 31 + texco.y * 17)),
                            abs(color.z * sin(tick * 7  + texco.y * 23)), 1);
    } else {
        color = vec4(abs(color.x * sin(tick * 19/40 + texco.y * 13)),
                            abs(color.y * sin(tick * 31/40 + texco.y * 17)),
                            abs(color.z * sin(tick * 7/40  + texco.y * 23)), 1);
    }

    float res = sin(tick) * 7.0f + 9.0f;
    color = floor(color * res) / res;
    color.a = 1.0f;

    gl_FragColor = color;
}
