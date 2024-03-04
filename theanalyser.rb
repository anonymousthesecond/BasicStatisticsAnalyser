# Function to calculate comprehensive statistics for a dataset
def calculate_statistics(data, handle_missing_values: :ignore)
  # Check if data is an array
  unless data.is_a?(Array)
    raise ArgumentError, "Input data must be an array"
  end

  # Handle missing values based on argument
  case handle_missing_values
  when :ignore
    cleaned_data = data.reject { |x| x.nil? }  # Remove nil values
  when :mean
    # Impute missing values with mean (adjust logic for other methods)
    mean_value = data.reject { |x| x.nil? }.sum / (data.length - data.count(nil)).to_f
    cleaned_data = data.map { |x| x.nil? ? mean_value : x }
  else
    raise ArgumentError, "Invalid handle_missing_values option"
  end

  # Check if data contains numeric values (for calculations)
  unless cleaned_data.all? { |x| x.is_a?(Numeric) }
    raise ArgumentError, "Data must contain numeric values for calculations"
  end

  # Calculate basic statistics
  sum = cleaned_data.sum
  average = sum / cleaned_data.length.to_f
  min = cleaned_data.min
  max = cleaned_data.max
  range = max - min

  # Calculate additional statistics (assuming numeric data)
  variance = cleaned_data.sum { |x| (x - average)**2 } / cleaned_data.length.to_f
  standard_deviation = Math.sqrt(variance)

  # Calculate quartiles (assuming data is sortable)
  sorted_data = cleaned_data.sort
  q1 = sorted_data[(cleaned_data.length / 4).floor]
  q2 = sorted_data[(cleaned_data.length / 2).floor]
  q3 = sorted_data[(cleaned_data.length * 3 / 4).floor]

  # Calculate percentiles (assuming data is sortable)
  percentiles = {}
  (1..99).each do |percentile|
    index = (cleaned_data.length * percentile / 100.0).floor
    percentiles[percentile] = sorted_data[index]
  end

  # Handle potential edge cases for percentiles (e.g., 100th percentile)
  percentiles[100] = max

  # Outlier Detection (basic IQR method)
  iqr = q3 - q1
  lower_bound = q1 - (1.5 * iqr)
  upper_bound = q3 + (1.5 * iqr)
  outliers = cleaned_data.select { |x| x < lower_bound || x > upper_bound }

  # Return a hash with results
  return {
    sum: sum,
    average: average,
    min: min,
    max: max,
    range: range,
    variance: variance,
    standard_deviation: standard_deviation,
    quartiles: {
      q1: q1,
      q2: q2,
      q3: q3
    },
    percentiles: percentiles,
    outliers: outliers
  }
end

# Example usage with numeric data (handling missing values)
data = [10, nil, 18, 2, 12, nil]
stats = calculate_statistics(data, handle_missing_values: :mean)
puts stats

# Example usage with non-numeric data (raises error)
data = ["apple", "banana", "orange"]
begin
  stats = calculate_statistics(data)
rescue ArgumentError => e
  puts e.message
end
