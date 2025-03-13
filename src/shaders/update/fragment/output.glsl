void writeCellFragment(Cell cell, out uvec4 output0, out uvec4 output1, out uvec4 output2) {
  output0 = uvec4(
    cell.rng,
    cell.clock,
    cell.empty0,
    cell.empty1
  );

  output1 = uvec4(
    cell.type,
    cell.temperature,
    cell.velocity,
    cell.isMoved
  );

  output2 = uvec4(
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
