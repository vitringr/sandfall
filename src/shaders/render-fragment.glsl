#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

out vec4 outColor;

flat in vec2 v_coordinates;

uniform bool u_debug;
uniform bool u_partition;
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

const float DEBUG_BORDER_SIZE = 0.02;

int getInBlockIndex(ivec2 cell) {
  return (cell.x & 1) + 2 * (cell.y & 1);
}

bool isDebugBorder(vec2 offset) {
  int localX = int(mod(v_coordinates.x + offset.x, 2.0));
  int localY = int(mod(v_coordinates.y + offset.y, 2.0));
  float borderThreshold = DEBUG_BORDER_SIZE;

  if(localX == 0 && gl_PointCoord.x < borderThreshold) return true;
  if(localX == 1 && gl_PointCoord.x > 1.0 - borderThreshold) return true;
  if(localY == 0 && gl_PointCoord.y < borderThreshold) return true;
  if(localY == 1 && gl_PointCoord.y > 1.0 - borderThreshold) return true;

  return false;
}

void main() {
  ivec2 cell = ivec2(v_coordinates);
  ivec4 state = texelFetch(u_outputTextureIndex, cell, 0);

  outColor = COLORS[state.r];

  if(u_debug) {
    if(u_partition){
      if(isDebugBorder(vec2(1.0, 0.0))) outColor = vec4(0.5, 0.3, 0.0, 1.0);
    }
    else {
      if(isDebugBorder(vec2(0.0, 1.0))) outColor = vec4(0.0, 0.3, 0.7, 1.0);
    }
  }
}
