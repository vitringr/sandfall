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

    console.log("maximum draw buffers: " + gl.getParameter(gl.MAX_DRAW_BUFFERS));
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

  private setupState(gl: WebGL2RenderingContext, programs: { update: WebGLProgram; render: WebGLProgram }) {
    const locations = {
      update: {
        aCanvasVertices: gl.getAttribLocation(programs.update, "a_canvasVertices"),

        uInputTexture0: gl.getUniformLocation(programs.update, "u_inputTexture0"),
        uInputTexture1: gl.getUniformLocation(programs.update, "u_inputTexture1"),
        uInputTexture2: gl.getUniformLocation(programs.update, "u_inputTexture2"),

        uIsPointerDown: gl.getUniformLocation(programs.update, "u_isPointerDown"),
        uTime: gl.getUniformLocation(programs.update, "u_time"),
        uInputKey: gl.getUniformLocation(programs.update, "u_inputKey"),
        uMaxSoakedCells: gl.getUniformLocation(programs.update, "u_maxSoakedCells"),
        uSoakPerAbsorb: gl.getUniformLocation(programs.update, "u_soakPerAbsorb"),
        uSpawnerSize: gl.getUniformLocation(programs.update, "u_spawnerSize"),
        uPointerPosition: gl.getUniformLocation(programs.update, "u_pointerPosition"),
      },

      render: {
        uOutputTexture0: gl.getUniformLocation(programs.render, "u_outputTexture0"),
        uOutputTexture1: gl.getUniformLocation(programs.render, "u_outputTexture1"),
        uOutputTexture2: gl.getUniformLocation(programs.render, "u_outputTexture2"),

        uMaxSoakedCells: gl.getUniformLocation(programs.render, "u_maxSoakedCells"),
        uSoakPerAbsorb: gl.getUniformLocation(programs.render, "u_soakPerAbsorb"),
        uCanvas: gl.getUniformLocation(programs.render, "u_canvas"),
        uColumns: gl.getUniformLocation(programs.render, "u_columns"),
        uBorderSize: gl.getUniformLocation(programs.render, "u_borderSize"),
      },
    };

    const data = {
      state0: new Int8Array(this.generator.generate0()),
      state1: new Int8Array(this.generator.generate1()),
      state2: new Int8Array(this.generator.generate2()),
      canvasVertices: new Float32Array(WebGL.Points.rectangle(0, 0, 1, 1)),
    };

    const vertexArrayObjects = {
      update: gl.createVertexArray(),
      render: gl.createVertexArray(),
    };

    const textures = {
      main0: gl.createTexture(),
      aux0: gl.createTexture(),
      main1: gl.createTexture(),
      aux1: gl.createTexture(),
      main2: gl.createTexture(),
      aux2: gl.createTexture(),
    };

    const framebuffers = {
      update: gl.createFramebuffer(),
    };

    gl.bindVertexArray(vertexArrayObjects.update);

    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
    gl.bufferData(gl.ARRAY_BUFFER, data.canvasVertices, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(locations.update.aCanvasVertices);
    gl.vertexAttribPointer(locations.update.aCanvasVertices, 2, gl.FLOAT, false, 0, 0);

    gl.bindTexture(gl.TEXTURE_2D, textures.main0);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, Config.columns, Config.columns, 0, gl.RGBA_INTEGER, gl.BYTE, data.state0);
    WebGL.Texture.applyClampAndNearest(gl);

    gl.bindTexture(gl.TEXTURE_2D, textures.aux0);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, Config.columns, Config.columns, 0, gl.RGBA_INTEGER, gl.BYTE, data.state0);
    WebGL.Texture.applyClampAndNearest(gl);

    gl.bindTexture(gl.TEXTURE_2D, textures.main1);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, Config.columns, Config.columns, 0, gl.RGBA_INTEGER, gl.BYTE, data.state1);
    WebGL.Texture.applyClampAndNearest(gl);

    gl.bindTexture(gl.TEXTURE_2D, textures.aux1);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, Config.columns, Config.columns, 0, gl.RGBA_INTEGER, gl.BYTE, data.state1);
    WebGL.Texture.applyClampAndNearest(gl);

    gl.bindTexture(gl.TEXTURE_2D, textures.main2);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, Config.columns, Config.columns, 0, gl.RGBA_INTEGER, gl.BYTE, data.state2);
    WebGL.Texture.applyClampAndNearest(gl);

    gl.bindTexture(gl.TEXTURE_2D, textures.aux2);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8I, Config.columns, Config.columns, 0, gl.RGBA_INTEGER, gl.BYTE, data.state2);
    WebGL.Texture.applyClampAndNearest(gl);

    return { locations, vertexArrayObjects, textures, framebuffers };
  }

  private main(gl: WebGL2RenderingContext) {
    WebGL.Canvas.resizeToDisplaySize(this.canvas);
    gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    gl.clearColor(0.08, 0.08, 0.08, 1.0);

    const programs = this.setupPrograms(gl);

    const { locations, vertexArrayObjects, textures, framebuffers } = this.setupState(gl, programs);

    let time: number = 0;

    const updateLoop = () => {
      gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffers.update);
      gl.viewport(0, 0, Config.columns, Config.columns);
      gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, textures.aux0, 0);
      gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT1, gl.TEXTURE_2D, textures.aux1, 0);
      gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT2, gl.TEXTURE_2D, textures.aux2, 0);
      gl.drawBuffers([gl.COLOR_ATTACHMENT0, gl.COLOR_ATTACHMENT1, gl.COLOR_ATTACHMENT2]);

      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, textures.main0);

      gl.activeTexture(gl.TEXTURE1);
      gl.bindTexture(gl.TEXTURE_2D, textures.main1);

      gl.activeTexture(gl.TEXTURE2);
      gl.bindTexture(gl.TEXTURE_2D, textures.main2);

      gl.useProgram(programs.update);
      gl.bindVertexArray(vertexArrayObjects.update);

      gl.uniform1i(locations.update.uInputTexture0, 0);
      gl.uniform1i(locations.update.uInputTexture1, 1);
      gl.uniform1i(locations.update.uInputTexture2, 2);
      gl.uniform1i(locations.update.uIsPointerDown, Number(this.input.getIsPointerDown()));
      gl.uniform1i(locations.update.uTime, time);
      gl.uniform1i(locations.update.uInputKey, this.input.getSpawnKey());
      gl.uniform1i(locations.update.uMaxSoakedCells, Config.maxSoakedCells);
      gl.uniform1i(locations.update.uSoakPerAbsorb, Config.soakPerAbsorb);
      gl.uniform1f(locations.update.uSpawnerSize, Config.spawnerSize);
      const pointerCoordinates = this.input.getPointerCoordinates();
      gl.uniform2f(locations.update.uPointerPosition, pointerCoordinates.x, pointerCoordinates.y);

      gl.drawArrays(gl.TRIANGLES, 0, 6);
    };

    const renderLoop = () => {
      gl.bindFramebuffer(gl.FRAMEBUFFER, null);
      gl.viewport(0, 0, this.canvas.width, this.canvas.height);

      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, textures.aux0);

      gl.activeTexture(gl.TEXTURE1);
      gl.bindTexture(gl.TEXTURE_2D, textures.aux1);

      gl.activeTexture(gl.TEXTURE2);
      gl.bindTexture(gl.TEXTURE_2D, textures.aux2);

      gl.useProgram(programs.render);
      gl.bindVertexArray(vertexArrayObjects.render);

      gl.uniform1i(locations.render.uOutputTexture0, 0);
      gl.uniform1i(locations.render.uOutputTexture1, 1);
      gl.uniform1i(locations.render.uOutputTexture2, 2);
      gl.uniform1i(locations.render.uMaxSoakedCells, Config.maxSoakedCells);
      gl.uniform1i(locations.render.uSoakPerAbsorb, Config.soakPerAbsorb);
      gl.uniform1f(locations.render.uCanvas, this.canvas.width);
      gl.uniform1f(locations.render.uColumns, Config.columns);
      gl.uniform1f(locations.render.uBorderSize, Config.borderSize);

      gl.drawArrays(gl.POINTS, 0, Config.columns ** 2);
    };

    const mainLoop = () => {
      updateLoop();
      renderLoop();

      time++;

      const swap0 = textures.main0;
      textures.main0 = textures.aux0;
      textures.aux0 = swap0;

      const swap1 = textures.main1;
      textures.main1 = textures.aux1;
      textures.aux1 = swap1;

      const swap2 = textures.main2;
      textures.main2 = textures.aux2;
      textures.aux2 = swap2;

      if (!Config.debug && !Config.limitFPS) requestAnimationFrame(mainLoop);
    };

    mainLoop();

    if (Config.debug) this.input.setOnDebug(mainLoop);

    if (!Config.debug && Config.limitFPS) setInterval(mainLoop, 1000 / Config.FPS);
  }
}
