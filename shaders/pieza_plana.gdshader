shader_type spatial;
render_mode unshaded;

uniform vec3 tinte : source_color = vec3(1.0);
varying vec3 normal_mundo;

void vertex() {
	normal_mundo = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// color según hacia dónde mira la cara, mezclado con el tinte de la pieza
	ALBEDO = (normal_mundo * 0.5 + 0.5) * tinte;
}