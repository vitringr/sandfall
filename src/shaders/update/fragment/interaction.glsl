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
    return INTERACTION_NONE;
  }

  if(aType == ICE) {
    return INTERACTION_NONE;
  }

  if(aType == STEAM) {
    return INTERACTION_NONE;
  }

  if(aType == FIRE) {
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
}
