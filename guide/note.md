# Main

Experiment with separate function for every cell? Idk.

# Fire

Change pixel color every frame

# Gas Gravity

Thinking of ways to make different spread:
- Randomize to sometimes change the velocity of heavy spread particles like fire?
- Remove the cardinal velocity limit and sometimes add multiple velocities to them.
- Function that sometimes randomizes the velocity of said particles. Maybe somehow revert it back later.


# Spawner

For this to work:

```glsl
if(type != EMPTY && type != BLOCK) {
  if(cell.rng < 30) return cell;
}
```

I need static RNG, meaning that it's based on the grid, and it's not Cell state.

Actually this sounds like some hash based on the grid coordinates.

# Heat Transfer

`total amount of heat in block` / 4

Maybe transfer slowly, once every few frames.

Add color to some elements based on heat.

Create fire out of heated empty cells.
