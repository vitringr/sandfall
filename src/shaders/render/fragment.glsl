#version 300 es
precision highp int;
precision highp float;
precision mediump usampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform usampler2D u_outputTexture0;
uniform usampler2D u_outputTexture1;
uniform usampler2D u_outputTexture2;

uniform uint u_maxSoakedCells;
uniform uint u_soakPerAbsorb;

const uint DEBUG = 0u;
const uint EMPTY = 1u;
const uint BLOCK = 2u;
const uint SAND  = 3u;
const uint WATER = 4u;
const uint FIRE  = 5u;
const uint STEAM = 6u;

const vec3 COLOR_DEBUG = vec3(0.6,  0.0,  0.6);
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

const vec3 TEMPERATURE_COLOR = vec3(1.0, 0.0, 0.0);
const uint TEMPERATURE_COLOR_FROM[5] = uint[5](
   0u, // DEBUG
   0u, // Empty
   0u, // Block
   0u, // Sand
   0u  // Water
);
const uint TEMPERATURE_COLOR_TO[5] = uint[5](
   0u,    // DEBUG
   0u,    // Empty
   2000u, // Block
   2000u, // Sand
   0u     // Water
);
const float TEMPERATURE_COLOR_FACTOR[5] = float[5](
  -1.0, // DEBUG
  -1.0, // Empty
  // 0.6,  // Block
  1.0,  // Block
  1.0, // Sand
  // 0.2, // Sand
  -1.0  // Water
);




struct Cell {
  uint rng;
  uint clock;
  uint empty0;
  uint empty1;

  uint type;
  uint temperature;
  uint velocity;
  uint isMoved;

  uint state0;
  uint state1;
  uint state2;
  uint state3;
};

Cell getCell(ivec2 grid) {
  uvec4 data0 = uvec4(texelFetch(u_outputTexture0, grid, 0));
  uvec4 data1 = uvec4(texelFetch(u_outputTexture1, grid, 0));
  uvec4 data2 = uvec4(texelFetch(u_outputTexture2, grid, 0));

  Cell cell;

  cell.rng         = data0.r;
  cell.clock       = data0.g;
  cell.empty0      = data0.b;
  cell.empty1      = data0.a;

  cell.type        = data1.r;
  cell.temperature = data1.g;
  cell.velocity    = data1.b;
  cell.isMoved     = data1.a;

  cell.state0      = data2.r;
  cell.state1      = data2.g;
  cell.state2      = data2.b;
  cell.state3      = data2.a;

  return cell;
}

vec3 applyElementColor(vec3 color, Cell cell) {
  uint mod3RNG = cell.rng % 3u;

  if(cell.type == DEBUG) {
    return COLOR_DEBUG;
  }

  if(cell.type == EMPTY) {
    return COLOR_EMPTY;
  }

  if(cell.type == BLOCK)  {
    return COLOR_BLOCK;
  }

  if(cell.type == SAND) {
    if(cell.state0 <= 0u) {
      return COLORS_SAND[mod3RNG];
    }
    else {
      float maxSoakStep = 1.0 / float(u_maxSoakedCells * u_soakPerAbsorb);

      return mix(
        COLORS_SAND[mod3RNG],
        COLORS_WET_SAND[mod3RNG],
        0.2 + 0.8 * (maxSoakStep * float(cell.state0))
      );
    }
  }

  if(cell.type == WATER) {
    return COLORS_WATER[mod3RNG];
  }

  if(cell.type == FIRE)  {
    return COLORS_FIRE[mod3RNG];
  }

  if(cell.type == STEAM) {
    return COLORS_STEAM[mod3RNG];
  }
}

vec3 applyTemperatureColor(vec3 color, Cell cell) {
  uint beginPoint = TEMPERATURE_COLOR_FROM[cell.type];

  if(beginPoint <= 0u) return color;
  if(cell.temperature <= beginPoint) return color;

  float maxSteps = float(TEMPERATURE_COLOR_TO[cell.type]);
  float factor = TEMPERATURE_COLOR_FACTOR[cell.type];

  float over = float(cell.temperature - beginPoint);

  float step = factor * (1.0 / maxSteps) * over;

  return mix(color, TEMPERATURE_COLOR, min(step, factor));
}

void main() {
  Cell cell = getCell(ivec2(v_coordinates));

  vec3 color = COLOR_DEBUG;

  color = applyElementColor(color, cell);
  color = applyTemperatureColor(color, cell);

  outColor = vec4(color, 1.0);
}
