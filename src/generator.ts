import { Random } from "./utilities/utilities";
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

    // Walls:

    //for (let y = 0; y < Config.height; y++) {
    //  for (let x = 0; x < Config.width; x++) {
    //    const index = (y * Config.width + x) * 4;
    //    if (y === 0) state[index] = 1;
    //    if (x === 0) state[index] = 1;
    //    if (x === Config.width - 1) state[index] = 1;
    //  }
    //}

    return state;
  }
}
