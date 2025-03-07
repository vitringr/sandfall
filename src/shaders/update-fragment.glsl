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

const float POINTER_AREA = 0.02;
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



// Maybe because it's biased, and it chooses to spread while falling down?

Block applySwaps(Block block) {
  int spread = SPREAD[block.bl.type];

  if(block.bl.velocity == 0) return block;

  if(block.bl.velocity == LEFT) {
    if(spread >= 2 && canSwap(block.bl, block.tl)) {
      swap(block.bl, block.tl);
      return block;
    }

    if(spread >= 3 && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }

    if(spread >= 4 && canSwap(block.bl, block.br)) {
      swap(block.bl, block.br);
      return block;
    }

    return block;
  }

  if(block.bl.velocity == DOWN) {
    if(spread >= 2 && canSwap(block.bl, block.br)) {
      swap(block.bl, block.br);
      return block;
    }

    if(spread >= 3 && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }

    if(spread >= 4 && canSwap(block.bl, block.tl)) {
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

    if(spread >= 1 && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }

    if(spread >= 2 && canSwap(block.bl, block.tl)) {
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

    if(spread >= 1 && canSwap(block.bl, block.tr)) {
      swap(block.bl, block.tr);
      return block;
    }

    if(spread >= 2 && canSwap(block.bl, block.br)) {
      swap(block.bl, block.br);
      return block;
    }

    return block;
  }

  return block;
}

Block change(Block originalBlock) {
  Block block = originalBlock;

  block = applySwaps(block);

  block = rotateBackBlock(block);
  block = applySwaps(block);
  block = rotateBlock(block);

  block = rotateBackBlock(block);
  block = rotateBackBlock(block);
  block = rotateBackBlock(block);
  block = applySwaps(block);
  block = rotateBlock(block);
  block = rotateBlock(block);
  block = rotateBlock(block);

  block = rotateBackBlock(block);
  block = rotateBackBlock(block);
  block = applySwaps(block);
  block = rotateBlock(block);
  block = rotateBlock(block);

  return block;
}




void main() {
  if(isClicked()) {
    int type = u_inputKey;
    int velocity = DOWN;
    if(type == EMPTY || type == BLOCK) velocity = 0;
    outData = ivec4(type, velocity, 0, 0);
    return;
  }

  ivec2 grid = ivec2(gl_FragCoord.xy);
  ivec2 blockOrigin = getBlockOrigin(grid);

  Block block = getBlock(blockOrigin);
  Block newBlock = change(block);

  Cell thisCell = getCellFromBlock(grid, newBlock);
  outData = ivec4(
    thisCell.type,
    thisCell.velocity,
    thisCell.empty0,
    thisCell.empty1
  );
}
