import { Random, Vector2, WebGL } from "../utilities/utilities";

import updateVertex from "./update-vertex.glsl";
import updateFragment from "./update-fragment.glsl";
import renderVertex from "./render-vertex.glsl";
import renderFragment from "./render-fragment.glsl";

enum Elements {
  EMPTY = 0,
  BLOCK = 1,
  SAND = 2,
  WATER = 3,
  FIRE = 4,
  STEAM = 5,
}

enum InputKeys {
  "NONE" = -1,
  "Q" = Elements.BLOCK,
  "W" = Elements.WATER,
  "E" = Elements.EMPTY,
  "R" = -1,
  "A" = -1,
  "S" = Elements.SAND,
  "D" = Elements.STEAM,
  "F" = Elements.FIRE,
}

export class Sandfall {
  ///* */ private readonly width = 40;
  ///**/ private readonly height = 40;
  /* */ private readonly width = 100;
  /**/ private readonly height = 100;

  private readonly percent = 0;
  private readonly FPS: number = 30; // Temporary; -1 for full

  private readonly totalCells = this.width * this.height;

  private readonly input = {
    pointer: { coordinates: Vector2.zero(), isDown: 0 },
    key: InputKeys.NONE,
  };
  private initialized = false;

  constructor(private readonly canvas: HTMLCanvasElement) { }

  init() {
    if (this.initialized) throw "Already initialized";
    this.initialized = true;

    const gl = this.canvas.getContext("webgl2");
    if (!gl) throw new Error("Failed to get WebGL2 context");

    this.setupInput();

    this.main(gl);
  }

