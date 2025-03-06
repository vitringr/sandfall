import { Config } from "./config";

export class Generator {
  generate() {
    const state: number[] = [];

    for (let i = 0; i < Config.totalCells; i++) {
      const type = 0;
      const velocity = 0;
      const empty0 = 0;
      const empty1 = 0;
      state.push(type, velocity, empty0, empty1);
    }

    return state;
  }
}
