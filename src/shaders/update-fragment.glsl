#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

in vec2 v_coordinates;

layout(location = 0) out ivec4 outOne;
layout(location = 1) out ivec4 outTwo;

uniform bool u_isPointerDown;
uniform int u_time;
uniform int u_inputKey;
uniform float u_spawnerSize;
uniform vec2 u_pointerPosition;
uniform isampler2D u_inputOneTexture;
uniform isampler2D u_inputTwoTexture;

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

const int LEFT  = 1;
const int DOWN  = 2;
const int RIGHT = 3;
const int UP    = 4;

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
  int id;
  int clock;
  int type;
  int state;

  int velocity;
  int isMoved;
  int heat;
  int empty;
};

struct Block {
  Cell bl;
  Cell tl;
  Cell tr;
  Cell br;
};




Cell getCell(ivec2 grid) {
  ivec4 one = texelFetch(u_inputOneTexture, grid, 0);
  ivec4 two = texelFetch(u_inputTwoTexture, grid, 0);

  Cell cell;

  cell.id       = one.r;
  cell.clock    = one.g;
  cell.type     = one.b;
  cell.state    = one.a;

  cell.velocity = two.r;
  cell.isMoved  = two.g;
  cell.heat     = two.b;
  cell.empty    = two.a;

  return cell;
}

ivec2 getPartition() {
  int modTime = u_time % 8;

  if(modTime == 0) return ivec2( 0,  0);
  if(modTime == 1) return ivec2( 1,  1);
  if(modTime == 2) return ivec2( 0,  0);
  if(modTime == 3) return ivec2( 1, -1);
  if(modTime == 4) return ivec2( 0,  0);
  if(modTime == 5) return ivec2(-1, -1);
  if(modTime == 6) return ivec2( 0,  0);
                   return ivec2(-1,  1);
}

ivec2 getBlockOrigin(ivec2 grid) {
  ivec2 keepAboveZero = ivec2(2, 2);
  ivec2 offset = getPartition();
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
  return distance(u_pointerPosition, v_coordinates) < u_spawnerSize;
}




void swap(inout Cell a, inout Cell b) {
  Cell temp = a;
  a = b;
  b = temp;

  a.isMoved = 1;
  b.isMoved = 1;
}

bool canSwap(Cell a, Cell b) {
  return DENSITY[a.type] > DENSITY[b.type];
}




int rotateVelocity(int velocity) {
  if(velocity == 0) return 0;
  if(velocity >= UP) return LEFT;
  return velocity + 1;
}

int rotateBackVelocity(int velocity) {
  if(velocity == 0) return 0;
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
  Block counterclockwise = block;
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




Block applyVelocityToBL(Block originalBlock) {
  if(originalBlock.bl.isMoved == 1) return originalBlock;
  if(originalBlock.bl.velocity == 0) return originalBlock;

  Block block = originalBlock;

  int spread = SPREAD[block.bl.type];

  if(block.bl.velocity == LEFT) {
    if(spread >= SPREAD_MID && canSwap(block.bl, block.tl)) {
      swap(block.bl, block.tl);
      return block;
    }
    if(spread >= SPREAD_HIGH && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }
    if(spread >= SPREAD_FULL && canSwap(block.bl, block.br)) {
      swap(block.bl, block.br);
      return block;
    }
    return block;
  }

  if(block.bl.velocity == DOWN) {
    if(spread >= SPREAD_MID && canSwap(block.bl, block.br)) {
      swap(block.bl, block.br);
      return block;
    }
    if(spread >= SPREAD_HIGH && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }
    if(spread >= SPREAD_FULL && canSwap(block.bl, block.tl)) {
      swap(block.bl, block.tl);
      return block;
    }
    return block;
  }

  if(block.bl.velocity == RIGHT) {
    if(canSwap(block.bl, block.br)) {
      swap(block.bl, block.br);
      return block;
    }
    if(spread >= SPREAD_LOW && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }
    if(spread >= SPREAD_MID && canSwap(block.bl, block.tl)) {
      swap(block.bl, block.tl);
      return block;
    }
    return block;
  }

  if(block.bl.velocity == UP) {
    if(canSwap(block.bl, block.tl)) {
      swap(block.bl, block.tl);
      return block;
    }
    if(spread >= SPREAD_LOW && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }
    if(spread >= SPREAD_MID && canSwap(block.bl, block.br)) {
      swap(block.bl, block.br);
      return block;
    }
    return block;
  }

  return block;
}

Block applyVelocityToIndex(Block originalBlock, int blockIndex) {
  Block block = originalBlock;

  for(int i = 0; i < blockIndex; i++) {
    block = rotateBlock(block);
  }

  block = applyVelocityToBL(block);

  for(int i = 0; i < blockIndex; i++) {
    block = rotateBackBlock(block);
  }

  return block;
}

Block applyVelocity(Block originalBlock, ivec4 applicationOrder) {
  Block block = originalBlock;
  block = applyVelocityToIndex(block, applicationOrder.r);
  block = applyVelocityToIndex(block, applicationOrder.g);
  block = applyVelocityToIndex(block, applicationOrder.b);
  block = applyVelocityToIndex(block, applicationOrder.a);
  return block;
}

Block changeBlock(Block originalBlock) {
  Block block = originalBlock;

  int modTime = u_time % 4;

  if(modTime == 0)      block = applyVelocity(block, ivec4(2, 0, 1, 3)); // right
  else if(modTime == 1) block = applyVelocity(block, ivec4(1, 3, 2, 0)); // left
  else if(modTime == 2) block = applyVelocity(block, ivec4(0, 1, 3, 2)); // left
  else                  block = applyVelocity(block, ivec4(2, 3, 0, 1)); // right

  block.bl.isMoved = 0;
  block.tl.isMoved = 0;
  block.tr.isMoved = 0;
  block.br.isMoved = 0;

  return block;
}

Cell spawnCell() {
  Cell newCell;

  int type = u_inputKey;

  newCell.id       = 0;
  newCell.clock    = 0;
  newCell.type     = type;
  newCell.state    = 0;

  newCell.velocity = 0;
  newCell.isMoved  = 0;
  newCell.heat     = 0;
  newCell.empty    = 0;

  if(type == SAND || type == WATER) newCell.velocity = DOWN;
  if(type == FIRE || type == STEAM) newCell.velocity = UP;

  return newCell;
}

void writeCellFragment(Cell cell, out ivec4 outOne, out ivec4 outTwo) {
  outOne = ivec4(
    cell.id,
    cell.clock,
    cell.type,
    cell.state
  );

  outTwo = ivec4(
    cell.velocity,
    cell.isMoved,
    cell.heat,
    cell.empty
  );
}

void main() {
  if(isClicked()) {
    Cell newCell = spawnCell();
    writeCellFragment(newCell, outOne, outTwo);
    return;
  }

  ivec2 grid = ivec2(gl_FragCoord.xy);
  ivec2 blockOrigin = getBlockOrigin(grid);

  Block block = getBlock(blockOrigin);
  block = changeBlock(block);

  Cell thisCell = getCellFromBlock(grid, block);

  // thisCell.heat++;
  // if(thisCell.heat > 10) thisCell.velocity = 0;

  writeCellFragment(thisCell, outOne, outTwo);
}

