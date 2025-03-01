#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

in vec2 v_coordinates;

out ivec4 outData;

uniform isampler2D u_inputTextureIndex;
uniform int u_inputKey;
uniform bool u_partition;
uniform bool u_isPointerDown;
uniform vec2 u_pointerPosition;

const float POINTER_AREA = 0.01;

const ivec2 NORTH      = ivec2(0, 1);
const ivec2 NORTH_EAST = ivec2(1, 1);
const ivec2 EAST       = ivec2(1, 0);

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;

bool isNearPointer() {
  vec2 scaledPointerPosition = u_pointerPosition / 2.0;
  return distance(scaledPointerPosition, v_coordinates) < POINTER_AREA;
}

ivec2 getBlock() {
  ivec2 block = ivec2(gl_FragCoord.xy);
  return block;
}

ivec4 getState(ivec2 block) {
  return texelFetch(u_inputTextureIndex, block, 0);
}

ivec4 applyRules(ivec4 pastState) {
  ivec4 newState = pastState;

  if(pastState.r == 1) {
    newState.r = 0;
    newState.g = 1;
  }

  if(pastState.g == 1) {
    newState.g = 0;
    newState.b = 1;
  }

  if(pastState.b == 1) {
    newState.b = 0;
    newState.a = 1;
  }

  if(pastState.a == 1) {
    newState.a = 0;
    newState.r = 1;
  }

  return newState;
}

void main() {
  if(u_inputKey > -1 && isNearPointer()) {
    outData = ivec4(u_inputKey);
    return;
  }

  ivec2 block = getBlock();
  ivec4 state = getState(block);

  ivec4 newState = applyRules(state);

  outData = newState;
}
