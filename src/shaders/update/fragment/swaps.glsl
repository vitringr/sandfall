bool canSwap(Cell a, Cell b) {
  if(a.type == b.type) {
    if(a.type == WATER || a.type == STEAM || a.type == FIRE)
      return DENSITY[a.type] >= DENSITY[b.type];
  }

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
  if(block.bl.type == DEBUG) return;
  if(block.bl.isMoved == 1) return;
  if(block.bl.velocity == 0) return;

  int spread = SPREAD[block.bl.type];

  // TODO: should those be if or else-if?

  if(block.bl.velocity == LEFT) {
    if(spread >= SPREAD_MID && canSwap(block.bl, block.tl)) 
      swapCells(block.bl, block.tl);
    if(spread >= SPREAD_HIGH && canSwap(block.bl, block.tr))
      swapCells(block.bl, block.tr);
    if(spread >= SPREAD_FULL && canSwap(block.bl, block.br))
      swapCells(block.bl, block.br);
  }

  if(block.bl.velocity == DOWN) {
    if(spread >= SPREAD_MID && canSwap(block.bl, block.br)) 
      swapCells(block.bl, block.br);
    if(spread >= SPREAD_HIGH && canSwap(block.bl, block.tr)) 
      swapCells(block.bl, block.tr);
    if(spread >= SPREAD_FULL && canSwap(block.bl, block.tl)) 
      swapCells(block.bl, block.tl);
  }

  if(block.bl.velocity == RIGHT) {
    if(canSwap(block.bl, block.br)) 
      swapCells(block.bl, block.br);
    if(spread >= SPREAD_LOW && canSwap(block.bl, block.tr)) 
      swapCells(block.bl, block.tr);
    if(spread >= SPREAD_MID && canSwap(block.bl, block.tl)) 
      swapCells(block.bl, block.tl);
  }

  if(block.bl.velocity == UP) {
    if(canSwap(block.bl, block.tl)) 
      swapCells(block.bl, block.tl);
    if(spread >= SPREAD_LOW && canSwap(block.bl, block.tr)) 
      swapCells(block.bl, block.tr);
    if(spread >= SPREAD_MID && canSwap(block.bl, block.br)) 
      swapCells(block.bl, block.br);
  }
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
