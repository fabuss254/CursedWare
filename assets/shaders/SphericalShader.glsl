extern number time; // time in seconds
		
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pixel_coords)
{
	vec2 p = -1.0 + 2.0 * tc;
	number r = dot(p, p);
	
	if (r > 1.0) discard;
	
	number f = (1.0 - sqrt(1.0 - r)) / (r);
	vec2 uv;
	uv.x = 1.0*p.x*f + time;
	uv.y = 1.0*p.y*f;
	
	return vec4(Texel(texture, uv).xyz, 1.0) * color;
}