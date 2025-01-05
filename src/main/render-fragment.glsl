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

const vec4 COLORS[4] = vec4[4](
  vec4(0.1,  0.1,  0.1,  1.0),  // 0: Empty
  vec4(0.5,  0.5,  0.5,  1.0),  // 1: Block
  vec4(0.5,  0.4,  0.0,  1.0),  // 2: Sand
  vec4(0.0,  0.3,  0.6,  1.0)   // 3: Water
);

void main() {
  ivec4 outputData = texelFetch(u_outputTextureIndex,
                                ivec2(v_coordinates * GRID_DIMENSIONS),
                                0);

  if(outputData.r == -1) outColor = vec4(0.5, 0.0, 0.5, 1.0); // Debug
  else outColor = COLORS[outputData.r];
}
