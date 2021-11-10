extern number time;
number t;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
{
    t = time * 1.5; //may want to vary this for cycle speed?
    color = Texel(tex, tc);
    return vec4(vec3(color.r + sin(t + 5.0)+0.3, color.b + -sin(t+5)+0.3, color.g + sin(t + 10.0)), color.a); //cycles colors and pulses brightness slightly
}