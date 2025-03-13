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

  uint modTime = u_time % 4u;

  if     (modTime == 0u) applyBlockSwaps(block, ivec4(2, 0, 1, 3));
  else if(modTime == 1u) applyBlockSwaps(block, ivec4(1, 3, 2, 0));
  else if(modTime == 2u) applyBlockSwaps(block, ivec4(0, 1, 3, 2));
  else                   applyBlockSwaps(block, ivec4(2, 3, 0, 1));

  if     (modTime == 0u) applyBlockTemperatureDiffusion(block, ivec4(2, 0, 1, 3));
  else if(modTime == 1u) applyBlockTemperatureDiffusion(block, ivec4(1, 3, 2, 0));
  else if(modTime == 2u) applyBlockTemperatureDiffusion(block, ivec4(0, 1, 3, 2));
  else                   applyBlockTemperatureDiffusion(block, ivec4(2, 3, 0, 1));

  block.bl.isMoved = block.tl.isMoved = block.tr.isMoved = block.br.isMoved = 0u;
}
