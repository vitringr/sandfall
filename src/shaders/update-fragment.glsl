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

const int DENSITY[6] = int[6](
  -10,
  10,
  1,
  0,
  -1,
  -1
);




struct Cell {
  int type;
  ivec2 velocity;
  int density;
};

struct Block {
  Cell bl;
  Cell br;
  Cell tl;
  Cell tr;
};




Cell getCell(ivec2 grid) {
  ivec4 state = texelFetch(u_inputTextureIndex, grid, 0);

  Cell cell;
  cell.type     = state.r;
  cell.velocity = state.gb;
  cell.density  = state.a;

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
  block.bl = getCell(origin);                 // index: 0
  block.br = getCell(origin + EAST);          // index: 1
  block.tl = getCell(origin + NORTH);         // index: 2
  block.tr = getCell(origin + NORTH + EAST);  // index: 3

  return block;
}

int getInBlockIndex(ivec2 grid) {
  ivec2 blockOrigin = getBlockOrigin(grid);

  ivec2 remainder = grid - blockOrigin;

  return (remainder.x & 1) + 2 * (remainder.y & 1);
}

Cell getCellFromBlock(ivec2 grid, Block block) {
  int inBlockIndex = getInBlockIndex(grid);

  if(inBlockIndex == 0) return block.bl;
  if(inBlockIndex == 1) return block.br;
  if(inBlockIndex == 2) return block.tl;
  if(inBlockIndex == 3) return block.tr;
}

bool isClicked() {
  if(u_inputKey < 0) return false;
  return distance(u_pointerPosition, v_coordinates) < POINTER_AREA;
}




void swap(inout Cell a, inout Cell b) {
  Cell temp = a;
  a = b;
  b = temp;
}

bool isMoving(Cell cell) {
  return cell.velocity != ivec2(0, 0);
}

bool canMoveInBlock(ivec2 velocity, int inBlockIndex) {
  if(inBlockIndex == 0) return velocity.x >= 0 && velocity.y >= 0; // bl
  if(inBlockIndex == 1) return velocity.x <= 0 && velocity.y >= 0; // br
  if(inBlockIndex == 2) return velocity.x >= 0 && velocity.y <= 0; // tl
  if(inBlockIndex == 3) return velocity.x <= 0 && velocity.y <= 0; // tr
}

bool canSwap(Cell a, Cell b) {
  return a.density > b.density;
}



Block applyLogic(Block originalBlock) {
  Block block = originalBlock;

  if(isMoving(block.bl) && canMoveInBlock(block.bl.velocity, 0)) {
    if(block.bl.velocity == EAST) {
      if(canSwap(block.bl, block.br))
        swap(block.bl, block.br);
    }

    if(block.bl.velocity == NORTH) {
      if(canSwap(block.bl, block.tl))
        swap(block.bl, block.tl);
    }

    if(block.bl.velocity == (NORTH + EAST)) {
      if(canSwap(block.bl, block.tr))
        swap(block.bl, block.tr);
    }
  }

  if(isMoving(block.br) && canMoveInBlock(block.br.velocity, 1)) {
    if(block.br.velocity == WEST) {
      if(canSwap(block.br, block.bl))
        swap(block.br, block.bl);
    }

    if(block.br.velocity == (NORTH + WEST)) {
      if(canSwap(block.br, block.tl))
        swap(block.br, block.tl);
    }

    if(block.br.velocity == NORTH) {
      if(canSwap(block.br, block.tr))
        swap(block.br, block.tr);
    }
  }

  if(isMoving(block.tl) && canMoveInBlock(block.tl.velocity, 2)) {
    if(block.tl.velocity == SOUTH) {
      if(canSwap(block.tl, block.bl))
        swap(block.tl, block.bl);
    }

    if(block.tl.velocity == (SOUTH + EAST)) {
      if(canSwap(block.tl, block.br))
        swap(block.tl, block.br);
    }

    if(block.tl.velocity == EAST) {
      if(canSwap(block.tl, block.tr))
        swap(block.tl, block.tr);
    }
  }

  if(isMoving(block.tr) && canMoveInBlock(block.tr.velocity, 3)) {
    if(block.tr.velocity == (SOUTH + WEST)) {
      if(canSwap(block.tr, block.bl))
        swap(block.tr, block.bl);
    }

    if(block.tr.velocity == SOUTH) {
      if(canSwap(block.tr, block.br))
        swap(block.tr, block.br);
    }

    if(block.tr.velocity == WEST) {
      if(canSwap(block.tr, block.tl))
        swap(block.tr, block.tl);
    }
  }

  return block;
}




void main() {
  if(isClicked()) {
    // TODO: velocity on spawn
    int type = u_inputKey;
    int gravity = type == BLOCK || type == EMPTY ? 0 : -1;
    outData = ivec4(type, 0, gravity, DENSITY[type]);
    return;
  }

  ivec2 grid = ivec2(gl_FragCoord.xy);
  ivec2 blockOrigin = getBlockOrigin(grid);

  Block block = getBlock(blockOrigin);
  Block newBlock = applyLogic(block);

  Cell thisCell = getCellFromBlock(grid, newBlock);

  outData = ivec4(
    thisCell.type,
    thisCell.velocity,
    thisCell.density
  );
}
