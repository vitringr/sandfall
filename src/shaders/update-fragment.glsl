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

const float POINTER_AREA = 0.03;
const ivec2 PARTITION_OFFSET = ivec2(1, 1);

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;

const int DENSITY[6] = int[6](
  /* EMPTY */ 0,
  /* BLOCK */ 5,
  /* SAND  */ 4,
  /* WATER */ 3,
  /* FIRE  */ 1,
  /* STEAM */ 2
);

const int LEFT          = 1;
const int DOWN          = 2;
const int RIGHT         = 3;
const int UP            = 4;

const int SPREAD_NONE = 0;
const int SPREAD_LOW  = 1;
const int SPREAD_MID  = 2;
const int SPREAD_HIGH = 3;
const int SPREAD_FULL = 4;

const int SPREAD[6] = int[6](
  /* EMPTY */ -1,
  /* BLOCK */ -1,
  /* SAND  */ SPREAD_LOW,
  /* WATER */ SPREAD_MID,
  /* FIRE  */ SPREAD_HIGH,
  /* STEAM */ SPREAD_HIGH
);




struct Cell {
  int type;
  int velocity;
  int empty0;
  int empty1;
};

struct Block {
  Cell bl;
  Cell tl;
  Cell tr;
  Cell br;
};




Cell getCell(ivec2 grid) {
  ivec4 state = texelFetch(u_inputTextureIndex, grid, 0);

  Cell cell;
  cell.type     = state.r;
  cell.velocity = state.g;
  cell.empty0   = state.b;
  cell.empty1   = state.a;

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
  block.bl = getCell(origin);               // index: 0
  block.tl = getCell(origin + ivec2(0, 1)); // index: 1
  block.tr = getCell(origin + ivec2(1, 1)); // index: 2
  block.br = getCell(origin + ivec2(1, 0)); // index: 3

  return block;
}

int getInBlockIndex(ivec2 grid) {
  ivec2 blockOrigin = getBlockOrigin(grid);

  ivec2 remainder = grid - blockOrigin;

  return (1 - remainder.x) * remainder.y + remainder.x * (3 - remainder.y);
}

Cell getCellFromBlock(ivec2 grid, Block block) {
  int inBlockIndex = getInBlockIndex(grid);

  if(inBlockIndex == 0) return block.bl;
  if(inBlockIndex == 1) return block.tl;
  if(inBlockIndex == 2) return block.tr;
  if(inBlockIndex == 3) return block.br;
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
  return cell.velocity > 0;
}

bool canMoveInBlock(int velocity, int inBlockIndex) {
  if(inBlockIndex == 0) return velocity == RIGHT || velocity == UP;   // bl
  if(inBlockIndex == 1) return velocity == RIGHT || velocity == DOWN; // tl
  if(inBlockIndex == 2) return velocity == LEFT  || velocity == DOWN; // tr
  if(inBlockIndex == 3) return velocity == LEFT  || velocity == UP;   // br
}

bool canSwap(Cell a, Cell b) {
  return DENSITY[a.type] > DENSITY[b.type];
}




int rotateVelocity(int velocity) {
  if(velocity == 0) return 0;
  // left => down
  // down => right
  // right => up
  // up => left
  if(velocity >= UP) return LEFT;
  return velocity + 1;
}

int rotateBackVelocity(int velocity) {
  if(velocity == 0) return 0;
  // up => right
  // right => down
  // down => left
  // left => up
  if(velocity == LEFT) return UP;
  return velocity - 1;
}

Cell rotateCell(Cell cell) {
  Cell counterclockwise = cell;

  counterclockwise.velocity = rotateVelocity(cell.velocity);

  return counterclockwise;
}

Cell rotateBackCell(Cell cell) {
  Cell clockwise = cell;

  clockwise.velocity = rotateBackVelocity(cell.velocity);

  return clockwise;
}

