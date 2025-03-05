export namespace Config {
  export const columns: number = 40;
  export const totalCells = columns * columns;

  export const FPS: number = 30;

  export const borderSize: number = 1;

  export enum Elements {
    EMPTY = 0,
    BLOCK = 1,
    SAND = 2,
    WATER = 3,
    FIRE = 4,
    STEAM = 5,
  }

  export enum InputKeys {
    "NONE" = -1,
    "Q" = Elements.EMPTY,
    "W" = Elements.BLOCK,
    "E" = Elements.SAND,
    "R" = Elements.WATER,
    "A" = -1,
    "S" = -1,
    "D" = Elements.STEAM,
    "F" = Elements.FIRE,
  }
}
