import { WebGL } from "./utilities/utilities";
import { Generator } from "./generator";
import { Config } from "./config";
import { Input } from "./input";

import updateVertex from "./shaders/update-vertex.glsl";
import updateFragment from "./shaders/update-fragment.glsl";
import renderVertex from "./shaders/render-vertex.glsl";
import renderFragment from "./shaders/render-fragment.glsl";

export class Main {
  private initialized = false;

  private input = new Input();
  private generator = new Generator();

  constructor(private readonly canvas: HTMLCanvasElement) {}

  setup() {
    if (this.initialized) throw "Already initialized";
    this.initialized = true;

    const gl = this.canvas.getContext("webgl2");
    if (!gl) throw "Failed to get WebGL2 context";

    this.input.setup(this.canvas);

    this.main(gl);
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

  private setupState(
    gl: WebGL2RenderingContext,
    programs: { update: WebGLProgram; render: WebGLProgram },
  ) {
    const locations = {
      update: {
        aCanvasVertices: gl.getAttribLocation(
          programs.update,
          "a_canvasVertices",
        ),

        uInputTextureIndex: gl.getUniformLocation(
          programs.update,
          "u_inputTextureIndex",
        ),

        uInputKey: gl.getUniformLocation(programs.update, "u_inputKey"),

        uPointerPosition: gl.getUniformLocation(
          programs.update,
          "u_pointerPosition",
        ),

        uIsPointerDown: gl.getUniformLocation(
          programs.update,
          "u_isPointerDown",
        ),

        uPartition: gl.getUniformLocation(programs.update, "u_partition"),

        uTime: gl.getUniformLocation(programs.update, "u_time"),
      },

      render: {
        uCanvas: gl.getUniformLocation(programs.render, "u_canvas"),
        uColumns: gl.getUniformLocation(programs.render, "u_columns"),
        uBorderSize: gl.getUniformLocation(programs.render, "u_borderSize"),

        uOutputTextureIndex: gl.getUniformLocation(
          programs.render,
          "u_outputTextureIndex",
        ),
      },
    };

    const data = {
      state: new Int8Array(this.generator.generate()),
      canvasVertices: new Float32Array(WebGL.Points.rectangle(0, 0, 1, 1)),
    };

    const vertexArrayObjects = {
      update: gl.createVertexArray(),
      render: gl.createVertexArray(),
    };

    const textures = {
      first: gl.createTexture(),
      second: gl.createTexture(),
    };

    const framebuffers = {
      update: gl.createFramebuffer(),
    };

    gl.bindVertexArray(vertexArrayObjects.update);

    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
    gl.bufferData(gl.ARRAY_BUFFER, data.canvasVertices, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(locations.update.aCanvasVertices);
    gl.vertexAttribPointer(
      locations.update.aCanvasVertices,
      2,
      gl.FLOAT,
      false,
      0,
      0,
    );

    gl.bindTexture(gl.TEXTURE_2D, textures.first);
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA8I,
      Config.columns,
      Config.columns,
      0,
      gl.RGBA_INTEGER,
      gl.BYTE,
      data.state,
    );
    WebGL.Texture.applyClampAndNearest(gl);

    gl.bindTexture(gl.TEXTURE_2D, textures.second);
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA8I,
      Config.columns,
      Config.columns,
      0,
      gl.RGBA_INTEGER,
      gl.BYTE,
      data.state,
    );
    WebGL.Texture.applyClampAndNearest(gl);

    return { locations, vertexArrayObjects, textures, framebuffers };
  }

  private main(gl: WebGL2RenderingContext) {
    WebGL.Canvas.resizeToDisplaySize(this.canvas);
    gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    gl.clearColor(0.08, 0.08, 0.08, 1.0);

    const programs = this.setupPrograms(gl);

    const { locations, vertexArrayObjects, textures, framebuffers } =
      this.setupState(gl, programs);

    let partition: boolean = false;
    let time: number = 0;

    const updateLoop = () => {
      gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffers.update);
      gl.viewport(0, 0, Config.columns, Config.columns);
      gl.framebufferTexture2D(
        gl.FRAMEBUFFER,
        gl.COLOR_ATTACHMENT0,
        gl.TEXTURE_2D,
        textures.second,
        0,
      );

      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, textures.first);

      gl.useProgram(programs.update);
      gl.bindVertexArray(vertexArrayObjects.update);

      gl.uniform1i(locations.update.uInputTextureIndex, 0);
      gl.uniform1i(locations.update.uTime, time);
      gl.uniform1i(locations.update.uInputKey, this.input.getKey());
      gl.uniform1i(locations.update.uPartition, partition ? 1 : 0);
      gl.uniform1i(
        locations.update.uIsPointerDown,
        this.input.getIsPointerDown() ? 1 : 0,
      );
      gl.uniform2f(
        locations.update.uPointerPosition,
        this.input.getPointerCoordinates().x,
        this.input.getPointerCoordinates().y,
      );

      gl.drawArrays(gl.TRIANGLES, 0, 6);
    };

    const renderLoop = () => {
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);
      gl.viewport(0, 0, this.canvas.width, this.canvas.height);

      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, textures.second);

      gl.useProgram(programs.render);
      gl.bindVertexArray(vertexArrayObjects.render);

      gl.uniform1f(locations.render.uCanvas, this.canvas.width);
      gl.uniform1f(locations.render.uColumns, Config.columns);
      gl.uniform1f(locations.render.uBorderSize, Config.borderSize);
      gl.uniform1i(locations.render.uOutputTextureIndex, 0);

      gl.drawArrays(gl.POINTS, 0, Config.totalCells);
    };

    const mainLoop = () => {
      updateLoop();
      renderLoop();

      if (Config.p) {
        partition = !partition;
      }

      time++;

      const swap = textures.first;
      textures.first = textures.second;
      textures.second = swap;

      if (Config.FPS === -1) requestAnimationFrame(mainLoop);
    };

    mainLoop();

    if (Config.FPS !== -1) setInterval(mainLoop, 1000 / Config.FPS);
  }
}
