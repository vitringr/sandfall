const uint DENSITY[7] = uint[7](
  UINT16_MAX, // DEBUG
  0u,         // Empty
  5u,         // Block
  4u,         // Sand
  3u,         // Water
  1u,         // Fire
  2u          // Steam
);

const uint MAX_TEMPERATURE_TRANSFER[7] = uint[7](
  0u,  // DEBUG
  0u,  // Empty
  10u, // Block
  50u, // Sand
  50u, // Water
  0u,  // Fire
  0u   // Steam
);

const uint SPREAD[7] = uint[7](
  SPREAD_NONE, // DEBUG
  SPREAD_NONE, // Empty
  SPREAD_NONE, // Block
  SPREAD_LOW,  // Sand
  SPREAD_MID,  // Water
  SPREAD_HIGH, // Fire
  SPREAD_HIGH  // Steam
);
