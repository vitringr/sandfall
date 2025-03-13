void resetCell(inout Cell cell) {
  // cell.rng;
  cell.clock       = 0u;
  cell.empty0      = 0u;
  cell.empty1      = 0u;

  cell.type        = EMPTY;
  cell.temperature = 0u;
  cell.velocity    = 0u;
  cell.isMoved     = 0u;

  cell.state0      = 0u;
  cell.state1      = 0u;
  cell.state2      = 0u;
  cell.state3      = 0u;
}

void balanceValues(inout uint a, inout uint b) {
  uint diff = (a > b) ? (a - b) : (b - a);
  if(diff < 2u) return;

  uint total = a + b;
  uint aNew = 0u;
  uint bNew = 0u;

  if(a > b) {
    aNew = (total + 1u) / 2u;
    bNew = total - aNew;
  }
  else {
    bNew = (total + 1u) / 2u;
    aNew = total - bNew;
  }

  a = aNew;
  b = bNew;
}
