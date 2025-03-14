void diffuseTemperature(inout Cell a, inout Cell b) {
  if (abs(a.temperature - b.temperature) < 2) return;

  int rateLimit = min(
    MAX_THERMAL_TRANSFER[a.type],
    MAX_THERMAL_TRANSFER[b.type]
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

void transformCellByTemperature(inout Cell cell) {
  int type = cell.type;
  int temperature = cell.temperature;

  if(type == EMPTY) {
    return;
  }

  if(type == BLOCK) {
    return;
  }

  if(type == SAND) {
    if(temperature >= TEMPERATURE_SAND_MELT) {
      return;
    }
  }

  if(type == WATER) {
    if(temperature <= TEMPERATURE_WATER_FREEZE) {
      resetCell(cell);
      cell.type = ICE;
      cell.temperature = temperature;
      cell.velocity = 0;
      return;
    }
    return;
  }

  if(type == ICE) {
    if(temperature > TEMPERATURE_WATER_FREEZE) {
      resetCell(cell);
      cell.type = WATER;
      cell.temperature = temperature;
      cell.velocity = GRAVITY;
      return;
    }
    return;
  }

  if(type == STEAM) {
    if(temperature <= TEMPERATURE_WATER_BOIL) {
      return;
    }
    return;
  }

  if(type == FIRE) {
    return;
  }
}

void applyBlockTemperatureTransform(inout Block block) {
  transformCellByTemperature(block.bl);
  transformCellByTemperature(block.tl);
  transformCellByTemperature(block.tr);
  transformCellByTemperature(block.bl);
}
