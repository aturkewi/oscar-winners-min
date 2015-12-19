class Movie

  @@total_budget ||= 0
  @@total_num_of_movies ||= 0

  def self.add_to_budget(new_budget)
    @@total_budget = @@total_budget + new_budget.to_i
  end

  def self.total_budget
    @@total_budget
  end

  def self.total_num_of_movies
    @@total_num_of_movies
  end

  def self.increase_movie_count
    @@total_num_of_movies += 1
  end

  def self.average_budget
    @@total_budget / @@total_num_of_movies
  end

end
