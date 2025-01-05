export function computeKernelWeight(kernel: number[]) {
  const weight = kernel.reduce((prev, curr) => prev + curr);
  return weight <= 0 ? 1 : weight;
}

export const matrices3x3 = {
  // prettier-ignore
  identity: [
    0, 0, 0,
    0, 1, 0,
    0, 0, 0,
  ],

  // prettier-ignore
  blur: [
    0.111, 0.111, 0.111,
    0.111, 0.111, 0.111,
    0.111, 0.111, 0.111,
  ],

  // prettier-ignore
  emboss: [
    -2, -1, 0,
    -1, 1, 1,
    0, 1, 2,
  ],

  // prettier-ignore
  sharpen: [
    0, -1, 0,
    -1, 5, -1,
    0, -1, 0,
  ],

  // prettier-ignore
  edgeDetection: [
    -1, -1, -1,
    -1, 8, -1,
    -1, -1, -1,
  ],

  // prettier-ignore
  horizontalEdgeDetection: [
    -1, -1, -1,
    0, 0, 0,
    1, 1, 1,
  ],

  // prettier-ignore
  verticalEdgeDetection: [
    -1, 0, 1,
    -1, 0, 1,
    -1, 0, 1,
  ],
};