Block rotateBlock(Block block) {
  Block counterclockwise;
  counterclockwise.bl = rotateCell(block.tl);
  counterclockwise.tl = rotateCell(block.tr);
  counterclockwise.tr = rotateCell(block.br);
  counterclockwise.br = rotateCell(block.bl);

  return counterclockwise;
}

Block rotateBackBlock(Block block) {
  Block clockwise;
  clockwise.bl = rotateBackCell(block.br);
  clockwise.tl = rotateBackCell(block.bl);
  clockwise.tr = rotateBackCell(block.tl);
  clockwise.br = rotateBackCell(block.tr);

  return clockwise;
}




// Block asd(Block block, Cell cell, int inBlockIndex) {
//   if(!isMoving(cell)) return block;
//   if(!canMoveInBlock(cell.velocity, inBlockIndex)) return block;
// }

Block applyVelocity(Block originalBlock) {
  Block block = originalBlock;

  // asd(block, block.bl, 0);

  if(isMoving(block.bl) && canMoveInBlock(block.bl.velocity, 0)) {
    if(block.bl.velocity == RIGHT) {
      if(canSwap(block.bl, block.br)) swap(block.bl, block.br);
      else if(canSwap(block.bl, block.tr)) swap(block.bl, block.tr);
    }
    else if(block.bl.velocity == UP) {
      if(canSwap(block.bl, block.tl)) swap(block.bl, block.tl);
      else if(canSwap(block.bl, block.tr)) swap(block.bl, block.tr);
    }
  }

  if(isMoving(block.tl) && canMoveInBlock(block.tl.velocity, 1)) {
    if(block.tl.velocity == DOWN) {
      if(canSwap(block.tl, block.bl)) swap(block.tl, block.bl);
      else if(canSwap(block.tl, block.br)) swap(block.tl, block.br);
    }
    else if(block.tl.velocity == RIGHT) {
      if(canSwap(block.tl, block.tr)) swap(block.tl, block.tr);
      else if(canSwap(block.tl, block.br)) swap(block.tl, block.br);
    }
  }

  if(isMoving(block.tr) && canMoveInBlock(block.tr.velocity, 2)) {
    if(block.tr.velocity == DOWN) {
      if(canSwap(block.tr, block.br)) swap(block.tr, block.br);
      else if(canSwap(block.tr, block.bl)) swap(block.tr, block.bl);
    }
    else if(block.tr.velocity == LEFT) {
      if(canSwap(block.tr, block.tl)) swap(block.tr, block.tl);
      else if(canSwap(block.tr, block.bl)) swap(block.tr, block.bl);
    }
  }

  if(isMoving(block.br) && canMoveInBlock(block.br.velocity, 3)) {
    if(block.br.velocity == LEFT) {
      if(canSwap(block.br, block.bl)) swap(block.br, block.bl);
      else if(canSwap(block.br, block.tl)) swap(block.br, block.tl);
    }
    else if(block.br.velocity == UP) {
      if(canSwap(block.br, block.tr)) swap(block.br, block.tr);
      else if(canSwap(block.br, block.tl)) swap(block.br, block.tl);
    }
  }

  return block;
}




void main() {
  if(isClicked()) {
    int type = u_inputKey;
    int gravity = type == BLOCK || type == EMPTY ? 0 : DOWN;
    outData = ivec4(type, gravity, 0, 0);
    return;
  }

  ivec2 grid = ivec2(gl_FragCoord.xy);
  ivec2 blockOrigin = getBlockOrigin(grid);

  Block block = getBlock(blockOrigin);

  Block newBlock = applyVelocity(block);

  Block rotation1 = rotateBlock(newBlock);
  Block rotation2 = rotateBlock(rotation1);
  Block rotation3 = rotateBlock(rotation2);
  Block rotation4 = rotateBlock(rotation3);

  Cell thisCell = getCellFromBlock(grid, rotation4);

  outData = ivec4(
    thisCell.type,
    thisCell.velocity,
    thisCell.empty0,
    thisCell.empty1
  );
}
