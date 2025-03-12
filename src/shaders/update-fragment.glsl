#version 300 es
precision highp int;
precision highp float;
precision highp isampler2D;




// DATA

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
uniform int u_maxSoakedCells;
uniform int u_soakPerAbsorb;
uniform float u_spawnerSize;
uniform vec2 u_pointerPosition;




// ENUM

const int EMPTY = 0;
const int BLOCK = 1;
const int SAND  = 2;
const int WATER = 3;
const int FIRE  = 4;
const int STEAM = 5;

const int LEFT  = 1;
const int DOWN  = 2;
const int RIGHT = 3;
const int UP    = 4;

const int SPREAD_NONE = 0;
const int SPREAD_LOW  = 1;
const int SPREAD_MID  = 2;
const int SPREAD_HIGH = 3;
const int SPREAD_FULL = 4;

const int INTERACTION_NONE            = 0;
const int INTERACTION_BLOCK_AND_BLOCK = 1;
const int INTERACTION_BLOCK_AND_SAND  = 2;
const int INTERACTION_BLOCK_AND_WATER = 3;
const int INTERACTION_SAND_AND_SAND   = 4;
const int INTERACTION_SAND_AND_WATER  = 5;
const int INTERACTION_WATER_AND_WATER = 6;




// CONFIG

const int DENSITY[6] = int[6](
  0, // Empty
  5, // Block
  4, // Sand
  3, // Water
  1, // Fire
  2  // Steam
);

const int MAX_TEMPERATURE_TRANSFER[6] = int[6](
  0,  // Empty
  10, // Block
  50, // Sand
  50, // Water
  0,  // Fire
  0   // Steam
);

const int SPREAD[6] = int[6](
  -1,          // Empty
  -1,          // Block
  SPREAD_LOW,  // Sand
  SPREAD_MID,  // Water
  SPREAD_HIGH, // Fire
  SPREAD_HIGH  // Steam
);




// STRUCTURE

struct Cell {
  int rng;
  int clock;
  int empty0;
  int empty1;

