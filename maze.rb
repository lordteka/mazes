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

Cell = Struct.new('Cell', :visited, :pos, :walls, keyword_init: true) do
  def initialize(*)
    super

    self.visited ||= false
    self.walls ||= Walls.new
  end
end

class Maze
  def initialize(cells)
    @maze = cells
  end

  def to_s
    [
      "+#{@maze[0].map { |cell| cell.walls.up ? '-' : ' ' }.join('+')}+\n",
      @maze.map do |line|
        [
          "#{line[0].walls.left ? '|' : ' '} #{line.map { |cell| cell.walls.right ? '|' : ' ' }.join(' ')}\n",
          "+#{line.map { |cell| cell.walls.down ? '-' : ' ' }.join('+')}+\n"
        ]
      end
    ].join('')
  end

  def self.from_string(s)
    lines = s.split("\n")
    cell_x = -1
    cell_y = -1

    Maze.new(
      (1...lines.length).step(2).map do |y|
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
end
