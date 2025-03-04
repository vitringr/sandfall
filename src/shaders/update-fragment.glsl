#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

in vec2 v_coordinates;

out ivec4 outData;

uniform int u_inputKey;
uniform bool u_partition;
uniform bool u_isPointerDown;
uniform vec2 u_pointerPosition;
uniform isampler2D u_inputTextureIndex;

const float POINTER_AREA = 0.05;

const ivec2 NORTH      = ivec2(0, 1);
const ivec2 NORTH_EAST = ivec2(1, 1);
const ivec2 EAST       = ivec2(1, 0);

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;

bool isClicked() {
  if(u_inputKey < 0) return false;
  return distance(u_pointerPosition, v_coordinates) < POINTER_AREA;
}

ivec2 getCell() {
  return ivec2(gl_FragCoord.xy);
}

ivec4 getState(ivec2 cell) {
  return texelFetch(u_inputTextureIndex, cell, 0);
}

void main() {
  if(isClicked()) {
    outData = ivec4(u_inputKey);
    return;
  }

  ivec2 cell = getCell();
  ivec4 state = getState(cell);

  outData = state;
}
