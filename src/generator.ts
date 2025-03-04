import { Config } from "./config";

export class Generator {
  generate() {
    const state: number[] = [];

    for (let i = 0; i < Config.totalCells; i++) {
        const type = 1;
        const g = 0;
        const b = 0;
        const clock = 0;
        state.push(type, g, b, clock);
    }

    return state;
  }
}
