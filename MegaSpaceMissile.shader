shader_type spatial;

//time_scale is a uniform float
const float time_scale = 2.0;
const float side_to_side = 1.0;
uniform vec3 impact_site;
const vec3 core = vec3(0);
const float max_dist = 5.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 lerp(vec3 a, vec3 b, float factor) {
    return (a + factor*(b-a));
} 

void vertex() {
	float time = TIME * time_scale;
	
	float dist = length(impact_site - VERTEX);
	
	vec3 ray = VERTEX - core;
	VERTEX = ray + (normalize(ray) * sin(dist*time));
	
	dist = length(impact_site - VERTEX);
	
	//vec3 albedo = vec3(rand(VERTEX.yz),0,0);
	COLOR.xyz = lerp(vec3(1,0,0), vec3(1,1,0), dist / 3.0);
}

void fragment(){
	// Shinier
	ALBEDO = COLOR.xyz;
	ROUGHNESS = 0.5;
	METALLIC = 0.5;
	
	// Flatter
	//ALBEDO = COLOR.xyz;
	//ROUGHNESS = 1.0;
	//METALLIC = 0.5;
	
}