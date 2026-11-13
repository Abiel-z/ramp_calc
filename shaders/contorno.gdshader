shader_type canvas_item;

uniform float grosor = 2.0;                  // en píxeles del viewport
uniform float umbral : hint_range(0.01, 2.0) = 0.3;
uniform vec4 color_linea : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_fondo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 fondo_3d : source_color = vec4(0.106, 0.125, 0.188, 1.0); // = color de fondo del Environment

// las cotas son rojo puro: no deben generar bordes
bool es_cota(vec3 c) {
	return c.r > 0.9 && c.g < 0.15 && c.b < 0.15;
}

vec3 muestra(sampler2D tex, vec2 uv) {
	vec3 c = texture(tex, uv).rgb;
	return es_cota(c) ? fondo_3d.rgb : c;
}

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE * grosor;
	vec3 centro = texture(TEXTURE, UV).rgb;

	vec3 tl = muestra(TEXTURE, UV + vec2(-px.x, -px.y));
	vec3 tc = muestra(TEXTURE, UV + vec2( 0.0,  -px.y));
	vec3 tr = muestra(TEXTURE, UV + vec2( px.x, -px.y));
	vec3 ml = muestra(TEXTURE, UV + vec2(-px.x,  0.0));
	vec3 mr = muestra(TEXTURE, UV + vec2( px.x,  0.0));
	vec3 bl = muestra(TEXTURE, UV + vec2(-px.x,  px.y));
	vec3 bc = muestra(TEXTURE, UV + vec2( 0.0,   px.y));
	vec3 br = muestra(TEXTURE, UV + vec2( px.x,  px.y));

	// Sobel sobre el color: detecta cambios entre caras, entre piezas y contra el fondo
	vec3 gx = (tr + 2.0 * mr + br) - (tl + 2.0 * ml + bl);
	vec3 gy = (bl + 2.0 * bc + br) - (tl + 2.0 * tc + tr);
	float borde = sqrt(dot(gx, gx) + dot(gy, gy));
	float linea = smoothstep(umbral, umbral * 1.5, borde);

	vec3 resultado = mix(color_fondo.rgb, color_linea.rgb, linea);
	COLOR = vec4(es_cota(centro) ? centro : resultado, 1.0);
}