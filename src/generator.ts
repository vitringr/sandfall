import { Config } from "./config";
import { Random } from "./utilities/utilities";

const totalCells = Config.columns ** 2;

export class Generator {
  private setWalls(state: number[]): number[] {
    const newState = state;

    for (let i = 0; i < totalCells; i++) {
      const index = i * 4 + 2;

      if (i < Config.columns) newState[index] = 1;
      if (i > totalCells - Config.columns) newState[index] = 1;
      if (i % Config.columns == 0) newState[index] = 1;
      if (i % Config.columns == Config.columns - 1) newState[index] = 1;
    }

    return newState;
  }

  generateOne() {
    const stateOne: number[] = [];
    for (let i = 0; i < totalCells; i++) {
      const rng = Random.rangeInt(0, 100);
      const clock = 0;
      const type = 0;
      const state = 0;
      stateOne.push(rng, clock, type, state);
    }

    if (Config.walls) this.setWalls(stateOne);

    return stateOne;
  }

  generateTwo() {
    const stateTwo: number[] = [];
    for (let i = 0; i < totalCells; i++) {
      const velocity = 0;
      const isMoved = 0;
      const heat = 0;
      const empty = 0;
      stateTwo.push(velocity, isMoved, heat, empty);
    }

    return stateTwo;
  }
}
