import { Vector2 } from "./utilities/vector2";
import { Config } from "./config";

export class Input {
  private spawnKey: Config.SpawnKeys = Config.SpawnKeys.NONE;
  private pointerCoordinates: Vector2 = Vector2.zero();
  private isPointerDown: boolean = false;

  getSpawnKey() {
    return this.spawnKey;
  }

  getPointerCoordinates() {
    return this.pointerCoordinates;
  }
  getIsPointerDown() {
    return this.isPointerDown;
  }

  private setupPointer(canvas: HTMLCanvasElement) {
    const canvasBounds = canvas.getBoundingClientRect();

    canvas.addEventListener("pointermove", (ev: PointerEvent) => {
      const x = ev.clientX - canvasBounds.left;
      const y = ev.clientY - canvasBounds.top;

      this.pointerCoordinates.set(x / canvas.width, (canvas.height - y) / canvas.height);
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
  }

  private setupKeyboard() {
    window.addEventListener("keydown", (ev: KeyboardEvent) => {
      switch (ev.key.toLowerCase()) {
        case "0":
          this.spawnKey = Config.SpawnKeys.NUM_0;
          break;
        case "1":
          this.spawnKey = Config.SpawnKeys.NUM_1;
          break;
        case "2":
          this.spawnKey = Config.SpawnKeys.NUM_2;
          break;
        case "3":
          this.spawnKey = Config.SpawnKeys.NUM_3;
          break;
        case "4":
          this.spawnKey = Config.SpawnKeys.NUM_4;
          break;
        case "5":
          this.spawnKey = Config.SpawnKeys.NUM_5;
          break;
        case "6":
          this.spawnKey = Config.SpawnKeys.NUM_6;
          break;
        case "7":
          this.spawnKey = Config.SpawnKeys.NUM_7;
          break;
        case "r":
          window.location.reload();
          break;
        default:
          break;
      }
    });

    window.addEventListener("keyup", (ev: KeyboardEvent) => {
      switch (ev.key.toLowerCase()) {
        case "0":
        case "1":
        case "2":
        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
          this.spawnKey = Config.SpawnKeys.NONE;
          break;
        default:
          break;
      }
    });
  }

  setup(canvas: HTMLCanvasElement) {
    this.setupPointer(canvas);
    this.setupKeyboard();
  }

  setOnDebug(callback: () => void) {
    window.addEventListener("keydown", (ev: KeyboardEvent) => {
      if (ev.key.toLowerCase() === "d") callback();
    });
  }
}
