import { Config } from "./config";

export class Generator {
  generate() {
    const state: number[] = [];

    for (let y = 0; y < Config.blockRange; y++) {
      for (let x = 0; x < Config.blockRange; x++) {
        const rCell = 1;
        const gCell = 0;
        const bCell = 0;
        const aCell = 0;
        state.push(rCell, gCell, bCell, aCell);
      }
    }

    //for (let y = 0; y < Config.height / 2; y++) {
    //  for (let x = 0; x < Config.width / 2; x++) {
    //    const index = (y * Config.width + x) * 4;
    //    const isWall = y === 0 || x === 0 || x === Config.width / 2 - 1;
    //    if (isWall) {
    //      state[index + 0] = 1;
    //      state[index + 1] = 1;
    //      state[index + 2] = 1;
    //      state[index + 3] = 1;
    //    }
    //  }
    //}

    return state;
  }
}
