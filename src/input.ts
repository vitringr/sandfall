import { Vector2 } from "./utilities/vector2";
import { Config } from "./config";

export class Input {
  private key: Config.InputKeys = Config.InputKeys.NONE;
  private pointerCoordinates: Vector2 = Vector2.zero();
  private isPointerDown: boolean = false;

  public get getKey() {
    return this.key;
  }

  public get getPointerCoordinates() {
    return this.pointerCoordinates;
  }

  public get getIsPointerDown() {
    return this.isPointerDown;
  }

  setup(canvas: HTMLCanvasElement) {
    const canvasBounds = canvas.getBoundingClientRect();

    // Pointer events
    canvas.addEventListener("pointermove", (ev: PointerEvent) => {
      const x = ev.clientX - canvasBounds.left;
      const y = ev.clientY - canvasBounds.top;

      this.pointerCoordinates.set(
        x / canvas.width,
        (canvas.height - y) / canvas.height,
      );
    });

    window.addEventListener("pointerdown", () => {
      this.isPointerDown = true;
    });
    window.addEventListener("pointerup", () => {
      this.isPointerDown = false;
    });
    window.addEventListener("blur", () => {
      this.isPointerDown = false;
    });

    // Keyboard events
    const handleKeyDown = (ev: KeyboardEvent) => {
      switch (ev.key.toLowerCase()) {
        case "q":
          this.key = Config.InputKeys.Q;
          break;
        case "w":
          this.key = Config.InputKeys.W;
          break;
        case "e":
          this.key = Config.InputKeys.E;
          break;
        case "r":
          this.key = Config.InputKeys.R;
          break;
        case "a":
          this.key = Config.InputKeys.A;
          break;
        case "s":
          this.key = Config.InputKeys.S;
          break;
        case "d":
          this.key = Config.InputKeys.D;
          break;
        case "f":
          this.key = Config.InputKeys.F;
          break;
        case "x":
          window.location.reload();
          break;
        default:
          break;
      }
    };

    const handleKeyUp = (ev: KeyboardEvent) => {
      switch (ev.key.toLowerCase()) {
        case "q":
        case "w":
        case "e":
        case "r":
        case "a":
        case "s":
        case "d":
        case "f":
          this.key = Config.InputKeys.NONE;
          break;
        default:
          break;
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);
  }
}
