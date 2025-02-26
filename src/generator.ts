import { Random } from "./utilities/utilities";
import { Config } from "./config";

export class Generator {
  generate() {
    const state: number[] = [];

    for (let y = 0; y < Config.height; y++) {
      for (let x = 0; x < Config.width; x++) {
        const r = Random.percent(Config.percent) ? Config.Elements.WATER : 0;
        const g = 0;
        const b = 0;
        const a = 0;
        state.push(r, g, b, a);
      }
    }

    for (let y = 0; y < Config.height; y++) {
      for (let x = 0; x < Config.width; x++) {
        const index = (y * Config.width + x) * 4;
        if (y === 0) state[index] = 1;
        if (x === 0) state[index] = 1;
        if (x === Config.width - 1) state[index] = 1;
      }
    }

    return state;
  }
}
