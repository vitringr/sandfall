export function compileShader(gl: WebGL2RenderingContext, type: "vertex" | "fragment", source: string) {
  const shaderType = type === "vertex" ? gl.VERTEX_SHADER : gl.FRAGMENT_SHADER;
  const shader = gl.createShader(shaderType);
  if (!shader) throw new Error("Unable to create shader");

  gl.shaderSource(shader, source);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    const info = gl.getShaderInfoLog(shader);
    gl.deleteShader(shader);
    throw new Error(`Could not compile ${type} shader: ` + info);
  }

  return shader;
}

export function linkProgram(gl: WebGL2RenderingContext, vertexShader: WebGLShader, fragmentShader: WebGLShader) {
  const program = gl.createProgram();
  if (!program) throw new Error("Unable to create program");

  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);

  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    const info = gl.getProgramInfoLog(program);
    gl.deleteProgram(program);
    throw new Error("Program failed to link: " + info);
  }

  // Optional. Default pixel alignment.
  gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);

  return program;
}

export function linkTransformFeedbackProgram(
  gl: WebGL2RenderingContext,
  vertexShader: WebGLShader,
  fragmentShader: WebGLShader,
  varyings: string[],
  bufferMode: "separate" | "interleaved",
) {
  const program = gl.createProgram();
  if (!program) throw new Error("Unable to create program");

  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);

  gl.transformFeedbackVaryings(
    program,
    varyings,
    bufferMode === "separate" ? gl.SEPARATE_ATTRIBS : gl.INTERLEAVED_ATTRIBS,
  );

  gl.linkProgram(program);

  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    const info = gl.getProgramInfoLog(program);
    gl.deleteProgram(program);
    throw new Error("Program failed to link: " + info);
  }

  // Optional. Default pixel alignment.
  gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);

  return program;
}
