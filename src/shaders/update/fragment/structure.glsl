struct Cell {
  int rng;
  int clock;
  int empty0;
  int empty1;

  int type;
  int temperature;
  int velocity;
  int isMoved;

  int state0;
  int state1;
  int state2;
  int state3;
};

struct Block {
  Cell bl;
  Cell tl;
  Cell tr;
  Cell br;
};
