require 'csv'
require 'pp'
CSV::Converters[:mint] = lambda { |s|
  begin
    DateTime.strptime(s, '%m/%d/%Y')
  rescue ArgumentError
    s
  end
}
csv = CSV.read('2015.csv', :headers => true, :converters => [:all, :mint])
categories_seen = {}
categories_wanted = [
'Home Improvement',
'1508 Mortgage',
'2238 Mortgage',
'Shopping',
'Clothes',
'Groceries',
'Restaurants',
'Kids Activities',
'Auto Payment',
'Education',
'Vacation',
'Gym',
'Business Expense',
'Utilities',
'Car',
'Property Tax',
'Financial',
'Mobile Phone',
'Charity',
'Internet',
'Personal Care',
'Cash',
'Auto Service',
'Pharmacy',
]
csv.each { |row|
  date = row['Date']
  row << ['Month', date.strftime('%m')]
  row << ['Year', date.strftime('%Y')]
  row << ['Sortable', date.strftime('%Y-%m')]

  next unless date.strftime('%Y') == '2015'

  category = row['Category']

  row['Category'] = 'Car' if category == 'Parking'
  row['Category'] = 'Car' if category == 'Rental Car & Taxi'

  category = row['Category']
  amount = row['Amount']
  tally = categories_seen[category] ? categories_seen[category] : {:count => 0, :amount => 0}
  tally[:count] += 1
  tally[:amount] += amount
  categories_seen[category] = tally
  puts "#{category} was not expected: $#{amount} #{row['Description']} on #{date}" unless (categories_wanted.include?(category))
}
pp categories_seen.sort_by {|_, tally| -tally[:count]}


