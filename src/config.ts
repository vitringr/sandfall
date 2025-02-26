export namespace Config {
  export const width: number = 100;
  export const height: number = 100;

  export const totalCells = width * height;

  export const percent: number = 0;

  export const FPS: number = 30;

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
    "Q" = Elements.BLOCK,
    "W" = Elements.WATER,
    "E" = Elements.EMPTY,
    "R" = -1,
    "A" = -1,
    "S" = Elements.SAND,
    "D" = Elements.STEAM,
    "F" = Elements.FIRE,
  }
}
