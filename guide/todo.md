# Refactor

The logic should be in functions for each element type.

# Element Groups

Elements should be separated into groups, for example `STATIC`, `ACTIVE`, `SOLID`, `LIQUID`, etc.

in this:

```glsl
if(neighbors.y == SAND) {
if(neighbors.z == EMPTY && neighbors.x == EMPTY)
  return EMPTY
}
```

Instead of horizontal empty, check if not falling.

# Colors

Randomize the colors a bit.
