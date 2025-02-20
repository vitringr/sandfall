export class Config {
  static readonly width: number = 100;
  static readonly height: number = 100;

  static get totalCells(): number {
    return Config.width * Config.height;
  }

  static readonly percent: number = 0;

  static readonly FPS: number = 30;
}

export namespace Config {
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
