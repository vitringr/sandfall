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
const ivec2 PARTITION_OFFSET = ivec2(1, 1);

const ivec2 NORTH      = ivec2( 0,  1);
const ivec2 NORTH_EAST = ivec2( 1,  1);
const ivec2 EAST       = ivec2( 1,  0);
const ivec2 SOUTH_EAST = ivec2( 1, -1);
const ivec2 SOUTH      = ivec2( 0, -1);
const ivec2 SOUTH_WEST = ivec2(-1, -1);
const ivec2 WEST       = ivec2(-1,  0);
const ivec2 NORTH_WEST = ivec2(-1,  1);

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;




int getInBlockIndex(ivec2 cell) {
  ivec2 margolusCell = u_partition ? (cell + PARTITION_OFFSET) : cell;
  return (margolusCell.x & 1) + 2 * (margolusCell.y & 1);
}

ivec2 getHorizontalNeighbor(ivec2 cell, int inBlockIndex) {
  if((inBlockIndex & 1) == 0) return cell + EAST;
  return cell + WEST;
}

ivec2 getVerticalNeighbor(ivec2 cell, int inBlockIndex) {
  if(inBlockIndex < 2) return cell + NORTH;
  return cell + SOUTH;
}

ivec2 getDiagonalNeighbor(ivec2 cell, int inBlockIndex) {
  if     (inBlockIndex == 0) return cell + NORTH_EAST;
  else if(inBlockIndex == 1) return cell + NORTH_WEST;
  else if(inBlockIndex == 2) return cell + SOUTH_EAST;
  else                       return cell + SOUTH_WEST;
}

ivec4 getState(ivec2 cell) {
  return texelFetch(u_inputTextureIndex, cell, 0);
}

bool isClicked() {
  if(u_inputKey < 0) return false;
  return distance(u_pointerPosition, v_coordinates) < POINTER_AREA;
}




int empty(ivec3 neighbors, int inBlockIndex) {
  bool isAbove = inBlockIndex >= 2;
  if(isAbove) return EMPTY;

  if(neighbors.y == SAND)
    return SAND;

  if(neighbors.z == SAND && neighbors.x == SAND) 
    return SAND;

  return EMPTY;
}

int block() {
  return BLOCK;
}

int sand(ivec3 neighbors, int inBlockIndex) {
  bool isBelow = inBlockIndex < 2;
  if(isBelow) return SAND;

  if(neighbors.y == EMPTY) return EMPTY;

  if(neighbors.y == SAND) {
    if(neighbors.z == EMPTY && neighbors.x == EMPTY)
      return EMPTY;
  }

  return SAND;
}




void main() {
  if(isClicked()) {
    outData = ivec4(u_inputKey);
    return;
  }

  ivec2 cell = ivec2(gl_FragCoord.xy);

  int inBlockIndex = getInBlockIndex(cell);

  ivec4 horizontalNeighborState = getState(getHorizontalNeighbor(cell, inBlockIndex));
  ivec4 verticalNeighborState   = getState(getVerticalNeighbor(cell, inBlockIndex));
  ivec4 diagonalNeighborState   = getState(getDiagonalNeighbor(cell, inBlockIndex));

  ivec3 neighbors = ivec3(
    horizontalNeighborState.r,
    verticalNeighborState.r,
    diagonalNeighborState.r
  );

  ivec4 state = getState(cell);
  ivec4 newState = state;

  int element = state.r;

  if(element == EMPTY)
    newState.r = empty(neighbors, inBlockIndex);

  else if(element == BLOCK)
    newState.r = block();

  else if(element == SAND)
    newState.r = sand(neighbors, inBlockIndex);

  outData = newState;
}
