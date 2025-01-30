export class Config {
  // Temporary:
  // Should later be passed as an object literal to the main
  // class, so that there can be different main class instances
  // with different configuration each.

  static readonly width: number = 100;
  static readonly height: number = 100;

  static readonly percent: number = 5;
  static readonly FPS: number = 30;

  static get totalCells(): number {
    return this.width * this.height;
  }

  static get halfWidth(): number {
    return this.width / 2
  }

  static get halfHeight(): number {
    return this.height / 2
  }
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
}

