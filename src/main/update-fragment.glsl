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

const float POINTER_AREA = 0.03;

// Neighbor Offsets.
const ivec2 NORTH      = ivec2(0, 1);
const ivec2 NORTH_EAST = ivec2(1, 1);
const ivec2 EAST       = ivec2(1, 0);

const int ELEMENTS_COUNT = 5;

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;

bool isAtPointer() {
  // If pointer is near these coordinates.
  return distance(u_pointerPosition, v_coordinates) < POINTER_AREA;
}

void main() {
  ivec2 cell = ivec2(gl_FragCoord.xy);

  ivec4 inputData = texelFetch(u_inputTextureIndex, cell, 0);

  if(u_inputKey > -1 && isAtPointer()) {
    outData = ivec4(u_inputKey, 0, 0, 0);
    return;
  }

  outData = inputData;
}


