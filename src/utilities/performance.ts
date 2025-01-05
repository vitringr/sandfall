export function measureTime(func: () => void, label: string): number {
  const start = performance.now();
  func();
  const end = performance.now();
  const elapsed = end - start;

  console.log(`${label}: ${elapsed.toFixed(3)}ms`);
  return elapsed;
}

export function loop(func: () => any, count: number) {
  for (let i = 0; i < count; i++) func();
}
