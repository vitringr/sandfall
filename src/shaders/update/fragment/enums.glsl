const int DEBUG = 0;
const int EMPTY = 1;
const int BLOCK = 2;
const int SAND  = 3;
const int WATER = 4;
const int ICE   = 5;
const int STEAM = 6;
const int FIRE  = 7;

const int LEFT  = 1;
const int DOWN  = 2;
const int RIGHT = 3;
const int UP    = 4;

const int SPREAD_NONE = 0;
const int SPREAD_LOW  = 1;
const int SPREAD_MID  = 2;
const int SPREAD_HIGH = 3;
const int SPREAD_FULL = 4;

const int INTERACTION_NONE            = 0;
const int INTERACTION_BLOCK_AND_BLOCK = 1;
const int INTERACTION_BLOCK_AND_SAND  = 2;
const int INTERACTION_BLOCK_AND_WATER = 3;
const int INTERACTION_SAND_AND_SAND   = 4;
const int INTERACTION_SAND_AND_WATER  = 5;
const int INTERACTION_WATER_AND_WATER = 6;
