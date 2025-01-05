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

const int EMPTY_BLOCK[16] = int[16](0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15);
const int EMPTY_SAND[16]  = int[16](0,  1,  2,  3,  1,  3,  3,  7,  2,  3,  3, 11,  3,  7, 11, 15);
const int EMPTY_WATER[16] = int[16](0,  2,  1,  3,  1,  3,  3, 11,  2,  3,  3,  7,  3,  7, 11, 15);

// Block Pattern Transforms.
const int INTERACTIONS[10 * 16] = int[10 * 16](
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, // EMPTY - BLOCK
  0,  1,  2,  3,  1,  3,  3,  7,  2,  3,  3, 11,  3,  7, 11, 15, // EMPTY - SAND
  0,  2,  1,  3,  1,  3,  3, 11,  2,  3,  3,  7,  3,  7, 11, 15, // EMPTY - WATER
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, // EMPTY - FIRE
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, // BLOCK - SAND
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, // BLOCK - WATER
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, // BLOCK - FIRE
  0,  4,  8, 12,  4, 12, 12, 13,  8, 12, 12, 14, 12, 13, 14, 15, // SAND - WATER
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, // SAND  - FIRE
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15  // WATER - FIRE
);

int getInteractionsIndex(ivec2 pair) {
  // Magic
  return 16 * (ELEMENTS_COUNT * pair.x - (pair.x * (pair.x + 1)) / 2 + (pair.y - pair.x - 1));
}

int encodePattern(ivec4 blockBits) {
  // Encodes 4 bits into a number [0 to 15].
  return blockBits.r +       // R: bottom-left cell
         blockBits.g * 2 +   // G: bottom-right cell
         blockBits.b * 4 +   // B: top-left cell
         blockBits.a * 8;    // A: top-right cell
}

ivec4 decodePattern(int pattern) {
  // Decodes a number [0 to 15] back to 4 bits.
  return ivec4(
     pattern       & 1,   // R: bottom-left cell
    (pattern >> 1) & 1,   // G: bottom-right cell
    (pattern >> 2) & 1,   // B: top-left cell
    (pattern >> 3) & 1    // A: top-right cell
  );
}

ivec2 getBlock(ivec2 cellCoordinates) {
  // Coordinates of a 2x2 margolus block.
  return (u_partition ? cellCoordinates + 1 : cellCoordinates) / 2;
}

int getInBlockIndex(ivec2 cell) {
  // The block index [0 to 3] of a cell.
  ivec2 partitionOffset = u_partition ? cell + 1 : cell;
  return (partitionOffset.x & 1) + 2 * (partitionOffset.y & 1);
}

ivec4 getData(ivec2 cell) {
  // Texel data.
  return texelFetch(u_inputTextureIndex, cell, 0);
}

ivec4 getBlockElements(ivec2 block) {
  // The block cell types.
  ivec2 cell = block * 2 - (u_partition ? 1 : 0);
  return ivec4(
    getData(cell             ).r,   // R: bottom-left cell
    getData(cell + EAST      ).r,   // G: bottom-right cell
    getData(cell + NORTH     ).r,   // B: top-left cell
    getData(cell + NORTH_EAST).r    // A: top-right cell
  );
}

bool isAtPointer() {
  // If pointer is near these coordinates.
  return distance(u_pointerPosition, v_coordinates) < POINTER_AREA;
}

int countUniqueElements(ivec4 elements) {
  int uniqueCount = 1;

  bool e1 = elements[1] != elements[0];
  bool e2 = elements[2] != elements[0] && elements[2] != elements[1];
  bool e3 = elements[3] != elements[0] && elements[3] != elements[1] && elements[3] != elements[2];

  uniqueCount += int(e1) + int(e2) + int(e3);

  return uniqueCount;
}

ivec2 getUniqueElementsPair(ivec4 elements) {
  // Returns the pair of two unique elements in ascending order.
  int one = elements.r;
  int two = (elements.g != one) ? elements.g : (elements.b != one) ? elements.b : elements.a;
  return one < two ? ivec2(one, two) : ivec2(two, one);
}

ivec4 mapToBitRange(ivec4 vector, int smaller) {
  // Maps the ivec4 of two elements into the 0-1 range.
  return ivec4(
    vector.r != smaller,
    vector.g != smaller,
    vector.b != smaller,
    vector.a != smaller
  );
}

ivec4 mapFromBitRange(ivec4 bitRange, ivec2 values) {
  // Maps a bitRange ivec4 of two elements into the values range.
  return ivec4(values.x) + bitRange * (values.y - values.x);
}

void main() {
  ivec2 cell = ivec2(gl_FragCoord.xy);

  // Input Spawn
  if(u_inputKey > -1 && isAtPointer()) {
    outData = ivec4(u_inputKey, 0, 0, 0);
    return;
  }

  ivec4 inputData = getData(cell);
  ivec2 block = getBlock(cell);
  ivec4 elements = getBlockElements(block);

  int uniqueElementsCount = countUniqueElements(elements);

  if(uniqueElementsCount == 1) {
    outData = inputData;
    return;
  }

  if(uniqueElementsCount == 2) {
    ivec2 pair = getUniqueElementsPair(elements);
    ivec4 bitRange = mapToBitRange(elements, pair.x);

    int oldPattern = encodePattern(bitRange);
    int newPattern = INTERACTIONS[getInteractionsIndex(pair) + oldPattern];

    // if(getInteractionsIndex(pair) == 112) {
    //   outData = ivec4(-1, inputData.gba);
    //   return;
    // }

    ivec4 newPatternBits = decodePattern(newPattern);
    ivec4 newBlockElements = mapFromBitRange(newPatternBits, pair);

    int newElement = newBlockElements[getInBlockIndex(cell)];

    outData = ivec4(newElement, inputData.gba);
    return;
  }

  outData = inputData;
}


