#version 300 es

in vec2 a_canvasVertices;

out vec2 v_coordinates;

void main() {
  vec2 clipSpace = a_canvasVertices * 2.0 - 1.0;
  gl_Position = vec4(clipSpace, 0.0, 1.0);

  v_coordinates = a_canvasVertices;
}
