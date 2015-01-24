#version 130

smooth in vec2 texco;
uniform sampler2D tex;

uniform float tick;

void main(void) {
    vec4 color = texture2D(tex, vec2(texco.x + sin(tick*20 + texco.y*20)/100, texco.y));
    /*gl_FragColor = vec4(abs(color.x * sin(tick * 19/40 + texco.y * 13)),
                        abs(color.y * sin(tick * 31/40 + texco.y * 17)),
                        abs(color.z * sin(tick * 7/40  + texco.y * 23)), 1);
*/

    gl_FragColor = vec4(abs(color.x * sin(tick * 19 + texco.y * 13)),
                        abs(color.y * sin(tick * 31 + texco.y * 17)),
                        abs(color.z * sin(tick * 7  + texco.y * 23)), 1);
}
