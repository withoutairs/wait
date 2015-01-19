require 'csv'
require 'pp'
CSV::Converters[:mint] = lambda { |s|
  begin
    DateTime.strptime(s, '%m/%d/%Y')
  rescue ArgumentError
    s
  end
}
csv = CSV.read('small.csv', :headers => true, :converters => [:all, :mint])
categories_seen = {}
csv.each { |row|
  date = row["Date"]
  row << ["Month", date.strftime("%m")]
  row << ["Year", date.strftime("%Y")]
  row << ["Sortable", date.strftime("%Y-%m")]
  category = row["Category"]
  amount = row["Amount"]
  tally = categories_seen[category] ? categories_seen[category] : {:count => 0, :amount => 0}
  tally[:count] += 1
  tally[:amount] += amount
  categories_seen[category] = tally

  row["Category"] = "XXX" if (category == "Parking")
}
pp categories_seen.sort_by {|category, tally| -tally[:count]}


