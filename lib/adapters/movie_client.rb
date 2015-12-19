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

    def update_totals(budget)
      Movie.increase_movie_count
      Movie.add_to_budget(budget)
    end

    def winner_data(winner)
      results=get_json(winner['Detail URL'])
      year = winner.year
      title = format_title(winner.Film)
      # budget = format_budget(results.Budget)
      budget = BudgetServiceObject.new(results.Budget).format
      update_totals(budget) unless budget == "NO BUDGET"
      puts "#{year} - #{title} - $#{budget}"
    end

    def seed
      get_winners.each do |winner|
        winner_data(winner)
      end
      puts "Average movie budget is: #{Movie.average_budget}"
    end

  end
end
