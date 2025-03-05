#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

in vec2 v_coordinates;

out ivec4 outData;

uniform int u_time;
uniform int u_inputKey;
uniform bool u_partition;
uniform bool u_isPointerDown;
uniform vec2 u_pointerPosition;
uniform isampler2D u_inputTextureIndex;

const float POINTER_AREA = 0.05;
const ivec2 PARTITION_OFFSET = ivec2(1, 1);

const ivec2 NORTH = ivec2( 0,  1);
const ivec2 EAST  = ivec2( 1,  0);
const ivec2 SOUTH = ivec2( 0, -1);
const ivec2 WEST  = ivec2(-1,  0);

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;




struct Cell {
  int type;
  int empty1;
  int empty2;
  int empty3;
};

struct Block {
  Cell BL;
  Cell BR;
  Cell TL;
  Cell TR;
};

struct TypeBlock {
  int BL;
  int BR;
  int TL;
  int TR;
};




Cell getCell(ivec2 grid) {
  ivec4 state = texelFetch(u_inputTextureIndex, grid, 0);

  Cell cell;
  cell.type   = state.r;
  cell.empty1 = state.g;
  cell.empty2 = state.b;
  cell.empty3 = state.a;

  return cell;
}

ivec2 getBlockOrigin(ivec2 grid) {
  ivec2 keepAboveZero = ivec2(2, 2);

  ivec2 offset = u_partition ? PARTITION_OFFSET : ivec2(0, 0);
  ivec2 origin = ((grid + keepAboveZero - offset) / 2) * 2 + offset;

  return origin - keepAboveZero;
}

Block getBlock(ivec2 origin) {
  Block block;
  block.BL = getCell(origin);                 // index: 0
  block.BR = getCell(origin + EAST);          // index: 1
  block.TL = getCell(origin + NORTH);         // index: 2
  block.TR = getCell(origin + NORTH + EAST);  // index: 3

  return block;
}

TypeBlock getTypeBlock(Block block) {
  TypeBlock typeBlock;
  typeBlock.BL = block.BL.type;
  typeBlock.BR = block.BR.type;
  typeBlock.TL = block.TL.type;
  typeBlock.TR = block.TR.type;

  return typeBlock;
}

int getInBlockIndex(ivec2 grid) {
  ivec2 blockOrigin = getBlockOrigin(grid);

  // remainder is: (0, 0), (1, 0), (0, 1), (1, 1)
  ivec2 remainder = grid - blockOrigin;

  return (remainder.x & 1) + 2 * (remainder.y & 1);
}

Cell getCellFromBlock(ivec2 grid, Block block) {
  int inBlockIndex = getInBlockIndex(grid);

  if(inBlockIndex == 0) return block.BL;
  if(inBlockIndex == 1) return block.BR;
  if(inBlockIndex == 2) return block.TL;
  if(inBlockIndex == 3) return block.TR;
}

bool isClicked() {
  if(u_inputKey < 0) return false;
  return distance(u_pointerPosition, v_coordinates) < POINTER_AREA;
}




void swap(inout int a, inout int b) {
  int temp = a;
  a = b;
  b = temp;
}

Block applyLogic(Block originalBlock) {
  Block newBlock = originalBlock;
  TypeBlock types = getTypeBlock(newBlock);

  if(types.TL == SAND && types.BL == EMPTY) {
    swap(types.TL, types.BL);
  }

  if(types.TR == SAND && types.BR == EMPTY) {
    swap(types.TR, types.BR);
  }

  newBlock.BL.type = types.BL;
  newBlock.BR.type = types.BR;
  newBlock.TL.type = types.TL;
  newBlock.TR.type = types.TR;

  return newBlock;
}




void main() {
  if(isClicked()) {
    outData = ivec4(u_inputKey, 0, 0, 0);
    return;
  }

  ivec2 grid = ivec2(gl_FragCoord.xy);
  ivec2 blockOrigin = getBlockOrigin(grid);

  Block block = getBlock(blockOrigin);
  Block newBlock = applyLogic(block);

  Cell thisCell = getCellFromBlock(grid, newBlock);

  outData = ivec4(
    thisCell.type,
    thisCell.empty1,
    thisCell.empty2,
    thisCell.empty3
  );
}
