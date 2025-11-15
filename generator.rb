require_relative 'maze'

class Generator
  class << self
    def perform(width, height)
      @maze = height.times.map do |y|
        width.times.map do |x|
          Cell.new(pos: Pos.new(x, y))
        end
      end

      open_walls
      # entrance is a cell where x == 0 or y == 0
      open_entrance(random_entrance)
      # exit is a cell where x == width or y == height
      open_exit(random_exit)

      Maze.new(@maze)
    end

    private

    # https://en.wikipedia.org/wiki/Maze_generation_algorithm#Iterative_implementation_(with_stack)
    def open_walls
      cell = @maze.sample.sample
      cell.visited = true
      stack = [cell]

      until stack.empty?
        neighbour, relative_pos = random_unvisited_neighbour(cell)

        next cell = stack.pop if neighbour.nil?

        open_wall(cell, neighbour, relative_pos)

        stack.push(cell)

        neighbour.visited = true

        cell = neighbour
      end
    end

    def random_unvisited_neighbour(cell)
      neighbours = []

      neighbours.push([@maze[cell.pos.y - 1][cell.pos.x], :up]) if cell.pos.y > 0
      neighbours.push([@maze[cell.pos.y + 1][cell.pos.x], :down]) if cell.pos.y < @maze.length - 1
      neighbours.push([@maze[cell.pos.y][cell.pos.x - 1], :left]) if cell.pos.x > 0
      neighbours.push([@maze[cell.pos.y][cell.pos.x + 1], :right]) if cell.pos.x < @maze[0].length - 1

      neighbours.reject {|cell, _pos| cell.visited }.sample
    end

    def open_wall(cell, neighbour, relative_pos)
      case relative_pos
      when :up
        cell.walls.up = false
        neighbour.walls.down = false
      when :down
        cell.walls.down = false
        neighbour.walls.up = false
      when :left
        cell.walls.left = false
        neighbour.walls.right = false
      when :right
        cell.walls.right = false
        neighbour.walls.left = false
      end
    end

    def open_entrance(entrance)
      return @maze[entrance.y][entrance.x].walls.up = false if entrance.y == 0

      @maze[entrance.y][entrance.x].walls.left = false
    end

    def open_exit(exit_)
      return @maze[exit_.y][exit_.x].walls.down = false if exit_.y == @maze.length - 1

      @maze[exit_.y][exit_.x].walls.right = false
    end

    def random_entrance
      [
        Pos.new(rand(@maze[0].length), 0),
        Pos.new(0, rand(@maze.length))
      ].sample
    end

    def random_exit
      max_x = @maze[0].length
      max_y = @maze.length

      [
        Pos.new(rand(max_x), max_y - 1),
        Pos.new(max_x - 1, rand(max_y))
      ].sample
    end
  end
end

puts Generator.perform(ARGV[0].to_i, ARGV[1].to_i)
