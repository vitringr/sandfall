bool isClicked() {
  if(u_inputKey == 0u) return false;
  return distance(u_pointerPosition, v_coordinates) < u_spawnerSize;
}

Cell spawnCell(ivec2 grid) {
  // TODO: this, but AFTER static rng
  // if(type != EMPTY && type != BLOCK) {
  //   if(cell.rng < 30) return cell;
  // }

  Cell cell = getCell(grid);

  uint type = uint(u_inputKey);

  // // TEST
  // if(type == 4u) type = SAND;

  resetCell(cell);
  cell.type = type;

  if(type == SAND || type == WATER) cell.velocity = DOWN;
  if(type == FIRE || type == STEAM) cell.velocity = UP;

  if(type == SAND) cell.temperature = 0u;

  // // TEST
  // if(type == 4u) cell.temperature = 2000u;

  return cell;
}
