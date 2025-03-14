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
