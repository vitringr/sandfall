#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform isampler2D u_outputOneTexture;
uniform isampler2D u_outputTwoTexture;

const vec4 COLORS[6] = vec4[6](
  vec4(0.1,  0.1,  0.1,  1.0),  // 0: Empty
  vec4(0.4,  0.3,  0.2,  1.0),  // 1: Block
  vec4(0.5,  0.4,  0.0,  1.0),  // 2: Sand
  vec4(0.0,  0.3,  0.6,  1.0),  // 3: Water
  vec4(0.7,  0.2,  0.0,  1.0),  // 4: Fire
  vec4(0.4,  0.4,  0.4,  1.0)   // 5: Steam
);

void main() {
  ivec2 grid = ivec2(v_coordinates);

  ivec4 stateOne = texelFetch(u_outputOneTexture, grid, 0);
  // ivec4 stateTwo = texelFetch(u_outputTwoTexture, grid, 0);

  outColor = COLORS[stateOne.b];
}
