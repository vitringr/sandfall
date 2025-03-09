import { Config } from "./config";
import { Random } from "./utilities/utilities";

const totalCells = Config.columns ** 2;

export class Generator {
  private isWall(cell: number): boolean {
    if (cell < Config.columns) return true;
    if (cell > totalCells - Config.columns) return true;
    if (cell % Config.columns == 0) return true;
    if (cell % Config.columns == Config.columns - 1) return true;

    return false;
  }

  generate0() {
    const state: number[] = [];
    for (let i = 0; i < totalCells; i++) {
      const r = Random.rangeInt(0, 100);
      const g = 0;
      const b = 0;
      const a = 0;
      state.push(r, g, b, a);
    }

    return state;
  }

  generate1() {
    const state: number[] = [];
    for (let i = 0; i < totalCells; i++) {
      const r = Config.walls && this.isWall(i) ? 1 : 0;
      const g = 30;
      const b = 0;
      const a = 0;
      state.push(r, g, b, a);
    }

    return state;
  }

  generate2() {
    const state: number[] = [];
    for (let i = 0; i < totalCells; i++) {
      const r = 0;
      const g = 0;
      const b = 0;
      const a = 0;
      state.push(r, g, b, a);
    }

    return state;
  }
}
