export const PI = 3.141592653589793;
export const TAU = 6.283185307179586;

export const SQRT_2 = 1.4142135623730951;

export const SIN_60 = 0.8660254037844386;
export const COS_60 = 0.5;
export const SIN_45 = 0.7071067811865476;
export const COS_45 = 0.7071067811865476;
export const SIN_30 = 0.5;
export const COS_30 = 0.8660254037844386;

export function degreesToRadians(degrees: number) {
  return degrees * (TAU / 360);
}

export function radiansToDegrees(radians: number) {
  return radians * (360 / TAU);
}

export function lerp(a: number, b: number, step: number) {
  return a + step * (b - a);
}

export function manhattanDistance(x1: number, y1: number, x2: number, y2: number) {
  return Math.abs(x1 - x2) + Math.abs(y1 - y2);
}

export function euclideanModulo(a: number, b: number) {
  return ((a % b) + b) % b;
}
