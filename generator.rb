require_relative 'maze'

class Generator
  class << self
    def perform(width, height)
      @maze = Maze.new(
        height.times.map do |y|
          width.times.map do |x|
            Cell.new(pos: Pos.new(x, y))
          end
        end
      )

      open_walls
      # entrance is a cell where x == 0 or y == 0
      open_entrance(random_entrance)
      # exit is a cell where x == width or y == height
      open_exit(random_exit)

      @maze
    end

    private

    # https://en.wikipedia.org/wiki/Maze_generation_algorithm#Iterative_implementation_(with_stack)
    def open_walls
      cell = @maze.sample
      cell.visited = true
      stack = [cell]

      until stack.empty?
        neighbour, relative_pos = random_unvisited_neighbour(cell)

        next cell = stack.pop if neighbour.nil?

        @maze.open_wall(cell.pos, relative_pos)

        stack.push(cell)

        neighbour.visited = true

        cell = neighbour
      end
    end

    def random_unvisited_neighbour(cell)
      neighbours = [
        [@maze.neighbour(cell.pos, :up), :up],
        [@maze.neighbour(cell.pos, :right), :right],
        [@maze.neighbour(cell.pos, :down), :down],
        [@maze.neighbour(cell.pos, :left), :left]
      ]

      neighbours.reject {|cell, _pos| cell.nil? || cell.visited }.sample
    end

    def open_entrance(entrance)
      return @maze.at(entrance).walls.up = false if entrance.y == 0

      @maze.at(entrance).walls.left = false
    end

    def open_exit(exit_)
      return @maze.at(exit_).walls.down = false if exit_.y == @maze.height - 1

      @maze.at(exit_).walls.right = false
    end

    def random_entrance
      [
        Pos.new(rand(@maze.width), 0),
        Pos.new(0, rand(@maze.height))
      ].sample
    end

    def random_exit
      max_x = @maze.width
      max_y = @maze.height

      [
        Pos.new(rand(max_x), max_y - 1),
        Pos.new(max_x - 1, rand(max_y))
      ].sample
    end
  end
end

puts Generator.perform(ARGV[0].to_i, ARGV[1].to_i)
