export function resizeToDisplaySize(canvas: HTMLCanvasElement, multiplier?: number): boolean {
  const scale = multiplier || 1;

  const width = (canvas.clientWidth * scale) | 0;
  const height = (canvas.clientHeight * scale) | 0;

  const needsResize = !(canvas.width === width && canvas.height === height);

  if (needsResize) {
    canvas.width = width;
    canvas.height = height;
  }

  return needsResize;
}
