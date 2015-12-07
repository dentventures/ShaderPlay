#version 330 core

in vec3 vLightDirection;
in vec3 vNormal;

out vec4 fragColor;

void main()
{
	vec3 color = vec3(0.0, 0.5, 1.0);
	float d = (gl_FragCoord.z*gl_FragCoord.w);
	float brightness = dot(-1.0 * normalize(vLightDirection), normalize(vNormal));

// srgb*Srgb + drgb * Drgb
	vec3 diffuse = color*brightness;

    fragColor = vec4(diffuse + d, 1.0);
}