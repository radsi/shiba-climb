shader_type canvas_item;

uniform sampler2D mask_texture; // Your mask texture (e.g., a black and white image)
uniform vec4 region_rect_uv_data; // x, y, width, height of the region in UV space

void fragment() {
    // Get the base color of the sprite's texture region
    vec4 base_color = texture(TEXTURE, UV);

    // Calculate UV relative to the region_rect
    // region_rect_uv_data.xy is the top-left corner of the region in UV space
    // region_rect_uv_data.zw is the width and height of the region in UV space
    vec2 region_uv = (UV - region_rect_uv_data.xy) / region_rect_uv_data.zw;

    // Check if the current UV is *within* the region (important for padding/edges)
    // This is often not strictly necessary if Godot's Sprite2D handles clipping
    // perfectly, but it's good practice for robustness.
    //if (region_uv.x < 0.0 || region_uv.x > 1.0 || region_uv.y < 0.0 || region_uv.y > 1.0) {
        //COLOR = base_color; // Render original color outside the region (or discard if desired)
        //return;
    //}

    // Sample the mask texture using the region-relative UV
    vec4 mask_color = texture(mask_texture, region_uv);

    // Apply the mask. For example, use the red channel of the mask as alpha.
    // Assuming your mask_texture has black (0) for transparent and white (1) for opaque.
    base_color.a *= mask_color.r;

    COLOR = base_color;
}