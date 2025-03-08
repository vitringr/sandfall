export namespace Config {
  export const debug = false;

  export const columns: number = 100;
  export const walls: boolean = true;
  export const spawnerSize: number = 0.014;

  export const limitFPS: boolean = false;
  export const FPS: number = 60;

  export const borderSize: number = -0.02;

  export const maxSoakedCells: number = 2;
  export const soakPerAbsorb: number = 10;

  export enum Elements {
    EMPTY = 0,
    BLOCK = 1,
    SAND = 2,
    WATER = 3,
    FIRE = 4,
    STEAM = 5,
    WET_SAND = 6,
  }

  export enum SpawnKeys {
    NONE = -1,
    Q = Elements.EMPTY,
    NUM_1 = Elements.BLOCK,
    NUM_2 = Elements.SAND,
    NUM_3 = Elements.WATER,
    NUM_4 = Elements.FIRE,
    NUM_5 = Elements.STEAM,
    NUM_6 = Elements.WET_SAND,
  }
}
