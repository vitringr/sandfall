#version 300 es

flat out vec2 v_coordinates;

layout(std140) uniform DimensionsStaticData {
  vec2 GRID_DIMENSIONS;
  vec2 CANVAS_DIMENSIONS;
};

vec2 getCoordinates(float id) {
  float xIndex = mod(id, GRID_DIMENSIONS.x);
  float yIndex = floor(id / GRID_DIMENSIONS.x);
  return vec2(xIndex, yIndex);
}

void main() {
  vec2 coordinates = getCoordinates(float(gl_VertexID));
  vec2 point = (coordinates + 0.5) / GRID_DIMENSIONS;

  vec2 clipSpace = point * 2.0 - 1.0;
  gl_Position = vec4(clipSpace, 0.0, 1.0);
  gl_PointSize = (CANVAS_DIMENSIONS.x / GRID_DIMENSIONS.x) - 1.0;

  v_coordinates = point;
}
