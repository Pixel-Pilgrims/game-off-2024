shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.4, 1.0); // Warm yellow glow
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float outline_width : hint_range(0.0, 10.0) = 1.2;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);

    // Calculate outline
    float outline = 0.0;
    for(float x = -outline_width; x <= outline_width; x++) {
        for(float y = -outline_width; y <= outline_width; y++) {
            vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
            if(texture(TEXTURE, UV + offset).a > 0.0) {
                outline = 1.0;
                break;
            }
        }
    }

    // Only show outline on the edges (where the original texture is transparent)
    outline *= (1.0 - texture_color.a);

    // Add glow to the original color
    vec4 glow = glow_color * outline * glow_strength;
    COLOR = texture_color + glow;
}