shader_type canvas_item;

uniform float progress: hint_range(0, 1);
uniform float offset: hint_range(0, 10);
//uniform vec3 startColor: source_color = vec3(0.345,0.376,0.431);
//uniform vec3 endColor: source_color = vec3(0.188,0.220,0.306);
uniform vec3 startColor: source_color = vec3(0.345,0.376,0.431);
uniform vec3 endColor: source_color = vec3(0.188,0.220,0.306);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//float temp = max(2.0*fract(TIME), 0.5)+1.00*(-1.0+UV.y)+2.0*fract(TIME);
	//float temp = max(2.0*progress, 0.5)+1.00*(-1.0+UV.y)+2.0*progress;
	//float pct = 0.15*sin(3.0*PI*UV.x) + temp-0.65;
	float pct = 0.075*sin(offset+10.0*UV.x+1.5*TIME);
	float temp = floor(0.8*(UV.y+1.2*progress)+ pct+ 0.125);
	//vec3 progressColor = mix(startColor, endColor, 0.35*sin(3.0*PI*UV.x + 3.0*PI) + temp -0.85);
	vec3 progressColor = mix(startColor, endColor, temp);//max((1.0-UV.y)+progress,0));
	COLOR = vec4(progressColor, 1.0);
}
