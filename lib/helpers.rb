module Helpers
  module Format
    def clear_screen
      system 'clear'
    end

    def prompt
      puts
      print '> '
      input = gets.chomp
      puts
      input
    end

    def prompt_continue
      puts
      print "Hit RETURN to continue..."
      gets
    end

    def prompt_for_next_turn
      puts
      print "Hit RETURN to advance to next player's turn..."
      gets
    end

    def choose_num(option_range)
      choice = nil
      loop do
        choice = prompt.to_i
        break if (option_range).include?(choice)
        puts 'Sorry, that is not a valid choice...'
      end
      choice
    end

    def no_event_msg
      puts
      puts 'Nothing happens...'
    end
  end
end
