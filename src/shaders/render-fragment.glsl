#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform isampler2D u_outputOneTexture;
uniform isampler2D u_outputTwoTexture;

const int EMPTY    = 0;
const int BLOCK    = 1;
const int SAND     = 2;
const int WATER    = 3;
const int FIRE     = 4;
const int STEAM    = 5;
const int WET_SAND = 6;

const vec3 COLOR_EMPTY = vec3(0.1,  0.1,  0.1);
const vec3 COLOR_BLOCK = vec3(0.4,  0.3,  0.2);

const vec3 COLORS_SAND[3] = vec3[3](
  vec3(0.75,  0.65,  0.0),
  vec3(0.70,  0.60,  0.0),
  vec3(0.65,  0.55,  0.1)
);
const vec3 COLORS_WATER[3] = vec3[3](
  vec3(0.32,  0.76,  1.0),
  vec3(0.29,  0.72,  1.0),
  vec3(0.26,  0.69,  1.0)
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

const vec3 COLOR_ADD_SAND_WETNESS = vec3(0.0, 0.0, 0.3);




struct Cell {
  int rng;
  int clock;
  int type;
  int state;

  int velocity;
  int isMoved;
  int heat;
  int empty;
};




Cell getCell(ivec2 grid) {
  ivec4 one = texelFetch(u_outputOneTexture, grid, 0);
  ivec4 two = texelFetch(u_outputTwoTexture, grid, 0);

  Cell cell;

  cell.rng      = one.r;
  cell.clock    = one.g;
  cell.type     = one.b;
  cell.state    = one.a;

  cell.velocity = two.r;
  cell.isMoved  = two.g;
  cell.heat     = two.b;
  cell.empty    = two.a;

  return cell;
}

void main() {
  Cell thisCell = getCell(ivec2(v_coordinates));

  vec3 color = vec3(0.0, 0.0, 0.0);

  int mod3RNG = thisCell.rng % 3;

  if(thisCell.type == EMPTY) 
    color = COLOR_EMPTY;
  else if(thisCell.type == BLOCK) 
    color = COLOR_BLOCK;
  else if(thisCell.type == SAND) 
    color = COLORS_SAND[mod3RNG];
  else if(thisCell.type == WATER)
    color = COLORS_WATER[mod3RNG];
  else if(thisCell.type == FIRE) 
    color = COLORS_FIRE[mod3RNG];
  else if(thisCell.type == STEAM)
    color = COLORS_STEAM[mod3RNG];
  else if(thisCell.type == WET_SAND)
    color = COLORS_SAND[mod3RNG] * 0.7 + COLOR_ADD_SAND_WETNESS;

  outColor = vec4(color, 1.0);
}