  private setupInput() {
    const canvasBounds = this.canvas.getBoundingClientRect();

    // Pointer events
    this.canvas.addEventListener("pointermove", (ev: PointerEvent) => {
      const x = ev.clientX - canvasBounds.left;
      const y = ev.clientY - canvasBounds.top;
      this.input.pointer.coordinates.set(x / this.canvas.width, (this.canvas.height - y) / this.canvas.height);
    });

    window.addEventListener("pointerdown", () => {
      this.input.pointer.isDown = 1;
    });
    window.addEventListener("pointerup", () => {
      this.input.pointer.isDown = 0;
    });
    window.addEventListener("blur", () => {
      this.input.pointer.isDown = 0;
    });

    // Keyboard events
    const handleKeyDown = (ev: KeyboardEvent) => {
      switch (ev.key.toLowerCase()) {
        case "q":
          this.input.key = InputKeys.Q;
          break;
        case "w":
          this.input.key = InputKeys.W;
          break;
        case "e":
          this.input.key = InputKeys.E;
          break;
        case "r":
          this.input.key = InputKeys.R;
          break;
        case "a":
          this.input.key = InputKeys.A;
          break;
        case "s":
          this.input.key = InputKeys.S;
          break;
        case "d":
          this.input.key = InputKeys.D;
          break;
        case "f":
          this.input.key = InputKeys.F;
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
          this.input.key = InputKeys.NONE;
          break;
        default:
          break;
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);
  }

  private setupPrograms(gl: WebGL2RenderingContext) {
    const updateVS = WebGL.Setup.compileShader(gl, "vertex", updateVertex);
    const updateFS = WebGL.Setup.compileShader(gl, "fragment", updateFragment);
    const renderVS = WebGL.Setup.compileShader(gl, "vertex", renderVertex);
    const renderFS = WebGL.Setup.compileShader(gl, "fragment", renderFragment);

    return {
      update: WebGL.Setup.linkProgram(gl, updateVS, updateFS),
      render: WebGL.Setup.linkProgram(gl, renderVS, renderFS),
    };
  }

  private generateData() {
    const state: number[] = [];

    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
        //const r = Random.percent(this.percent) ? 1 : 0;
        const r = Random.percent(this.percent) ? 3 : 0;
        const g = 0;
        const b = 0;
        const a = 0;
        state.push(r, g, b, a);
      }
    }

    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
        const index = (y * this.width + x) * 4;
        if (y === 0) state[index] = 1;
        if (x === 0) state[index] = 1;
        if (x === this.width - 1) state[index] = 1;
      }
    }

    return state;
  }

  private setupUniformBlock(gl: WebGL2RenderingContext, programs: { update: WebGLProgram; render: WebGLProgram }) {
    const blockIndices = {
      update: {},
      render: {
        dimensions: gl.getUniformBlockIndex(programs.render, "DimensionsStaticData"),
      },
    };

    const buffers = {
      dimensions: gl.createBuffer(),
    };

    const data = {
      dimensions: new Float32Array([this.width, this.height, this.canvas.width, this.canvas.height]),
    };

    const dimensionsIndex = 0;
    gl.uniformBlockBinding(programs.render, blockIndices.render.dimensions, dimensionsIndex);
    gl.bindBuffer(gl.UNIFORM_BUFFER, buffers.dimensions);
    gl.bufferData(gl.UNIFORM_BUFFER, data.dimensions, gl.STATIC_DRAW);
    gl.bindBufferBase(gl.UNIFORM_BUFFER, dimensionsIndex, buffers.dimensions);
  }

  private setupState(gl: WebGL2RenderingContext, programs: { update: WebGLProgram; render: WebGLProgram }) {
    const locations = {
      update: {
        aCanvasVertices: gl.getAttribLocation(programs.update, "a_canvasVertices"),
        uInputTextureIndex: gl.getUniformLocation(programs.update, "u_inputTextureIndex"),
        uInputKey: gl.getUniformLocation(programs.update, "u_inputKey"),
        uPointerPosition: gl.getUniformLocation(programs.update, "u_pointerPosition"),
        uIsPointerDown: gl.getUniformLocation(programs.update, "u_isPointerDown"),
        uPartition: gl.getUniformLocation(programs.update, "u_partition"),
      },
      render: {
        uOutputTextureIndex: gl.getUniformLocation(programs.render, "u_outputTextureIndex"),
      },
    };

    this.setupUniformBlock(gl, programs);

    const data = {
      state: new Int8Array(this.generateData()),
      canvasVertices: new Float32Array(WebGL.Points.rectangle(0, 0, 1, 1)),
    };

    const vertexArrayObjects = {
      update: gl.createVertexArray(),
      render: gl.createVertexArray(),
    };

    const textures = {
      input: gl.createTexture(),
      output: gl.createTexture(),
    };

    const framebuffers = {
      update: gl.createFramebuffer(),
    };

    gl.bindVertexArray(vertexArrayObjects.update);

    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
    gl.bufferData(gl.ARRAY_BUFFER, data.canvasVertices, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(locations.update.aCanvasVertices);
    gl.vertexAttribPointer(locations.update.aCanvasVertices, 2, gl.FLOAT, false, 0, 0);

    gl.bindTexture(gl.TEXTURE_2D, textures.input);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, this.width, this.height, 0, gl.RGBA_INTEGER, gl.BYTE, data.state);
    WebGL.Texture.applyClampAndNearest(gl);

    gl.bindTexture(gl.TEXTURE_2D, textures.output);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, this.width, this.height, 0, gl.RGBA_INTEGER, gl.BYTE, data.state);
    WebGL.Texture.applyClampAndNearest(gl);

    return { locations, vertexArrayObjects, textures, framebuffers };
  }

  private main(gl: WebGL2RenderingContext) {
    WebGL.Canvas.resizeToDisplaySize(this.canvas);
    gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    gl.clearColor(0.08, 0.08, 0.08, 1.0);

    const programs = this.setupPrograms(gl);

    const { locations, vertexArrayObjects, textures, framebuffers } = this.setupState(gl, programs);

    let partition: boolean = false;

    const updateLoop = () => {
      gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffers.update);
      gl.viewport(0, 0, this.width, this.height);
      gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, textures.output, 0);

      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, textures.input);

      gl.useProgram(programs.update);
      gl.bindVertexArray(vertexArrayObjects.update);

      gl.uniform1i(locations.update.uInputTextureIndex, 0);
      gl.uniform1i(locations.update.uInputKey, this.input.key);
      gl.uniform1i(locations.update.uPartition, partition ? 1 : 0);
      gl.uniform1i(locations.update.uIsPointerDown, this.input.pointer.isDown);
      gl.uniform2f(
        locations.update.uPointerPosition,
        this.input.pointer.coordinates.x,
        this.input.pointer.coordinates.y,
      );

      gl.drawArrays(gl.TRIANGLES, 0, 6);
    };

    const renderLoop = () => {
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);
      gl.viewport(0, 0, this.canvas.width, this.canvas.height);

      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, textures.output);

      gl.useProgram(programs.render);
      gl.bindVertexArray(vertexArrayObjects.render);

      gl.uniform1i(locations.render.uOutputTextureIndex, 0);

      gl.drawArrays(gl.POINTS, 0, this.totalCells);
    };

    const mainLoop = () => {
      updateLoop();
      renderLoop();

      partition = !partition;

      const swap = textures.input;
      textures.input = textures.output;
      textures.output = swap;

      if (this.FPS === -1) requestAnimationFrame(mainLoop);
    };

    mainLoop();

    if (this.FPS !== -1) setInterval(mainLoop, 1000 / this.FPS);
  }
}
