require 'yaml'
require 'benchmark'

class MineSweeper
  attr_reader :hidden_board, :view_board
  attr_accessor :flags, :time_taken

  def initialize(size = 9, bombs = 10)
    @hidden_board = Board.new(0, size, bombs)
    @view_board = Board.new('*', size)
    @flags = []
    @time_taken = 0
  end

  def reveal_squares(pos)
    self.view_board.reveal_squares(pos, self.hidden_board)
  end

  def set_flag(pos)
    if self.view_board.board[pos[0]][pos[1]] == '*'
      self.view_board.set_flag(pos)
      self.flags << pos
    end
  end

  def game_won?
    return false if flags.size < 10

    self.flags.each do |flag_pos|
      x, y = flag_pos[0], flag_pos[1]
      return false if self.hidden_board.board[x][y] != 'b'
    end

    true
  end

  def input_pos
    puts 'Enter a position:'
    print 'Format: "x, y": '
    inputs = gets.chomp.split(',')
    inputs.map { |el| el.to_i }
  end

  def input_option
    print 'Options: r - reveal, f - flag, s - save, l - load: '
    gets.chomp
  end

  def save_file
    File.open('minesweeper.txt','w') do |file|
      file.puts self.to_yaml
    end

    puts "\nState saved to 'minesweeper.txt'"
  end

  def load_file
    temp = YAML::load(File.open('minesweeper.txt'))
    self.view_board.board = temp.view_board.board
    self.hidden_board.board = temp.hidden_board.board
    self.flags = temp.flags
    self.time_taken = temp.time_taken

    puts "\nPrevious state loaded from 'minesweeper.txt'"
  end

  def play
    t0 = Time.now
    fin = false
    until game_won? || fin
      #self.hidden_board.show_board
      self.view_board.show_board
      puts
      case  input_option
      when 'r'
        inputs = input_pos
        if self.hidden_board.bomb?(inputs)
          self.hidden_board.show_board
          puts "You LOSE!"
          fin = true
        else
          reveal_squares(inputs)
        end
      when 'f'
        inputs = input_pos
        set_flag(inputs)
      when 's'
        t1 = Time.now
        self.time_taken = (t1 - t0).to_i
        save_file
        fin = true
      when 'l'
        load_file
        t0 = Time.now - time_taken
      else
        puts 'wrong input!'
      end
    end
    t1 = Time.now
    self.time_taken = (t1 - t0).to_i
    puts "\nTime taken: #{self.time_taken}"
  end
end

class Board
  attr_accessor :board

  def initialize(char = '*', size = 9, bombs = 10)#view_board
    @board = Array.new(size) { Array.new(size) {char} }
    hidden_board(size, bombs) if char == 0
  end

  def hidden_board(size, bombs)
    count = 0
    while count < bombs
      x = (0..size-1).to_a.sample
      y = (0..size-1).to_a.sample
      if self.board[x][y] == 'b'
        next
      else
        self.board[x][y] = 'b'
        update_adjacent_squares([x,y])
        count += 1
      end
    end
  end

  def update_adjacent_squares(pos)
    get_adjacent_squares(pos).each do |adjacent_pos|
      x = adjacent_pos[0]
      y = adjacent_pos[1]
      self.board[x][y] += 1 unless self.board[x][y] == 'b'
    end
  end

  def show_board
    puts
    len = self.board.length - 1
    (0..len).each do |i|
      (0..len).each do |j|
        print self.board[i][j], "  "
      end
      puts
    end
  end

  def bomb?(pos)
    x = pos[0]
    y = pos[1]
    self.board[x][y] == 'b'
  end

  def get_adjacent_squares(pos)
    x, y  = pos[0], pos[1]
    x_min, x_max = x-1, x+1
    y_min, y_max = y-1, y+1
    len = self.board.length - 1
    [].tap do |positions|
      (x_min..x_max).each do |x|
        (y_min..y_max).each do |y|
          positions << [x, y] if (x.between?(0,len) and y.between?(0,len))
        end
      end
    end - [pos]
  end

  def reveal_squares(pos, hidden_board)
    x = pos[0]
    y = pos[1]
    if hidden_board.board[x][y] == 'b'
      return
    elsif self.board[x][y] == 'f'
      return
    elsif hidden_board.board[x][y] != 0 #reveal - 1,2,3
      self.board[x][y] = hidden_board.board[x][y]
      return
    elsif self.board[x][y] != '_'#when 0s
      adj_squares = get_adjacent_squares(pos) # array of postions of adj squares
      self.board[x][y] = '_'
      adj_squares.each do |adj_pos|
        reveal_squares(adj_pos, hidden_board)
      end
      #get_adjacent_squares(pos) # array of postions of adj squares
    end
  end

  def set_flag(pos)
    self.board[pos[0]][pos[1]] = 'f'
  end

end #Board class

new_game = MineSweeper.new
#new_game.hidden_board.show_board
puts
new_game.play