Cell getCell(ivec2 grid) {
  // TODO: WIP
  uvec4 data0 = uvec4(texelFetch(u_inputTexture0, grid, 0));
  uvec4 data1 = uvec4(texelFetch(u_inputTexture1, grid, 0));
  uvec4 data2 = uvec4(texelFetch(u_inputTexture2, grid, 0));

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
  uint modTime = u_time % 8u;

  if(modTime == 0u) return ivec2( 0,  0);
  if(modTime == 1u) return ivec2( 1,  1);
  if(modTime == 2u) return ivec2( 0,  0);
  if(modTime == 3u) return ivec2( 1, -1);
  if(modTime == 4u) return ivec2( 0,  0);
  if(modTime == 5u) return ivec2(-1, -1);
  if(modTime == 6u) return ivec2( 0,  0);
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
