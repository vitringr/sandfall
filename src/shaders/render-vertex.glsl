#version 300 es

flat out vec2 v_coordinates;

uniform float u_canvas;
uniform float u_columns;
uniform float u_borderSize;

vec2 getCoordinates(float id) {
  float xIndex = mod(id, u_columns);
  float yIndex = floor(id / u_columns);
  return vec2(xIndex, yIndex);
}

void main() {
  vec2 coordinates = getCoordinates(float(gl_VertexID));
  vec2 point = (coordinates + 0.5) / u_columns;

  vec2 clipSpace = point * 2.0 - 1.0;
  gl_Position = vec4(clipSpace, 0.0, 1.0);

  float scale = u_canvas / u_columns;
  gl_PointSize = scale - float(u_borderSize);

  v_coordinates = coordinates;
}
