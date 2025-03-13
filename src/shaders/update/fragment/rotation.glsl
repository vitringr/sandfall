uint rotateVelocity(uint velocity) {
  if(velocity == 0u) return 0u;
  if(velocity >= UP) return LEFT;
  return velocity + 1u;
}

uint reverseRotateVelocity(uint velocity) {
  if(velocity == 0u) return 0u;
  if(velocity == LEFT) return UP;
  return velocity - 1u;
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
