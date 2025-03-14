
void resetCell(inout Cell cell) {
  // cell.rng;
  cell.clock       = 0;
  cell.empty0      = 0;
  cell.empty1      = 0;

  cell.type        = DEBUG;
  cell.temperature = TEMPERATURE_NORMAL;
  cell.velocity    = 0;
  cell.isMoved     = 0;

  cell.state0      = 0;
  cell.state1      = 0;
  cell.state2      = 0;
  cell.state3      = 0;
}

void balanceValues(inout int a, inout int b) {
  if(abs(a - b) < 2) return;

  int total = a + b;
  int aNew = 0;
  int bNew = 0;

  if(a > b) {
    aNew = (total + 1) / 2;
    bNew = total - aNew;
  }
  else {
    bNew = (total + 1) / 2;
    aNew = total - bNew;
  }

  a = aNew;
  b = bNew;
}
