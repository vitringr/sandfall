import { Config } from "./config";

const totalCells = Config.columns ** 2;

export class Generator {
  setWalls(state: number[]): number[] {
    const newState = state;

    for (let i = 0; i < totalCells; i++) {
      const index = i * 4;

      if (i < Config.columns) newState[index] = 1;
      if (i > totalCells - Config.columns) newState[index] = 1;
      if (i % Config.columns == 0) newState[index] = 1;
      if (i % Config.columns == Config.columns - 1) newState[index] = 1;
    }

    return newState;
  }

  generate() {
    const state: number[] = [];

    for (let i = 0; i < totalCells; i++) {
      const type = 0;
      const velocity = 0;
      const empty0 = 0;
      const empty1 = 0;
      state.push(type, velocity, empty0, empty1);
    }

    if (Config.walls) this.setWalls(state);

    return state;
  }
}
