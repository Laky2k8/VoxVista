shader_type canvas_item;

// The screen texture (automatically provided when using hint_screen_texture)
uniform sampler2D screen_tex : hint_screen_texture;

// Size of the viewport in pixels (set from GDScript)
uniform vec2 screen_size = vec2(1280.0, 720.0);

// Number of screen pixels per pixelated "block"
uniform float pixel_size : hint_range(1.0, 256.0) = 4.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    // how many blocks across and down
    vec2 blocks = screen_size / pixel_size;

    // sample the center of the block to avoid edge interpolation blur
    vec2 cell = floor(uv * blocks) + 0.5;
    vec2 coord = cell / blocks;

    COLOR = texture(screen_tex, coord);
}