  int type;
  int temperature;
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




// FETCH

Cell getCell(ivec2 grid) {
  ivec4 data0 = texelFetch(u_inputTexture0, grid, 0);
  ivec4 data1 = texelFetch(u_inputTexture1, grid, 0);
  ivec4 data2 = texelFetch(u_inputTexture2, grid, 0);

  Cell cell;

  cell.rng         = data0.r;
  cell.clock       = data0.g;
  cell.empty0      = data0.b;
  cell.empty1      = data0.a;

  cell.type        = data1.r;
  cell.temperature = data1.g;
  cell.velocity    = data1.b;
  cell.isMoved     = data1.a;

  cell.state0      = data2.r;
  cell.state1      = data2.g;
  cell.state2      = data2.b;
  cell.state3      = data2.a;

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




// MISC

void resetCell(inout Cell cell) {
  // cell.rng;
  cell.clock       = 0;
  cell.empty0      = 0;
  cell.empty1      = 0;

  cell.type        = EMPTY;
  cell.temperature = 0;
  cell.velocity    = 0;
  cell.isMoved     = 0;

  cell.state0      = 0;
  cell.state1      = 0;
  cell.state2      = 0;
  cell.state3      = 0;
}

void balanceValues(inout int a, inout int b) {
  if(abs(a - b) < 2) return;

  int total = a + b;
  int aNew = 0;
  int bNew = 0;

  if(a > b) {
    aNew = (total + 1) / 2;
    bNew = total - aNew;
  }
  else {
    bNew = (total + 1) / 2;
    aNew = total - bNew;
  }

  a = aNew;
  b = bNew;
}




// ROTATION

int rotateVelocity(int velocity) {
  if(velocity == 0) return 0;
  if(velocity >= UP) return LEFT;
  return velocity + 1;
}

int reverseRotateVelocity(int velocity) {
  if(velocity == 0) return 0;
  if(velocity == LEFT) return UP;
  return velocity - 1;
}

void rotateBlock(inout Block block) {
  Block originalBlock = block;

  block.bl = originalBlock.tl;
  block.bl.velocity = rotateVelocity(block.bl.velocity);

  block.tl = originalBlock.tr;
  block.tl.velocity = rotateVelocity(block.tl.velocity);

  block.tr = originalBlock.br;
  block.tr.velocity = rotateVelocity(block.tr.velocity);

  block.br = originalBlock.bl;
  block.br.velocity = rotateVelocity(block.br.velocity);
}

void reverseRotateBlock(inout Block block) {
  Block originalBlock = block;

  block.bl = originalBlock.br;
  block.bl.velocity = reverseRotateVelocity(block.bl.velocity);

  block.tl = originalBlock.bl;
  block.tl.velocity = reverseRotateVelocity(block.tl.velocity);

  block.tr = originalBlock.tl;
  block.tr.velocity = reverseRotateVelocity(block.tr.velocity);

  block.br = originalBlock.tr;
  block.br.velocity = reverseRotateVelocity(block.br.velocity);
}




// INTERACTION

int getInteraction(int aType, int bType) {
  if(aType == EMPTY) {
    return INTERACTION_NONE;
  }

  if(aType == BLOCK) {
    if(bType == BLOCK) return INTERACTION_BLOCK_AND_BLOCK;
    if(bType == SAND) return INTERACTION_BLOCK_AND_SAND;
    if(bType == WATER) return INTERACTION_BLOCK_AND_WATER;
    return INTERACTION_NONE;
  }

  if(aType == SAND) {
    if(bType == SAND) return INTERACTION_SAND_AND_SAND;
    if(bType == WATER) return INTERACTION_SAND_AND_WATER;
    return INTERACTION_NONE;
  }

  if(aType == WATER) {
    if(bType == WATER) return INTERACTION_WATER_AND_WATER;
    return INTERACTION_NONE;
  }

  if(aType == FIRE) {
    return INTERACTION_NONE;
  }

  if(aType == STEAM) {
    return INTERACTION_NONE;
  }

  return INTERACTION_NONE;
}

void blockAndBlock(inout Cell a, inout Cell b) { }

void blockAndSand(inout Cell block, inout Cell sand) { }

void blockAndWater(inout Cell block, inout Cell water) { }

void sandAndWater(inout Cell sand, inout Cell water) {
  if(sand.state0 < u_soakPerAbsorb * u_maxSoakedCells) {
    balanceValues(sand.temperature, water.temperature);

    sand.state0 += u_soakPerAbsorb;

    resetCell(water);

    return;
  }
}

void sandAndSand(inout Cell a, inout Cell b) {
  balanceValues(a.state0, b.state0);
}

void waterAndWater(inout Cell a, inout Cell b) { }

void applyInteraction(inout Cell one, inout Cell two) {
  int interaction = getInteraction(one.type, two.type);

  if(interaction == INTERACTION_NONE) return;

  if(interaction == INTERACTION_BLOCK_AND_BLOCK) {
    blockAndBlock(one, two);
    return;
  }

  if(interaction == INTERACTION_BLOCK_AND_SAND) {
    blockAndSand(one, two);
    return;
  }

  if(interaction == INTERACTION_BLOCK_AND_WATER) {
    blockAndWater(one, two);
    return;
  }

  if(interaction == INTERACTION_SAND_AND_WATER) {
    sandAndWater(one, two);
    return;
  }

  if(interaction == INTERACTION_SAND_AND_SAND) {
    sandAndSand(one, two);
    return;
  }

  if(interaction == INTERACTION_WATER_AND_WATER) {
    waterAndWater(one, two);
    return;
  }
}




// SWAPS

bool canSwap(Cell a, Cell b) {
  return DENSITY[a.type] > DENSITY[b.type];
}

void swapCells(inout Cell a, inout Cell b) {
  Cell temp = a;
  a = b;
  b = temp;

  a.isMoved = 1;
  b.isMoved = 1;
}

void applySwapsToBL(inout Block block) {
  if(block.bl.isMoved == 1) return;
  if(block.bl.velocity == 0) return;

  int spread = SPREAD[block.bl.type];

  // TODO: should those be if or else-if?

  if(block.bl.velocity == LEFT) {
    if(spread >= SPREAD_MID && canSwap(block.bl, block.tl)) {
      swapCells(block.bl, block.tl);
      return;
    }
    if(spread >= SPREAD_HIGH && canSwap(block.bl, block.tr)) {
      swapCells(block.bl, block.tr);
      return;
    }
    if(spread >= SPREAD_FULL && canSwap(block.bl, block.br)) {
      swapCells(block.bl, block.br);
      return;
    }
    return;
  }

  if(block.bl.velocity == DOWN) {
    if(spread >= SPREAD_MID && canSwap(block.bl, block.br)) {
      swapCells(block.bl, block.br);
      return;
    }
    if(spread >= SPREAD_HIGH && canSwap(block.bl, block.tr)) {
      swapCells(block.bl, block.tr);
      return;
    }
    if(spread >= SPREAD_FULL && canSwap(block.bl, block.tl)) {
      swapCells(block.bl, block.tl);
      return;
    }
    return;
  }

  if(block.bl.velocity == RIGHT) {
    if(canSwap(block.bl, block.br)) {
      swapCells(block.bl, block.br);
      return;
    }
    if(spread >= SPREAD_LOW && canSwap(block.bl, block.tr)) {
      swapCells(block.bl, block.tr);
      return;
    }
    if(spread >= SPREAD_MID && canSwap(block.bl, block.tl)) {
      swapCells(block.bl, block.tl);
      return;
    }
    return;
  }

  if(block.bl.velocity == UP) {
    if(canSwap(block.bl, block.tl)) {
      swapCells(block.bl, block.tl);
      return;
    }
    if(spread >= SPREAD_LOW && canSwap(block.bl, block.tr)) {
      swapCells(block.bl, block.tr);
      return;
    }
    if(spread >= SPREAD_MID && canSwap(block.bl, block.br)) {
      swapCells(block.bl, block.br);
      return;
    }
    return;
  }

  return;
}

void applySwapsToIndex(inout Block block, int blockIndex) {
  for(int i = 0; i < blockIndex; i++) {
    rotateBlock(block);
  }

  applySwapsToBL(block);

  for(int i = 0; i < blockIndex; i++) {
    reverseRotateBlock(block);
  }
}

void applyBlockSwaps(inout Block block, ivec4 applicationOrder) {
  applySwapsToIndex(block, applicationOrder.r);
  applySwapsToIndex(block, applicationOrder.g);
  applySwapsToIndex(block, applicationOrder.b);
  applySwapsToIndex(block, applicationOrder.a);
}




// TEMPERATURE

void diffuseTemperature(inout Cell a, inout Cell b) {
  if (abs(a.temperature - b.temperature) < 2) return;

  int rateLimit = min(
    MAX_TEMPERATURE_TRANSFER[a.type],
    MAX_TEMPERATURE_TRANSFER[b.type]
  );

  if (a.temperature > b.temperature) {
    int diff = a.temperature - b.temperature;
    int idealTransfer = diff / 2;
    int transfer = min(idealTransfer, rateLimit);
    a.temperature -= transfer;
    b.temperature += transfer;
  } else {
    int diff = b.temperature - a.temperature;
    int idealTransfer = diff / 2;
    int transfer = min(idealTransfer, rateLimit);
    b.temperature -= transfer;
    a.temperature += transfer;
  }
}

void applyBlockTemperatureDiffusion(inout Block block, ivec4 applicationOrder) {
  for(int i = 0; i < 4; i++) {
    if     (applicationOrder[i] == 0) diffuseTemperature(block.bl, block.tl);
    else if(applicationOrder[i] == 1) diffuseTemperature(block.tl, block.tr);
    else if(applicationOrder[i] == 2) diffuseTemperature(block.tr, block.br);
    else                              diffuseTemperature(block.br, block.bl);
  }

  diffuseTemperature(block.br, block.tl);
  diffuseTemperature(block.bl, block.tr);
}




// LOGIC

void changeBlock(inout Block block) {
  if(block.bl.type <= block.tl.type) applyInteraction(block.bl, block.tl);
  else                               applyInteraction(block.tl, block.bl);

  if(block.tl.type <= block.tr.type) applyInteraction(block.tl, block.tr);
  else                               applyInteraction(block.tr, block.tl);

  if(block.tr.type <= block.br.type) applyInteraction(block.tr, block.br);
  else                               applyInteraction(block.br, block.tr);

  if(block.br.type <= block.bl.type) applyInteraction(block.br, block.bl);
  else                               applyInteraction(block.bl, block.br);

  if(block.bl.type <= block.tr.type) applyInteraction(block.bl, block.tr);
  else                               applyInteraction(block.tr, block.bl);

  if(block.tl.type <= block.br.type) applyInteraction(block.tl, block.br);
  else                               applyInteraction(block.br, block.tl);

  int modTime = u_time % 4;

  if     (modTime == 0) applyBlockSwaps(block, ivec4(2, 0, 1, 3));
  else if(modTime == 1) applyBlockSwaps(block, ivec4(1, 3, 2, 0));
  else if(modTime == 2) applyBlockSwaps(block, ivec4(0, 1, 3, 2));
  else                  applyBlockSwaps(block, ivec4(2, 3, 0, 1));

  if     (modTime == 0) applyBlockTemperatureDiffusion(block, ivec4(2, 0, 1, 3));
  else if(modTime == 1) applyBlockTemperatureDiffusion(block, ivec4(1, 3, 2, 0));
  else if(modTime == 2) applyBlockTemperatureDiffusion(block, ivec4(0, 1, 3, 2));
  else                  applyBlockTemperatureDiffusion(block, ivec4(2, 3, 0, 1));

  block.bl.isMoved = block.tl.isMoved = block.tr.isMoved = block.br.isMoved = 0;
}




// INPUT

bool isClicked() {
  if(u_inputKey < 0) return false;
  return distance(u_pointerPosition, v_coordinates) < u_spawnerSize;
}

Cell spawnCell(ivec2 grid) {
  // TODO: this, but AFTER static rng
  // if(type != EMPTY && type != BLOCK) {
  //   if(cell.rng < 30) return cell;
  // }

  Cell cell = getCell(grid);

  int type = u_inputKey;
  // TEST
  if(u_inputKey == 4) type = SAND;

  resetCell(cell);
  cell.type = type;

  if(type == SAND || type == WATER) cell.velocity = DOWN;
  if(type == FIRE || type == STEAM) cell.velocity = UP;

  if(type == SAND) cell.temperature = 0;
  // TEST
  if(u_inputKey == 4) cell.temperature = 2000;

  return cell;
}



// OUTPUT

void writeCellFragment(Cell cell, out ivec4 output0, out ivec4 output1, out ivec4 output2) {
  output0 = ivec4(
    cell.rng,
    cell.clock,
    cell.empty0,
    cell.empty1
  );

  output1 = ivec4(
    cell.type,
    cell.temperature,
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

  changeBlock(block);

  Cell thisCell = getCellFromBlock(grid, block);

  thisCell.clock++;

  writeCellFragment(thisCell, output0, output1, output2);
}
