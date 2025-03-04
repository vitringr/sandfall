import { Config } from "./config";

export class Generator {
  generate() {
    const state: number[] = [];

    for (let i = 0; i < Config.totalCells; i++) {
      const type = 0;
      const g = 1;
      const b = 0;
      const clock = 0;
      state.push(type, g, b, clock);
    }

    return state;
  }
}
