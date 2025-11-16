Pos = Struct.new('Pos', :x, :y)

Walls = Struct.new('Walls', :up, :right, :down, :left, keyword_init: true) do
  def initialize(*)
    super

    self.up = true if self.up != false
    self.right = true if self.right != false
    self.down = true if self.down != false
    self.left = true if self.left != false
  end
end

Cell = Struct.new('Cell', :visited, :pos, :walls, :path, keyword_init: true) do
  def initialize(*)
    super

    self.visited ||= false
    self.path ||= false
    self.walls ||= Walls.new
  end
end

class Maze
  def self.from_string(s)
    lines = s.split("\n")
    cell_y = -1

    Maze.new(
      (1...lines.length).step(2).map do |y|
        cell_x = -1
        cell_y += 1

        (1...lines[y].length).step(2).map do |x|
          cell_x += 1

          Cell.new(
            pos: Pos.new(cell_x, cell_y),
            walls: Walls.new(
              up: lines[y - 1][x] != ' ',
              right: lines[y][x + 1] != ' ',
              down: lines[y + 1][x] != ' ',
              left: lines[y][x - 1] != ' '
            )
          )
        end
      end
    )
  end

  def initialize(cells)
    @maze = cells
  end

  def to_s
    x_length = (width + 1) * 2
    s = ' ' * (((width + 1) * 2) * (height * 2 + 1))

    @maze.each do |line|
      line.each do |cell|
        i = cell.pos.x * 2 + 1 + (cell.pos.y * 2 + 1) * x_length

        s[i] = cell.path ? '*' : ' '

        # cell corners
        s[i - x_length - 1] = '+'
        s[i - x_length + 1] = '+'
        s[i + x_length - 1] = '+'
        s[i + x_length + 1] = '+'

        # cell walls
        s[i - 1] = cell_wall_char(cell, :left)
        s[i + 1] = cell_wall_char(cell, :right)
        s[i - x_length] = cell_wall_char(cell, :up)
        s[i + x_length] = cell_wall_char(cell, :down)

        # line breaks
        if cell.pos.x == width - 1
          s[i - x_length + 2] = "\n"
          s[i + 2] = "\n"
          s[i + x_length + 2] = "\n"
        end
      end
    end

    s
  end

  def path?(cell)
    !cell.visited?
  end

  def deep_clone
    Maze.new(
      @maze.map do |line|
        line.map do |cell|
          Cell.new(pos: cell.pos, walls: cell.walls.clone)
        end
      end
    )
  end

  def each
    @maze.each do |line|
      line.each do |cell|
        yield cell
      end
    end
  end

  def sample
    @maze.sample.sample
  end

  def height
    @maze.length
  end

  def width
    @maze[0].length
  end

  def [](index)
    @maze[index]
  end

  def open_wall(pos, direction)
    change_wall_state(pos, direction, false)
  end

  def close_wall(pos, direction)
    change_wall_state(pos, direction, true)
  end

  private

  def change_wall_state(pos, direction, state)
    cell = @maze[pos.y][pos.x]

    case direction
    when :up
      cell.walls.up = state
      @maze[pos.y - 1][pos.x].walls.down = state
    when :down
      cell.walls.down = state
      @maze[pos.y + 1][pos.x].walls.up = state
    when :left
      cell.walls.left = state
      @maze[pos.y][pos.x - 1].walls.right = state
    when :right
      cell.walls.right = state
      @maze[pos.y][pos.x + 1].walls.left = state
    end
  end

  def cell_wall_char(cell, direction)
    if cell.walls.send(direction)
      case direction
      when :up, :down
        return '-'
      when :left, :right
        return '|'
      end
    end

    return ' ' if !cell.path

    case direction
    when :up
      return '*' if cell.pos.y == 0

      @maze[cell.pos.y - 1][cell.pos.x].path ? '*' : ' '
    when :right
      return '*' if cell.pos.x == width - 1

      @maze[cell.pos.y][cell.pos.x + 1].path ? '*' : ' '
    when :down
      return '*' if cell.pos.y == height - 1

      @maze[cell.pos.y + 1][cell.pos.x].path ? '*' : ' '
    when :left
      return '*' if cell.pos.x == 0

      @maze[cell.pos.y][cell.pos.x - 1].path ? '*' : ' '
    end
  end
end
