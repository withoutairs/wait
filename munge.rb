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
categories_map = {
'Home Improvement' => 'Home Improvement',
'1508 Mortgage' => '1508 Mortgage',
'Mortgage & Rent' => '2238 Mortgage',
'Shopping' => 'Shopping',
'Clothes' => 'Clothes',
'Groceries' => 'Groceries',
'Restaurants' => 'Restaurants',
'Coffee Shops' => 'Restaurants',
'Katey Lunches' => 'Restaurants',
'Chris Lunches' => 'Restaurants',
'Food & Dining' => 'Restaurants',
'Alcohol & Bars' => 'Restaurants',
'Fast Food' => 'Restaurants',
'Kids Activities' => 'Kids Activities',
'Auto Payment' => 'Auto Payment',
'Education' => 'Education',
'Air Travel' => 'Vacation',
'Travel'  => 'Vacation',
'Vacation' => 'Vacation',
'Gym' => 'Gym',
'Business Expense' => 'Business Expense',
'Utilities' => 'Utilities',
'Gas & Fuel' => 'Car',
'Car' => 'Car',
'Parking' => 'Car',
'Property Tax' => 'Property Tax',
'Financial' => 'Financial',
'Mobile Phone' => 'Mobile Phone',
'Charity' => 'Charity',
'Internet' => 'Internet',
'Personal Care' => 'Personal Care',
'Cash' => 'Cash',
'Auto Service' => 'Auto Service',
'Pharmacy' => 'Health Care',
'Doctor' => 'Health Care',
'Eyecare' => 'Health Care',
'Health Care' => 'Health Care',
'Babysitter & Daycare' => 'Nanny',
'Clothing' => 'Clothing',
'Music' => 'Home Entertainment',
'Rental Car & Taxi' => 'Rental Car & Taxi',
'Movies & DVDs' => 'Movies & DVDs',
'Pets' => 'Pets',
'Newspapers & Magazines' => 'Newspapers & Magazines',
'Spa & Massage' => 'Spa & Massage',
'Gift' => 'Gift',
'Transfer for Cash Spending' => 'Cash',
'Public Transportation' => 'Public Transportation',
'Bills & Utilities' => 'Bills & Utilities',
'Laundry' => 'Dry Cleaning',
'Electronics & Software' => 'Electronics & Software',
'Home Services' => 'Home Services',
'Books' => 'Books',
'Sporting Goods' => 'Shopping',
'Service & Parts' => 'Car',
'Auto & Transport' => 'Car'
}
csv.each { |row|
  date = row['Date']
  row << ['Month', date.strftime('%m')]
  row << ['Year', date.strftime('%Y')]
  row << ['Sortable', date.strftime('%Y-%m')]

  next unless date.strftime('%Y') == '2015'
  next if (row['Category'] == 'Paycheck')
  next if (row['Category'] == 'Credit Card Payment')
  next if (row['Category'] == 'Income')
  next if (row['Category'] == 'Transfer')

  category = categories_map[row['Category']] || row['Category']

  row['Category'] = category
  amount = row['Amount']
  tally = categories_seen[category] ? categories_seen[category] : {:count => 0, :amount => 0}
  tally[:count] += 1
  tally[:amount] += amount
  categories_seen[category] = tally
  puts "#{category} was not expected: $#{amount} #{row['Description']} on #{date}" unless ((categories_map.include?(category)) || (categories_map.values.include?(category)))
}
pp categories_seen.sort_by {|_, tally| -tally[:count]}


