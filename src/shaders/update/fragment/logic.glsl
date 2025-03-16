const ivec4 APPLICATION_PATTERNS[4] = ivec4[4] (
  ivec4(2, 0, 1, 3),
  ivec4(1, 3, 2, 0),
  ivec4(0, 1, 3, 2),
  ivec4(2, 3, 0, 1)
);

ivec4 getRandomApplicationPattern() {
  return APPLICATION_PATTERNS[u_random % 4];
}

void changeBlock(inout Block block) {
  applyBlockTemperatureTransform(block);

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

  ivec4 randomApplicationPattern = getRandomApplicationPattern();
  applyBlockSwaps(block, randomApplicationPattern);

  block.bl.isMoved = block.tl.isMoved = block.tr.isMoved = block.br.isMoved = 0;

  applyBlockTemperatureDiffusion(block, randomApplicationPattern);
}
