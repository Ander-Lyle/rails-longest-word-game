require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @grid = []
    10.times { @grid << (('A'..'Z').to_a.sample) }
  end

  def score
    @new_start_time = Time.parse(params[:time])
    @end_time = Time.now
    @word = params[:word]
    @new_grid = params[:grid].gsub(' ', '').chars
    @result = run_game(@new_start_time, @end_time, @word, @new_grid)[:message]
    @score = run_game(@new_start_time, @end_time, @word, @new_grid)[:score]
    @time = run_game(@new_start_time, @end_time, @word, @new_grid)[:time]
  end

  private

  def run_game(start_time, end_time, word, grid)
    result = {}
    result[:score] = 0
    result[:time] = end_time - start_time

    attempt_hash = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{word}").read)
    valid_word = word.upcase.chars.all? { |letter| word.upcase.count(letter) <= grid.count(letter) }
    result_message(word, result, attempt_hash, valid_word)
  end

  def result_message(word, result, attempt_hash, valid_word)
    if !attempt_hash['found']
      result[:message] = 'Not an English word.'
    elsif !valid_word
      result[:message] = 'Not in the grid.'
    else
      result[:message] = 'Well done!'
      result[:score] = ((result[:time] / word.chars.size)).to_i
    end

    result
  end
end
