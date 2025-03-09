# Main

Experiment with separate function for every cell? Idk.

# Slow Entropy

Right now the entropy is instant 1:1

Make it incremental.

# Generator

Should probably be uint

# Temperature

Heat should start from 0 (for now absolute zero), with 30 default.

If water heat is high increase the spread.

If low reduce the spread?

## Air Transfer

If you want to make air transfer, you can add state to the Empty cells.

The state shows how close they are to a non-empty cell.

This state can be transfered with entropy between empty cells.

For example, the closest is 5, then 4, 3, 2, 1, and if there are no non-empty neighbors - 0.

This will create a "shield" around the non-empty cells.

This shield is not so big, as it has the entropy limit with lower integers.

Make these shield cells transfer heat via entropy.

# Fire

Change pixel color every frame

# Gas Gravity

Thinking of ways to make different spread:
- Randomize to sometimes change the velocity of heavy spread particles like fire?
- Remove the cardinal velocity limit and sometimes add multiple velocities to them.
- Function that sometimes randomizes the velocity of said particles. Maybe somehow revert it back later.

# Soak Integer Logic
The higher the integer, the more it equalizes with others due to entropy.
(3,  0) => (2,  1)
(30, 0) => (15, 15)

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
