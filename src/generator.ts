import { Config } from "./config";

export class Generator {
  generate() {
    const state: number[] = [];

    for (let y = 0; y < Config.height; y++) {
      for (let x = 0; x < Config.width; x++) {
        const r = Config.Elements.FIRE;
        const g = Config.Elements.SAND;
        const b = Config.Elements.WATER;
        const a = Config.Elements.EMPTY;
        state.push(r, g, b, a);
      }
    }

    for (let y = 0; y < Config.height; y++) {
      for (let x = 0; x < Config.width; x++) {
        const index = (y * Config.width + x) * 4;
        const isWall = y === 0 || x === 0 || x === Config.width / 2 - 1;
        if (isWall) {
          state[index + 0] = 1;
          state[index + 1] = 1;
          state[index + 2] = 1;
          state[index + 3] = 1;
        }
      }
    }

    return state;
  }
}
