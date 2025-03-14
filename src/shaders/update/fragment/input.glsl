bool isClicked() {
  if(u_inputKey < 0) return false;
  return distance(u_pointerPosition, v_coordinates) < u_spawnerSize;
}

Cell spawnCell(ivec2 grid) {
  // TODO: this, but AFTER static rng
  // if(type != EMPTY && type != BLOCK) {
  //   if(cell.rng < 30) return cell;
  // }

  Cell cell = getCell(grid);

  int type = u_inputKey;

  resetCell(cell);
  cell.type = type;

  if(type == SAND || type == WATER) cell.velocity = DOWN;
  if(type == FIRE || type == STEAM) cell.velocity = UP;

  if(type == SAND) cell.temperature = 0;

  // TEST
  if(u_inputKey == 4) cell.temperature = 2000;

  return cell;
}
