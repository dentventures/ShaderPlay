#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;

uniform vec3 lightDirection;
uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;


out vec3 vLightDirection;
out vec3 vNormal;

void main()
{
	vLightDirection = lightDirection;
	vNormal = normal;
    gl_Position = projection * view * model * vec4(position, 1.0);
}