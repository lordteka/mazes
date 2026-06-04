## Prerequite

Ruby 3 or above

## Usage

### Generate maze

`ruby generator.rb -w <width> -h <height> [-s <square|hexa>]`

### Solve square maze

The solver assume the same input format as the generator output

`ruby solver.rb maze.txt`

`ruby generator.rb -w <width> -h <height> | ruby solver.rb`
