const int DENSITY[6] = int[6](
  0, // Empty
  5, // Block
  4, // Sand
  3, // Water
  1, // Fire
  2  // Steam
);

const int MAX_TEMPERATURE_TRANSFER[6] = int[6](
  0,  // Empty
  10, // Block
  50, // Sand
  50, // Water
  0,  // Fire
  0   // Steam
);

const int SPREAD[6] = int[6](
  -1,          // Empty
  -1,          // Block
  SPREAD_LOW,  // Sand
  SPREAD_MID,  // Water
  SPREAD_HIGH, // Fire
  SPREAD_HIGH  // Steam
);
