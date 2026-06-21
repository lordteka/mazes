require_relative 'maze'

class HexaMaze < Maze
  RIGHT_WALL_CHAR = '\\'.freeze
  LEFT_WALL_CHAR = '/'.freeze
  VERTICAL_WALL_CHAR = '_'.freeze
  EMPTY_CHAR = ' '.freeze

  class << self
    def from_string(s)
      lines = s.split("\n")
      cell_y = -1

      HexaMaze.new(
        (1...lines.length-1).step(2).map do |line|
          cell_x = -1
          cell_y += 1

          (1...lines[line].length).step(3).map do |x|
            cell_x += 1
            y = cell_x % 2 == 0 ? line : line + 1

            Cell.new(
              pos: Pos.new(cell_x, cell_y),
              walls: Walls.new(
                up: lines[y - 1][x] != EMPTY_CHAR && lines[y - 1][x + 1] != EMPTY_CHAR,
                right: lines[y][x + 2] != EMPTY_CHAR,
                down: lines[y + 1][x] != EMPTY_CHAR && lines[y + 1][x + 1] != EMPTY_CHAR,
                left: lines[y][x - 1] != EMPTY_CHAR,
                down_right: lines[y + 1][x + 2] != EMPTY_CHAR,
                down_left: lines[y + 1][x - 1] != EMPTY_CHAR,
              )
            )
          end
        end
      )
    end
  end

  def to_s
    x_length = width * 3 + 2
    s = EMPTY_CHAR * (x_length * (height * 2 + 2))

    @maze.each do |line|
      line.each do |cell|
        i = cell.pos.x * 3 + 1
        i += (cell.pos.y * 2 + 1) * x_length
        i += x_length if cell.pos.x % 2 == 1

        s[i] = cell.path ? PATH_CHAR : EMPTY_CHAR

        s[i - x_length] = cell_wall_char(cell, :up)
        s[i + 1 - x_length] = cell_wall_char(cell, :up)

        s[i + 2] = cell_wall_char(cell, :right)
        s[i + 2 + x_length] = cell_wall_char(cell, :down_right)

        s[i + x_length] = cell_wall_char(cell, :down)
        s[i + 1 + x_length] = cell_wall_char(cell, :down)

        s[i - 1] = cell_wall_char(cell, :left)
        s[i - 1 + x_length] = cell_wall_char(cell, :down_left)


        if cell.pos.x == width - 1
          s[i + 3 - 2 * x_length] = "\n" if cell.pos.y == 0
          s[i + 3 - x_length] = "\n" if cell.pos.y == 0
          s[i + 3] = "\n"
          s[i + 3 + x_length] = "\n"
        end
      end
    end

    colorize(s)
  end

  def neighbour(pos, direction)
    floor = pos.x % 2 == 0 ? :high : :low

    case [direction, floor]
    when [:right, :high]
      return if pos.x == width - 1 || pos.y == 0

      @maze[pos.y - 1][pos.x + 1]
    when [:left, :high]
      return if pos.x == 0 || pos.y == 0

      @maze[pos.y - 1][pos.x - 1]
    when [:down_right, :low]
      return if pos.x == width - 1 || pos.y == height - 1

      @maze[pos.y + 1][pos.x + 1]
    when [:down_left, :low]
      return if pos.x == 0 || pos.y == height - 1

      @maze[pos.y + 1][pos.x - 1]
    when [:down_right, :high]
      super(pos, :right)
    when [:down_left, :high]
      super(pos, :left)
    else
      super(pos, direction)
    end
  end

  private

  def change_wall_state(pos, direction, state)
    cell = @maze[pos.y][pos.x]
    cell.walls.send(:"#{direction}=", state)

    case direction
    when :up
      neighbour(cell.pos, :up).walls.down = state
    when :right
      neighbour(cell.pos, :right).walls.down_left = state
    when :down
      neighbour(cell.pos, :down).walls.up = state
    when :left
      neighbour(cell.pos, :left).walls.down_right = state
    when :down_right
      neighbour(cell.pos, :down_right).walls.left = state
    when :down_left
      neighbour(cell.pos, :down_left).walls.right = state
    end
  end

  def cell_wall_char(cell, direction)
    if cell.walls.send(direction)
      case direction
      when :up, :down
        return VERTICAL_WALL_CHAR
      when :right, :down_left
        return RIGHT_WALL_CHAR
      when :left, :down_right
        return LEFT_WALL_CHAR
      end
    end

    super(cell, direction)
  end
end
