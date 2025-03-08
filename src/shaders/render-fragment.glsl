#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform isampler2D u_outputTexture0;
uniform isampler2D u_outputTexture1;
uniform isampler2D u_outputTexture2;

uniform int u_maxSoakedCells;
uniform int u_soakPerAbsorb;

const int EMPTY    = 0;
const int BLOCK    = 1;
const int SAND     = 2;
const int WATER    = 3;
const int FIRE     = 4;
const int STEAM    = 5;

const vec3 COLOR_DEBUG = vec3(1.0,  0.0,  1.0);
const vec3 COLOR_EMPTY = vec3(0.1,  0.1,  0.1);
const vec3 COLOR_BLOCK = vec3(0.4,  0.3,  0.2);

const vec3 COLORS_SAND[3] = vec3[3](
  vec3(0.75,  0.65,  0.0),
  vec3(0.70,  0.60,  0.0),
  vec3(0.65,  0.55,  0.1)
);
const vec3 COLORS_WET_SAND[3] = vec3[3](
  vec3(0.32,  0.27,  0.27),
  vec3(0.29,  0.24,  0.24),
  vec3(0.26,  0.21,  0.21)
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





struct Cell {
  int rng;
  int clock;
  int empty0;
  int empty1;

  int type;
  int heat;
  int velocity;
  int isMoved;

  int state0;
  int state1;
  int state2;
  int state3;
};

Cell getCell(ivec2 grid) {
  ivec4 data0 = texelFetch(u_outputTexture0, grid, 0);
  ivec4 data1 = texelFetch(u_outputTexture1, grid, 0);
  ivec4 data2 = texelFetch(u_outputTexture2, grid, 0);

  Cell cell;

  cell.rng      = data0.r;
  cell.clock    = data0.g;
  cell.empty0   = data0.b;
  cell.empty1   = data0.a;

  cell.type     = data1.r;
  cell.heat     = data1.g;
  cell.velocity = data1.b;
  cell.isMoved  = data1.a;

  cell.state0   = data2.r;
  cell.state1   = data2.g;
  cell.state2   = data2.b;
  cell.state3   = data2.a;

  return cell;
}




void main() {
  Cell cell = getCell(ivec2(v_coordinates));

  vec3 color = vec3(0.0, 0.0, 0.0);

  int mod3RNG = cell.rng % 3;

  if(cell.type == EMPTY) {
    color = COLOR_EMPTY;
  }

  else if(cell.type == BLOCK)  {
    color = COLOR_BLOCK;
  }

  else if(cell.type == SAND) {
    if(cell.state0 <= 0) {
      color = COLORS_SAND[mod3RNG];
    }
    else {
      float maxSoakStep = 1.0 / float(u_maxSoakedCells * u_soakPerAbsorb);

      color = mix(
        COLORS_SAND[mod3RNG],
        COLORS_WET_SAND[mod3RNG],
        0.2 + 0.8 * (maxSoakStep * float(cell.state0))
      );
    }
  }

  else if(cell.type == WATER) {
    color = COLORS_WATER[mod3RNG];
  }

  else if(cell.type == FIRE)  {
    color = COLORS_FIRE[mod3RNG];
  }

  else if(cell.type == STEAM) {
    color = COLORS_STEAM[mod3RNG];
  }

  outColor = vec4(color, 1.0);
}
