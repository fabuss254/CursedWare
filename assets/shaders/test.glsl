#pragma header

uniform float deltaX;
uniform float deltaY;

uniform float resolutionX;
uniform float resolutionY;

void main() {

    vec2 dir = openfl_TextureCoordv - vec2( .5 );
    float d = .7 * length( dir );
    normalize( dir );
    vec2 value = d * dir * vec2(deltaX, deltaY);

    vec4 c1 = texture2D( bitmap, openfl_TextureCoordv - value / resolutionX );
    vec4 c2 = texture2D( bitmap, openfl_TextureCoordv );
    vec4 c3 = texture2D( bitmap, openfl_TextureCoordv + value / resolutionY );
    
    gl_FragColor = vec4( c1.r, c2.g, c3.b, c1.a + c2.a + c3.b );

}