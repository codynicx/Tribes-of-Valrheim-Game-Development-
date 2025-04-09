shader_type spatial;

uniform float wave_speed = 0.2;  // Slower movement for more visible waves
uniform float wave_amplitude = 0.008;  // Small but noticeable waves
uniform float wave_frequency = 0.5;  // Larger spaces between waves (lower value)
uniform float time_factor = 1.0;  // Time multiplier to make waves smoother over time
uniform sampler2D water_texture;  // Optional water texture

void vertex() {
	// Combine multiple wave functions to make the movement more noticeable
	float wave1 = sin(TIME * wave_speed + VERTEX.x * wave_frequency) * wave_amplitude;
	float wave2 = sin(TIME * wave_speed + VERTEX.z * wave_frequency * 1.2) * wave_amplitude;
	float wave3 = sin(TIME * wave_speed * 0.5 + VERTEX.x * wave_frequency * 1.5) * wave_amplitude;

	// Sum waves for a smooth continuous effect
	VERTEX.y += (wave1 + wave2 + wave3) * 0.5;
}

void fragment() {
	// More vibrant ocean blue color (darker and richer blue)
	vec3 water_color = vec3(0.2, 0.6, 1.0);  // Vibrant ocean blue

	// Apply texture if available
	if (texture(water_texture, UV).a > 0.0) {
		water_color *= texture(water_texture, UV).rgb;
	}

	ALBEDO = water_color;
}