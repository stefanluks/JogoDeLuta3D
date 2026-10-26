shader_type spatial;
render_mode diffuse_toon, specular_toon;
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform bool has_texture = false;
uniform vec4 base_color : source_color = vec4(0.7, 0.8, 0.9, 1.0);
void fragment() {
 ALBEDO = base_color.rgb * (has_texture ? texture(albedo_texture, UV).rgb : vec3(1.0));
 ROUGHNESS = 0.85;
}
