require_relative 'maze'

class Solver
  class << self
    def perform(maze)
      @maze = maze.deep_clone

      while fill_dead_ends; end

      @maze.each do |cell|
        if !cell.visited
          maze[cell.pos.y][cell.pos.x].path = true
        end
      end

      maze
    end

    private

    def fill_dead_ends
      any = false

      @maze.each do |cell|
        if cell.walls.count(&:itself) == 3
          any = true
          cell.visited = true

          direction = cell.walls.deconstruct_keys([:up, :right, :down, :left]).select { |k, v| !v }.keys.first

          @maze.close_wall(cell.pos, direction)
        end
      end

      any
    end
  end
end

puts Solver.perform(Maze.from_string(ARGF.read))
