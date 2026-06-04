require 'optparse'

require_relative 'maze'
require_relative 'hexa_maze'

class Generator
  class << self
    def perform(options)
      @options = options

      maze_klass = options[:shape] == :hexa ? HexaMaze : Maze

      @maze = maze_klass.new(
        options[:height].times.map do |y|
          options[:width].times.map do |x|
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

      if @options[:shape] == :hexa
        neighbours += [
          [@maze.neighbour(cell.pos, :down_right), :down_right],
          [@maze.neighbour(cell.pos, :down_left), :down_left],
        ]
      end

      neighbours.reject {|cell, _pos| cell.nil? || cell.visited }.sample
    end

    def open_entrance(entrance)
      return @maze.at(entrance).walls.up = false if entrance.y == 0

      walls_to_open = [:left]
      walls_to_open += [:down_left] if @options[:shape] == :hexa

      @maze.at(entrance).walls.send(:"#{walls_to_open.sample}=" ,false)
    end

    def open_exit(exit_)
      return @maze.at(exit_).walls.down = false if exit_.y == @maze.height - 1

      walls_to_open = [:right]
      walls_to_open += [:down_right] if @options[:shape] == :hexa

      @maze.at(exit_).walls.send(:"#{walls_to_open.sample}=" ,false)
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

options = {width: 10, height: 10, shape: :square}

OptionParser.new do |parser|
  parser.on('-s SHAPE', '--shape', %i[square hexa], "Tile shape. Can be 'square' or 'hexa'. Default to 'square'")
  parser.on('-w WIDTH', '--width', Integer)
  parser.on('-h HEIGHT', '--height', Integer)
end.parse!(into: options)

puts Generator.perform(options)
