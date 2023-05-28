shader_type canvas_item;

uniform float time : hint_range(0, 10) = 0;
uniform vec2 resolution : hint_range(0, 4096) = vec2(512.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = textureLod(SCREEN_TEXTURE, uv, 0.0);

    float disintegrate = smoothstep(0.0, 1.0, time);
    float noise = textureLod(SCREEN_TEXTURE, uv * resolution, 8.0).r;
    float distortion = pow(noise, 3.0) * disintegrate;

    uv += distortion * vec2(0.1, 0.1);

    color.rgb *= 1.0 - disintegrate;
    color.a *= 1.0 - disintegrate;

    COLOR = color;
}