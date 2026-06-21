require_relative 'hexa_maze'

class Solver
  class << self
    def perform(string)
      maze = get_maze(string)
      @maze = maze.deep_clone

      while fill_dead_ends; end

      @maze.each do |cell|
        if !cell.visited
          maze.at(cell.pos).path = true
        end
      end

      maze
    end

    private

    def get_maze(string)
      if string[0] == Maze::CORNER_CHAR
        Maze.from_string(string)
      else
        HexaMaze.from_string(string)
      end
    end

    def fill_dead_ends
      any = false

      @maze.each do |cell|
        if cell.walls.count(&:itself) == 5
          any = true
          cell.visited = true

          direction = cell.walls.deconstruct_keys(%i[up right down left down_left down_right]).select { |k, v| !v }.keys.first

          @maze.close_wall(cell.pos, direction)
        end
      end

      any
    end
  end
end

puts Solver.perform(ARGF.read)
