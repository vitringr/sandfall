struct Cell {
  uint rng;
  uint clock;
  uint empty0;
  uint empty1;

  uint type;
  uint temperature;
  uint velocity;
  uint isMoved;

  uint state0;
  uint state1;
  uint state2;
  uint state3;
};

struct Block {
  Cell bl;
  Cell tl;
  Cell tr;
  Cell br;
};
