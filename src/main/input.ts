import { Vector2 } from "../utilities/vector2";
import { Config } from "./config";

export class Input {
  private state: Input.InputData = {
    pointer: {
      coordinates: Vector2.zero(),
      isDown: 0
    },
    key: Input.InputKeys.NONE
  }

  private handleKeyDown(ev: KeyboardEvent) {
    switch (ev.key.toLowerCase()) {
      case "q":
        this.state.key = Input.InputKeys.Q;
        break;
      case "w":
        this.state.key = Input.InputKeys.W;
        break;
      case "e":
        this.state.key = Input.InputKeys.E;
        break;
      case "r":
        this.state.key = Input.InputKeys.R;
        break;
      case "a":
        this.state.key = Input.InputKeys.A;
        break;
      case "s":
        this.state.key = Input.InputKeys.S;
        break;
      case "d":
        this.state.key = Input.InputKeys.D;
        break;
      case "f":
        this.state.key = Input.InputKeys.F;
        break;
      case "x":
        window.location.reload();
        break;
      default:
        break;
    }
  }

  private handleKeyUp(ev: KeyboardEvent) {
    switch (ev.key.toLowerCase()) {
      case "q":
      case "w":
      case "e":
      case "r":
      case "a":
      case "s":
      case "d":
      case "f":
      case "x":
        this.state.key = Input.InputKeys.NONE;
        break;
      default:
        break;
    }
  }

  setup(canvas: HTMLCanvasElement) {
    const canvasBounds = canvas.getBoundingClientRect();

    // Pointer events
    canvas.addEventListener("pointermove", (ev: PointerEvent) => {
      const x = ev.clientX - canvasBounds.left;
      const y = ev.clientY - canvasBounds.top;
      this.state.pointer.coordinates.set(x / canvas.width, (canvas.height - y) / canvas.height);
    });

    window.addEventListener("pointerdown", () => {
      this.state.pointer.isDown = 1;
    });
    window.addEventListener("pointerup", () => {
      this.state.pointer.isDown = 0;
    });
    window.addEventListener("blur", () => {
      this.state.pointer.isDown = 0;
    });

    // Keyboard events
    window.addEventListener("keydown", () => this.handleKeyDown);
    window.addEventListener("keyup", () => this.handleKeyUp);
  }

  get(): Readonly<Input.InputData> {
    return this.state;
  }
}

export namespace Input {
  export type InputData = {
    pointer: {
      coordinates: Vector2;
      isDown: number;
    };
    key: InputKeys;
  }

  export enum InputKeys {
    "NONE" = -1,
    "Q" = Config.Elements.BLOCK,
    "W" = Config.Elements.WATER,
    "E" = Config.Elements.EMPTY,
    "R" = -1,
    "A" = -1,
    "S" = Config.Elements.SAND,
    "D" = Config.Elements.STEAM,
    "F" = Config.Elements.FIRE,
  }
}
