#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;

in vec2 v_coordinates;

layout(location = 0) out ivec4 output0;
layout(location = 1) out ivec4 output1;
layout(location = 2) out ivec4 output2;

uniform isampler2D u_inputTexture0;
uniform isampler2D u_inputTexture1;
uniform isampler2D u_inputTexture2;

uniform bool u_isPointerDown;
uniform int u_time;
uniform int u_inputKey;
uniform float u_spawnerSize;
uniform vec2 u_pointerPosition;

const int EMPTY    = 0;
const int BLOCK    = 1;
const int SAND     = 2;
const int WATER    = 3;
const int FIRE     = 4;
const int STEAM    = 5;

const int INTERACTION_NONE           = 0;
const int INTERACTION_SAND_AND_SAND  = 1;
const int INTERACTION_SAND_AND_WATER = 2;

const int DENSITY[6] = int[6](
  /* EMPTY */    0,
  /* BLOCK */    5,
  /* SAND  */    4,
  /* WATER */    3,
  /* FIRE  */    1,
  /* STEAM */    2
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
  /* EMPTY */    -1,
  /* BLOCK */    -1,
  /* SAND  */    SPREAD_LOW,
  /* WATER */    SPREAD_MID,
  /* FIRE  */    SPREAD_HIGH,
  /* STEAM */    SPREAD_HIGH
);




struct Cell {
  int rng;
  int clock;
  int empty0;
  int empty1;

  int type;
  int heat;
  int velocity;
  int isMoved;

  int state0;
  int state1;
  int state2;
  int state3;
};

struct Block {
  Cell bl;
  Cell tl;
  Cell tr;
  Cell br;
};




Cell getCell(ivec2 grid) {
  ivec4 data0 = texelFetch(u_inputTexture0, grid, 0);
  ivec4 data1 = texelFetch(u_inputTexture1, grid, 0);
  ivec4 data2 = texelFetch(u_inputTexture2, grid, 0);

  Cell cell;

  cell.rng      = data0.r;
  cell.clock    = data0.g;
  cell.empty0   = data0.b;
  cell.empty1   = data0.a;

  cell.type     = data1.r;
  cell.heat     = data1.g;
  cell.velocity = data1.b;
  cell.isMoved  = data1.a;

  cell.state0   = data2.r;
  cell.state1   = data2.g;
  cell.state2   = data2.b;
  cell.state3   = data2.a;

  return cell;
}

Cell resetCell(Cell originalCell) {
  Cell cell = originalCell;

  cell.rng      = originalCell.rng;
  cell.clock    = 0;
  cell.empty0   = 0;
  cell.empty1   = 0;

  cell.type     = EMPTY;
  cell.heat     = 0;
  cell.velocity = 0;
  cell.isMoved  = 0;

  cell.state0   = 0;
  cell.state1   = 0;
  cell.state2   = 0;
  cell.state3   = 0;

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




int getInteraction(int aType, int bType) {
  if(aType == EMPTY) {
    return INTERACTION_NONE;
  }

  else if(aType == BLOCK) {
    return INTERACTION_NONE;
  }

  else if(aType == SAND) {
    if(bType == SAND) return INTERACTION_SAND_AND_SAND;
    if(bType == WATER) return INTERACTION_SAND_AND_WATER;
    return INTERACTION_NONE;
  }

  else if(aType == WATER) {
    return INTERACTION_NONE;
  }

  else if(aType == FIRE) {
    return INTERACTION_NONE;
  }

  else if(aType == STEAM) {
    return INTERACTION_NONE;
  }

  return INTERACTION_NONE;
}

void sandAndWater(inout Cell sand, inout Cell water) {
  int maxSandSoak = 10; // TODO: magic
  if(sand.state0 >= maxSandSoak) return;

  sand.state0++; // increase soak

  water = resetCell(water);
}

void entropy(inout int a, inout int b) {
  if(abs(a- b) < 2) return;

  int total= a+ b;
  int aNew = 0;
  int bNew = 0;

  if(a> b) {
    aNew = (total+ 1) / 2;
    bNew = total- aNew;
  }
  else {
    bNew = (total+ 1) / 2;
    aNew = total- bNew;
  }

  a = aNew;
  b = bNew;
}

void sandAndSand(inout Cell a, inout Cell b) {
  entropy(a.state0, b.state0);
}

void applyInteraction(inout Cell one, inout Cell two) {
  int interaction = getInteraction(one.type, two.type);

  if(interaction == INTERACTION_NONE) return;

  if(interaction == INTERACTION_SAND_AND_WATER) {
    sandAndWater(one, two);
    return;
  }

  if(interaction == INTERACTION_SAND_AND_SAND) {
    sandAndSand(one, two);
    return;
  }
}




Block changeBlock(Block originalBlock) {
  Block block = originalBlock;

  if(block.bl.type <= block.tl.type) applyInteraction(block.bl, block.tl);
  else                               applyInteraction(block.tl, block.bl);

  if(block.tl.type <= block.tr.type) applyInteraction(block.tl, block.tr);
  else                               applyInteraction(block.tr, block.tl);

  if(block.tr.type <= block.br.type) applyInteraction(block.tr, block.br);
  else                               applyInteraction(block.br, block.tr);

  if(block.br.type <= block.bl.type) applyInteraction(block.br, block.bl);
  else                               applyInteraction(block.bl, block.br);

  int modTime = u_time % 4;
  if     (modTime == 0) block = applyVelocity(block, ivec4(2, 0, 1, 3));
  else if(modTime == 1) block = applyVelocity(block, ivec4(1, 3, 2, 0));
  else if(modTime == 2) block = applyVelocity(block, ivec4(0, 1, 3, 2));
  else                  block = applyVelocity(block, ivec4(2, 3, 0, 1));

  block.bl.isMoved =
  block.tl.isMoved =
  block.tr.isMoved =
  block.br.isMoved = 0;

  return block;
}




Cell spawnCell(ivec2 grid) {
  // TODO: this, but AFTER static rng
  // if(type != EMPTY && type != BLOCK) {
  //   if(cell.rng < 30) return cell;
  // }
  Cell cell = getCell(grid);

  int type = u_inputKey;

  cell = resetCell(cell);
  cell.type = type;

  if(type == SAND || type == WATER) cell.velocity = DOWN;
  if(type == FIRE || type == STEAM) cell.velocity = UP;

  return cell;
}

void writeCellFragment(Cell cell, out ivec4 output0, out ivec4 output1, out ivec4 output2) {
  output0 = ivec4(
    cell.rng,
    cell.clock,
    cell.empty0,
    cell.empty1
  );

  output1 = ivec4(
    cell.type,
    cell.heat,
    cell.velocity,
    cell.isMoved
  );

  output2 = ivec4(
    cell.state0,
    cell.state1,
    cell.state2,
    cell.state3
  );
}

void main() {
  ivec2 grid = ivec2(gl_FragCoord.xy);

  if(isClicked()) {
    writeCellFragment(spawnCell(grid), output0, output1, output2);
    return;
  }

  ivec2 blockOrigin = getBlockOrigin(grid);

  Block block = getBlock(blockOrigin);
  block = changeBlock(block);

  Cell thisCell = getCellFromBlock(grid, block);

  thisCell.clock++;

  writeCellFragment(thisCell, output0, output1, output2);
}
