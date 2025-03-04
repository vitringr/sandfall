#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform float u_canvas;
uniform float u_columns;
uniform float u_borderSize;
uniform isampler2D u_outputTextureIndex;

const vec4 COLORS[6] = vec4[6](
  vec4(0.1,  0.1,  0.1,  1.0),  // 0: Empty
  vec4(0.4,  0.3,  0.2,  1.0),  // 1: Block
  vec4(0.5,  0.4,  0.0,  1.0),  // 2: Sand
  vec4(0.0,  0.3,  0.6,  1.0),  // 3: Water
  vec4(0.7,  0.2,  0.0,  1.0),  // 4: Fire
  vec4(0.4,  0.4,  0.4,  1.0)   // 5: Steam
);

int getInBlockIndex(ivec2 cell) {
  return (cell.x & 1) + 2 * (cell.y & 1);
}

void main() {
  ivec2 cell = ivec2(v_coordinates);
  ivec2 block = cell / 2;

  ivec4 blockData = texelFetch(u_outputTextureIndex, block, 0);

  int inBlockIndex = getInBlockIndex(cell);
  int cellState = blockData[inBlockIndex];

  outColor = COLORS[cellState];
}
