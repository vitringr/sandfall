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

const vec3 COLOR_EMPTY = vec3(0.1,  0.1,  0.1);
const vec3 COLOR_BLOCK = vec3(0.4,  0.3,  0.2);
const vec3 COLORS_SAND[3] = vec3[3](
  vec3(0.7,  0.6,  0.0),
  vec3(0.62,  0.52,  0.0),
  vec3(0.54,  0.44,  0.0)
);
const vec3 COLORS_WATER[3] = vec3[3](
  vec3(0.47,  0.83,  1.0),
  vec3(0.32,  0.80,  1.0),
  vec3(0.29,  0.73,  1.0)
);
const vec3 COLORS_FIRE[3] = vec3[3](
  vec3(1.0,  0.9,  0.0),
  vec3(1.0,  0.6,  0.0),
  vec3(1.0,  0.2,  0.0)
);
const vec3 COLORS_STEAM[3] = vec3[3](
  vec3(0.4,  0.4,  0.4),
  vec3(0.5,  0.5,  0.5),
  vec3(0.3,  0.3,  0.3)
);

void main() {
  ivec2 grid = ivec2(v_coordinates);
  ivec4 stateOne = texelFetch(u_outputOneTexture, grid, 0);

  int rng = stateOne.r;
  int type = stateOne.b;

  vec3 color = vec3(0.0, 0.0, 0.0);

  if(type == EMPTY) 
    color = COLOR_EMPTY;
  else if(type == BLOCK) 
    color = COLOR_BLOCK;
  else if(type == SAND) 
    color = COLORS_SAND[rng];
  else if(type == WATER)
    color = COLORS_WATER[rng];
  else if(type == FIRE) 
    color = COLORS_FIRE[rng];
  else if(type == STEAM)
    color = COLORS_STEAM[rng];

  outColor = vec4(color, 1.0);
}
