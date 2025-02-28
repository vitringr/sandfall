#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform isampler2D u_outputTextureIndex;
layout(std140) uniform DimensionsStaticData {
  vec2 GRID_DIMENSIONS;
  vec2 CANVAS_DIMENSIONS;
};

const vec4 COLORS[6] = vec4[6](
  vec4(0.1,  0.1,  0.1,  1.0),  // 0: Empty
  vec4(0.4,  0.3,  0.2,  1.0),  // 1: Block
  vec4(0.5,  0.4,  0.0,  1.0),  // 2: Sand
  vec4(0.0,  0.3,  0.6,  1.0),  // 3: Water
  vec4(0.7,  0.2,  0.0,  1.0),  // 4: Fire
  vec4(0.4,  0.4,  0.4,  1.0)   // 5: Steam
);

// ivec4 outputData = texelFetch(u_outputTextureIndex,
//                               ivec2(v_coordinates * GRID_DIMENSIONS),
//                               0);

// void main() {
//   ivec2 cellCoordinates = ivec2(v_coordinates);
//
//   ivec4 blockData = texelFetch(u_outputTextureIndex, cellCoordinates / 2, 0);
//
//   int cellIndex = (cellCoordinates.y % 2) 
//
// }

void main() {
  ivec2 cellCoord = ivec2(v_coordinates);
  ivec4 blockData = texelFetch(u_outputTextureIndex, cellCoord / 2, 0);

  // Determine which cell in the block this fragment corresponds to
  int cellIndex = (cellCoord.y % 2) * 2 + (cellCoord.x % 2);
  int cellState = blockData[cellIndex];

  // if(cellState < 0) outColor = vec4(0.5, 0.0, 0.5, 1.0); // Debug
  // else outColor = COLORS[cellState];

  outColor = COLORS[cellState];
}
