shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D palette;
uniform int palette_size;

uniform float randomization_amount = 0.5;
uniform float randomization_seed = 11.0;

vec3 hueShift( vec3 color, float hueAdjust ){
    const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
    const vec3  kRGBToI      = vec3 (0.596, -0.275, -0.321);
    const vec3  kRGBToQ      = vec3 (0.212, -0.523, 0.311);

    const vec3  kYIQToR     = vec3 (1.0, 0.956, 0.621);
    const vec3  kYIQToG     = vec3 (1.0, -0.272, -0.647);
    const vec3  kYIQToB     = vec3 (1.0, -1.107, 1.704);

    float   YPrime  = dot (color, kRGBToYPrime);
    float   I       = dot (color, kRGBToI);
    float   Q       = dot (color, kRGBToQ);
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    hue += hueAdjust;

    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    vec3    yIQ   = vec3 (YPrime, I, Q);

    return vec3( dot (yIQ, kYIQToR), dot (yIQ, kYIQToG), dot (yIQ, kYIQToB) );
}

void fragment() {
	vec4 original_color = textureLod(screen_texture, UV, 0.0);
	
	float idx = -1.0;
    float bestDistance = 1000000000.0;
	vec3 best_palette_color;
	const int MAX_ITERATIONS = 1000;
	
	for (int i = 0; i < MAX_ITERATIONS; i++) {
        if (i >= palette_size) {
            break;
        }
		vec3 palette_color = texture(palette, vec2((float(i) + 0.5) / float(palette_size), 0)).rgb;
		float dist = distance(palette_color, original_color.rgb);
		if (dist < bestDistance) {
			idx = float(i);
			bestDistance = dist;
			best_palette_color = palette_color;
		}
	}
	
	if (idx >= 0.0) {
		float change_amount = (fract(sin(dot(vec2(randomization_seed, idx), vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * randomization_amount;
		COLOR = vec4(hueShift(best_palette_color, change_amount * PI), original_color.a);
	} else {
		COLOR = original_color;
	}
}












