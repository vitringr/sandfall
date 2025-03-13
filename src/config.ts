// TODO: purple shit

export namespace Config {
  export const debug = false;

  export const columns: number = 100;
  export const walls: boolean = true;
  export const spawnerSize: number = 0.014;
  //export const spawnerSize: number = 0.02;

  export const limitFPS: boolean = false;
  export const FPS: number = 60;

  export const borderSize: number = -0.02;

  export const maxSoakedCells: number = 2;
  export const soakPerAbsorb: number = 10;

  export enum Elements {
    DEBUG = 0,
    EMPTY = 1,
    BLOCK = 2,
    SAND = 3,
    WATER = 4,
    FIRE = 5,
    STEAM = 6,
  }

  export enum SpawnKeys {
    NONE = 0,
    NUM_1 = Elements.EMPTY,
    NUM_2 = Elements.BLOCK,
    NUM_3 = Elements.SAND,
    NUM_4 = Elements.WATER,
    NUM_5 = Elements.FIRE,
    NUM_6 = Elements.STEAM,
  }
}
