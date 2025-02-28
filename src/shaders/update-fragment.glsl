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

// ivec2 getBlock(ivec2 cellCoordinates) {
//   // Coordinates of a 2x2 margolus block.
//   return (u_partition ? cellCoordinates + 1 : cellCoordinates) / 2;
// }

ivec2 getCell(ivec2 blockCoordinates, int positionInBlock) {
  // WIP have the cell in block coordinate
  return blockCoordinates * 2;
}

int getInBlockIndex(ivec2 cell) {
  // The block index [0 to 3] of a cell.
  ivec2 partitionOffset = u_partition ? cell + 1 : cell;
  return (partitionOffset.x & 1) + 2 * (partitionOffset.y & 1);
}

ivec4 getData(ivec2 block) {
  // Texel data.
  return texelFetch(u_inputTextureIndex, block, 0);
}

// ivec4 getBlockElements(ivec2 block) {
//   // The block cell types.
//   ivec2 cell = block * 2 - (u_partition ? 1 : 0);
//   return ivec4(
//     getData(cell             ).r,   // R: bottom-left cell
//     getData(cell + EAST      ).r,   // G: bottom-right cell
//     getData(cell + NORTH     ).r,   // B: top-left cell
//     getData(cell + NORTH_EAST).r    // A: top-right cell
//   );
// }

bool isAtPointer() {
  // If pointer is near these coordinates.
  return distance(u_pointerPosition, v_coordinates) < POINTER_AREA;
}

void main() {
  ivec2 block = ivec2(gl_FragCoord.xy);

  // Input Spawn
  if(u_inputKey > -1 && isAtPointer()) {
    outData = ivec4(u_inputKey, 0, 0, 0);
    return;
  }

  ivec4 inputData = getData(block);

  // if(uniqueElementsCount == 2) {
  //   ivec2 pair = getUniqueElementsPair(elements);
  //   ivec4 bitRange = mapToBitRange(elements, pair.x);
  //
  //   int oldPattern = encodePattern(bitRange);
  //   int newPattern = INTERACTIONS[getInteractionsIndex(pair) + oldPattern];
  //
  //   ivec4 newPatternBits = decodePattern(newPattern);
  //   ivec4 newBlockElements = mapFromBitRange(newPatternBits, pair);
  //
  //   int newElement = newBlockElements[getInBlockIndex(cell)];
  //
  //   outData = ivec4(newElement, inputData.gba);
  //   return;
  // }

  outData = inputData;
}


