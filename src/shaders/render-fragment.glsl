#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform isampler2D u_outputOneTexture;
uniform isampler2D u_outputTwoTexture;

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;

const vec4 COLORS[6] = vec4[6](
  vec4(0.1,  0.1,  0.1,  1.0),  // 0: Empty
  vec4(0.4,  0.3,  0.2,  1.0),  // 1: Block
  vec4(0.5,  0.4,  0.0,  1.0),  // 2: Sand
  vec4(0.0,  0.3,  0.6,  1.0),  // 3: Water
  vec4(0.7,  0.2,  0.0,  1.0),  // 4: Fire
  vec4(0.4,  0.4,  0.4,  1.0)   // 5: Steam
);

const vec4 COLORS_SAND[3] = vec4[3](
  vec4(vec3(0.5,  0.4,  0.0)      ,  1.0),
  vec4(vec3(0.5,  0.4,  0.0) * 0.9,  1.0),
  vec4(vec3(0.5,  0.4,  0.0) * 0.8,  1.0)
);

void main() {
  ivec2 grid = ivec2(v_coordinates);

  ivec4 stateOne = texelFetch(u_outputOneTexture, grid, 0);

  int rng = stateOne.r;
  int type = stateOne.b;

  if(type == SAND){
    outColor = COLORS_SAND[rng];
  }
  else {
    outColor = COLORS[stateOne.b];
  }
}
