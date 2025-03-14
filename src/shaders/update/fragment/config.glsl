const int TEMPERATURE_ABSOLUTE_ZERO = 0;
const int TEMPERATURE_WATER_FREEZE  = 2700;
const int TEMPERATURE_NORMAL        = 3000;
const int TEMPERATURE_WATER_BOIL    = 3700;
const int TEMPERATURE_WOOD_BURN     = 8000;
const int TEMPERATURE_METAL_MELT    = 15000;
const int TEMPERATURE_SAND_MELT     = 19000;
const int TEMPERATURE_MAXIMUM       = 30000;

const int MAX_THERMAL_TRANSFER[7] = int[7](
  1000, // Empty
  1000, // Block
  1000,  // Sand
  1000, // Water
  1000,  // Ice
  1000, // Steam
  1000  // Fire
);

const int DENSITY[7] = int[7](
  0, // Empty
  9, // Block
  4, // Sand
  3, // Water
  9, // Ice
  2, // Steam
  1  // Fire
);

const int SPREAD[7] = int[7](
  -1,          // Empty
  -1,          // Block
  SPREAD_LOW,  // Sand
  SPREAD_MID,  // Water
  SPREAD_NONE, // Ice
  SPREAD_HIGH, // Steam
  SPREAD_HIGH  // Fire
);
