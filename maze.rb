Pos = Struct.new('Pos', :x, :y)
Walls = Struct.new('Walls', :up, :right, :down, :left) do
  def initialize(*)
    super

    # For now `up` and `left` are redondant
    self.up = true
    self.right = true
    self.down = true
    self.left = true
  end
end

Cell = Struct.new('Cell', :visited, :pos, :walls, keyword_init: true) do
  def initialize(*)
    super
    self.visited ||= false
    self.walls ||= Walls.new
  end
end

class Maze
  def initialize(width, height)
    @maze = height.times.map do |y|
      width.times.map do |x|
        Cell.new(pos: Pos.new(x, y))
      end
    end

    open_walls
  end

  def to_s
    [
    "+#{@maze[0].map { '-' }.join('+')}+\n",
    @maze.map do |line|
      [
        "| #{line.map { |cell| cell.walls.right ? '|' : ' ' }.join(' ')}\n",
        "+#{line.map { |cell| cell.walls.down ? '-' : ' ' }.join('+')}+\n"
      ].join('')
    end
    ].join('')
  end

  private

  # https://en.wikipedia.org/wiki/Maze_generation_algorithm#Iterative_implementation_(with_stack)
  def open_walls
    stack = [@maze.sample.sample]

    while !stack.empty?
      cell = stack.pop

      neighbour, relative_pos = random_unvisited_neighbour(cell)

      next if neighbour.nil?

      open_wall(cell, neighbour, relative_pos)

      stack.push(cell)
      neighbour.visited = true
      stack.push(neighbour)
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
end

puts Maze.new(ARGV[0].to_i, ARGV[1].to_i)
