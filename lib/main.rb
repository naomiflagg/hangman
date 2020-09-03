class Hangman
  require 'yaml'

  def initialize
    new_game
  end

  def new_game
    puts 'Welcome to Hangman!'
    unless open_saved_game?
      set_word
      display_instructions
      @guesses_left = 6
    end
    play_game
  end

  def open_saved_game?
    puts 'Would you like to open a saved game? If yes, type Y and press enter.'
    return unless gets.chomp.upcase == 'Y'

    begin 
      from_yaml('naomi_hangman_game.yml')
    rescue
      puts "Sorry, no saved file was found. Let's start a new game!"
    end
  end

  def from_yaml(file)
    data = YAML.load_file(file)
    @secret_word = data[:secret_word]
    @guesses_left = data[:guesses_left]
    @guessing = data[:guessing]
  end

  def set_word
    dict = File.readlines('../5desk.txt').each(&:chomp!)
    # Create array of words between 5 and 12 characters, then select randomly
    words = dict.select { |line| line.size.between?(5, 12) }
    @secret_word = words.sample.upcase
    @guessing = ['_'] * @secret_word.size
  end

  def display_instructions
    puts "The computer has randomly selected a word 5-12 letters long. Your\n" \
      "goal is to guess the word by guessing letters one at a time. For each\n"\
      "guess, the computer will let you know if the letter is in the word. If it's\n"\
      "not, you lose a guess. You will begin with 6 guesses, and if you get to 0,\n"\
      'you lose. Time for your first guess. Good luck!'
  end

  def play_game
    loop do
      display_guessing
      ask_for_guess
      evaluate_guess
      break if game_over?

      break if save_game?
    end
  end

  def save_game?
    puts 'Would you like to save your game and exit? If yes, type Y and press enter.'
    if gets.chomp.upcase == 'Y'
      File.open('naomi_hangman_game.yml', 'w') { |file| file.puts to_yaml }
      return true
    end
  end

  def to_yaml
    YAML.dump({ secret_word: @secret_word, guesses_left: @guesses_left, guessing: @guessing })
  end

  def ask_for_guess
    loop do
      puts 'Time to guess a letter. Type a single letter and press enter.'
      @guess = gets.chomp.upcase
      break if @guess.match(/^[[:alpha:]]$/) && @guess.size == 1

      puts 'Your guess must be a single letter. Try again.'
    end
  end

  def evaluate_guess
    if @secret_word.include?(@guess)
      puts "Well done! #{@guess} is in the secret word."
      add_letter
    else
      puts "Uh oh. #{@guess} is not in the secret word. You lose a guess."
      @guesses_left -= 1
    end
  end

  def add_letter
    @secret_word.each_char.with_index do |ch, idx|
      if ch == @guess
        @guessing[idx] = @guess
      end
    end
  end

  def game_over?
    if @guessing.join('') == @secret_word
      p "Congrats! You got it. The word was #{@secret_word}."
    elsif @guesses_left.zero?
      p "Sorry, but you've run out of guesses. The word was #{@secret_word}."
    end
  end

  def display_guessing
    puts "Your guess so far: #{@guessing.join(' ')}\nWrong guesses left: #{@guesses_left}"
  end
end

Hangman.new
