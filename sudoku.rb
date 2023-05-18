class Sudoku
  attr_accessor :starting_board, :solution, :removed_values, :difficulty

  BLANK_BOARD = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0]
  ]

  def initialize(holes = 30)
    holes > 64 ? 64 : holes
    generate_game(holes)
  end

  def generate_game(holes)
    begin
      @iteration_counter = 0
      self.solution = new_solved_board
      self.removed_values, self.starting_board = poke_holes(self.solution.map(&:clone), holes)
      self.difficulty = holes
    rescue
      generate_game(holes)
    end
  end

  def new_solved_board
    new_board = BLANK_BOARD.map(&:clone)
    solve(new_board)
    new_board
  end

  def solve (puzzle_matrix)
    empty_cell = find_next_empty_cell(puzzle_matrix)
    return puzzle_matrix if !empty_cell

    # Fill in the empty cell
    for num in (1..9).to_a.shuffle do
      raise if (@iteration_counter > 1_000_000)
      if safe(puzzle_matrix, empty_cell, num)
        puzzle_matrix[empty_cell[:row_i]][empty_cell[:col_i]] = num
        return puzzle_matrix if solve(puzzle_matrix)
        puzzle_matrix[empty_cell[:row_i]][empty_cell[:col_i]] = 0
      end
    end
    return false
  end

  def find_next_empty_cell(puzzle_matrix)
    empty_cell = {row_i:"",col_i:""}
    for row in puzzle_matrix do
      next_zero_index = row.find_index(0)
      empty_cell[:row_i] = puzzle_matrix.find_index(row)
      empty_cell[:col_i] = next_zero_index
      return empty_cell if empty_cell[:col_i]
    end

    return false
  end

  def safe(puzzle_matrix, empty_cell, num)
    row_safe(puzzle_matrix, empty_cell, num) &&
      col_safe(puzzle_matrix, empty_cell, num) &&
      box_safe(puzzle_matrix, empty_cell, num)
  end

  def row_safe (puzzle_matrix, empty_cell, num)
    !puzzle_matrix[ empty_cell[:row_i] ].find_index(num)
  end

  def col_safe (puzzle_matrix, empty_cell, num)
    !puzzle_matrix.any?{|row| row[ empty_cell[:col_i] ] == num}
  end

  def box_safe (puzzle_matrix, empty_cell, num)
    box_start_row = (empty_cell[:row_i] - (empty_cell[:row_i] % 3))
    box_start_col = (empty_cell[:col_i] - (empty_cell[:col_i] % 3))

    (0..2).to_a.each do |box_row|
      (0..2).to_a.each do |box_col|
        return false if puzzle_matrix[box_start_row + box_row][box_start_col + box_col] == num
      end
    end
    return true
  end


  def poke_holes(puzzle_matrix, holes)
    removed_values = []

    while removed_values.length < holes
      row_i = (0..8).to_a.sample
      col_i = (0..8).to_a.sample

      next if (puzzle_matrix[row_i][col_i] == 0)
      removed_values.push({row_i: row_i, col_i: col_i, val: puzzle_matrix[row_i][col_i] })
      puzzle_matrix[row_i][col_i] = 0

      proposed_board = puzzle_matrix.map(&:clone)

      puzzle_matrix[row_i][col_i] = removed_values.pop[:val] if !solve( proposed_board )
    end

    [removed_values, puzzle_matrix]
  end

end