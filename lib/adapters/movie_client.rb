module Adapters
  class MovieClient

    include HTTParty

    attr_reader :connection

    def initialize
      @connection = self.class
    end

    def get_json(url)
      results = connection.get(url)
      json = RecursiveOpenStruct.new(results, :recurse_over_arrays => true)
    end

    def find_winner(films_array)
      films_array.find do |film|
        film.Winner
      end
    end

    def get_winners
      json = get_json('http://oscars.yipitdata.com/')
      json.results.collect do |films_array|
        find_winner(films_array.films).tap do |winner|
          winner[:year] = films_array.year[0,4]
        end
      end
    end

    def format_title(unformatted_title)
      unformatted_title.gsub(/ *\[[^)]*\] */, "").strip
    end

    # def convert_from_pounds(budget_in_words)
    #   if budget_in_words[0] == "£"
    #     budget = budget_in_words.delete("£").delete(",").split(" ")
    #     budget_in_words = "$#{(budget[0].to_i * 1.49).round} #{budget[1]}"
    #   end
    #   budget_in_words
    # end
    #
    # def avg_range(budget_in_words)
    #   budget_in_words = budget_in_words.gsub("-","–")
    #   if budget_in_words.include?("–")
    #     budget_array = budget_in_words.split("–")
    #     budget_in_words = budget_array[0][0] + budget_array[1]
    #   end
    #   budget_in_words
    # end
    #
    # def multiply_by_suffix(budget_in_words)
    #   if budget_in_words.include?("million")
    #     budget_in_words.delete("US").sub(" ","")
    #     budget_arrays = budget_in_words.split("m")
    #     budget = budget_arrays[0][1..-1].to_i * 1000000
    #   else
    #     budget = budget_in_words.delete(",").delete("$").to_i
    #   end
    # end
    #
    # def convert_to_int(budget_in_words)
    #   budget_in_words = avg_range(budget_in_words)
    #   budget_in_words = convert_from_pounds(budget_in_words)
    #   budget = multiply_by_suffix(budget_in_words)
    # end
    #
    # def clear_off_extras(unformatted_budget)
    #   budget_in_words = unformatted_budget.gsub(/ *\[[^)]*\] */, "").
    #     gsub(/ *\([^)]*\) */, "").gsub("US","")
    # end
    #
    # def format_budget(unformatted_budget)
    #   if unformatted_budget
    #     budget_in_words = clear_off_extras(unformatted_budget)
    #     budget = convert_to_int(budget_in_words)
    #   else
    #     "NO BUDGET"
    #   end
    # end
    #
    # def update_totals(budget)
    #   Movie.increase_movie_count
    #   Movie.add_to_budget(budget)
    # end

    def winner_data(winner)
      results=get_json(winner['Detail URL'])
      year = winner.year
      title = format_title(winner.Film)
      # budget = format_budget(results.Budget)
      budget = BudgetServiceObject.new(results.Budget).format
      update_totals(budget) unless budget == "NO BUDGET"
      puts "#{year} - #{title} - #{budget}"
    end

    def seed
      get_winners.each do |winner|
        winner_data(winner)
      end
      puts "Average movie budget is: #{Movie.average_budget}"
    end

  end
end
