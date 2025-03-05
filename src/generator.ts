import { Config } from "./config";

export class Generator {
  generate() {
    const state: number[] = [];

    for (let i = 0; i < Config.totalCells; i++) {
      const type = 0;
      const xVelocity = 1;
      const yVelocity = 0;
      const density = 0;
      state.push(type, xVelocity, yVelocity, density);
    }

    return state;
  }
}
