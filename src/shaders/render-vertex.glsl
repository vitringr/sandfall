#version 300 es

flat out vec2 v_coordinates;

uniform float u_borderSize;
layout(std140) uniform Dimensions {
  float CELL_RANGE;
  float BLOCK_RANGE;
  float CANVAS_RANGE;
};

vec2 getCoordinates(float id) {
  float xIndex = mod(id, CELL_RANGE);
  float yIndex = floor(id / CELL_RANGE);
  return vec2(xIndex, yIndex);
}

void main() {
  vec2 coordinates = getCoordinates(float(gl_VertexID));
  vec2 point = (coordinates + 0.5) / CELL_RANGE;

  vec2 clipSpace = point * 2.0 - 1.0;
  gl_Position = vec4(clipSpace, 0.0, 1.0);

  float scale = CANVAS_RANGE / CELL_RANGE;
  gl_PointSize = scale - float(u_borderSize);

  v_coordinates = coordinates;
}
