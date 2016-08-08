require 'open-uri'
require 'json'

class PagesController < ApplicationController

  def game
    session[:start_time] = Time.now.to_i
    session[:grid] = grid_generator
  end

  def score
    @time = time_calculator
    @guess = params[:guess]
    @match = is_in_the_grid?(@guess.downcase)
    @real_word = is_the_word_exist?(@guess.downcase)
    games_records
  end

  def games_records
    if session[:scores_avg].nil?
      session[:scores] = []
      session[:scores] << score_calculator(@guess, @time)
      session[:games_nb] = 1
      session[:scores_avg] = session[:scores].inject{ |sum, el| sum + el }.to_f / session[:scores].size
    else
      session[:games_nb] += 1
      session[:scores] << score_calculator(@guess, @time)
      session[:scores_avg] = session[:scores].inject{ |sum, el| sum + el }.to_f / session[:scores].size
    end
  end

  def time_calculator
    end_time = Time.now.to_i
    session[:start_time] - end_time
  end

  def is_in_the_grid?(word)
    word.each_char { |char| return false unless session[:grid].include?(char) }
    true
  end

  def grid_generator
    random_grid = []
    (1..14).to_a.each { random_grid << ('a'..'z').to_a.sample }
    random_grid
  end

  def score_calculator(word, time)
    (@match && @real_word) ? ((word.length * 10) - time) : 0
  end

  def is_the_word_exist?(word)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{word}"
    json = JSON.parse(open(api_url).read)
    if json.key?("Error")
      return false
    end
    true
  end
end
