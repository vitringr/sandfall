export namespace Config {
  export const debug = true;
  export const partition = true;

  export const columns: number = 32;
  export const totalCells = columns * columns;

  export const walls: boolean = false;

  export const FPS: number = -1;

  export const borderSize: number = 0;

  export enum Elements {
    EMPTY = 0,
    BLOCK = 1,
    SAND = 2,
    WATER = 3,
    FIRE = 4,
    STEAM = 5,
  }

  export enum SpawnKeys {
    NONE = -1,
    Q = Elements.EMPTY,
    NUM_1 = Elements.BLOCK,
    NUM_2 = Elements.SAND,
    NUM_3 = Elements.WATER,
    NUM_4 = Elements.FIRE,
    NUM_5 = Elements.STEAM,
  }
}
