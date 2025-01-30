import { Random } from "../utilities/utilities";
import { Config } from "./config";

export class Generator {
  static randomRGBA(width: number, height: number, percent: number) {
    const state: number[] = [];

    for (let y = 0; y < width; y++) {
      for (let x = 0; x < height; x++) {
        const r = Random.percent(percent) ? Config.Elements.SAND : 0;
        const g = Random.percent(percent) ? Config.Elements.BLOCK : 0;
        const b = Random.percent(percent) ? Config.Elements.WATER : 0;
        const a = Random.percent(percent) ? Config.Elements.FIRE : 0;
        state.push(r, g, b, a);
      }
    }

    return state;
  }

  static emptyRGBA(width: number, height: number) {
    const state: number[] = [];

    for (let y = 0; y < width; y++) {
      for (let x = 0; x < height; x++) {
        state.push(0, 0, 0, 0);
      }
    }

    return state;
  }

}

