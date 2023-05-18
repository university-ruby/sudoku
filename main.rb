require 'sinatra'
require_relative 'sudoku.rb'

sudoku = Sudoku.new()

board_string = []

sudoku.starting_board.each do |row|
  board_string.append(row.join(" "))
end

get '/' do
  erb :index, locals: {board: board_string}
end

post '/result' do
  user_board = params['board'].split("\n").map { |row| row.strip.split(' ').map(&:to_i) }

  erb :result, locals: { user_board: user_board, auto_board: sudoku.solution }
end
