class BudgetServiceObject

  attr_accessor :unformatted_budget

  def initialize(budget)
    @unformatted_budget = budget
  end

  def convert_from_pounds(budget_in_words)
    if budget_in_words[0] == "£"
      budget = budget_in_words.delete("£").delete(",").split(" ")
      budget_in_words = "$#{(budget[0].to_i * 1.49).round} #{budget[1]}"
    end
    budget_in_words
  end

  # If a budget has a range, takes the maximum value
  def avg_range(budget_in_words)
    budget_in_words = budget_in_words.gsub("-","–")
    if budget_in_words.include?("–")
      budget_array = budget_in_words.split("–")
      budget_in_words = budget_array[0][0] + budget_array[1]
    end
    budget_in_words
  end

  # If budget has word 'million', it multiplies the number by that
  def multiply_by_suffix(budget_in_words)
    if budget_in_words.include?("million")
      budget_in_words.delete("US").sub(" ","")
      budget_arrays = budget_in_words.split("m")
      budget = budget_arrays[0][1..-1].to_i * 1000000
    else
      budget = budget_in_words.delete(",").delete("$").to_i
    end
  end

  # Method in charge of calling other methods to convert to integer
  def convert_to_int(budget_in_words)
    budget_in_words = avg_range(budget_in_words)
    budget_in_words = convert_from_pounds(budget_in_words)
    budget = multiply_by_suffix(budget_in_words)
  end

  # Gets rid of things like [...] and (...)
  def clear_off_extras(unformatted_budget)
    budget_in_words = unformatted_budget.gsub(/ *\[[^)]*\] */, "").
      gsub(/ *\([^)]*\) */, "").gsub("US","")
  end

  # Will put "NO BUDGET" if there wasn't one and returns final budget
  def format
    if unformatted_budget
      budget_in_words = clear_off_extras(unformatted_budget)
      budget = convert_to_int(budget_in_words)
    else
      "NO BUDGET"
    end
  end

end
