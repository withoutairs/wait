require 'csv'
require 'pp'
CSV::Converters[:mint] = lambda { |s|
  begin
    DateTime.strptime(s, '%m/%d/%Y')
  rescue ArgumentError
    s
  end
}
csv = CSV.read('mint-transactions.csv', :headers => true, :converters => [:all, :mint])
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
    'Travel' => 'Vacation',
    'Vacation' => 'Vacation',
    'Gym' => 'Gym',
    'Business Expense' => 'Business Expense',
    'Utilities' => 'Utilities',
    'Gas & Fuel' => 'Car',
    'Car' => 'Car',
    'Parking' => 'Car',
    'Property Tax' => 'Property Tax',
    'Financial' => 'Financial',
    'Mobile Phone' => 'Utilities',
    'Charity' => 'Charity',
    'Internet' => 'Utilities',
    'Personal Care' => 'Personal Care',
    'Cash' => 'Cash',
    'Cash & ATM' => 'Cash',
    'Auto Service' => 'Auto Service',
    'Pharmacy' => 'Health Care',
    'Doctor' => 'Health Care',
    'Eyecare' => 'Health Care',
    'Health Care' => 'Health Care',
    'Babysitter & Daycare' => 'Nanny',
    'Clothing' => 'Clothing',
    'Music' => 'Entertainment',
    'Rental Car & Taxi' => 'Getting Around',
    'Movies & DVDs' => 'Entertainment',
    'Pets' => 'Pets',
    'Newspapers & Magazines' => 'Entertainment',
    'Spa & Massage' => 'Personal Care',
    'Gift' => 'Gifts',
    'Gifts & Donations' => 'Gifts',
    'Transfer for Cash Spending' => 'Cash',
    'ATM Fee' => 'Cash',
    'Public Transportation' => 'Getting Around',
    'Laundry' => 'Home Services',
    'Electronics & Software' => 'Entertainment',
    'Home Services' => 'Home Services',
    'Books' => 'Entertainment',
    'Sporting Goods' => 'Shopping',
    'Service & Parts' => 'Car',
    'Auto & Transport' => 'Car',
    'Bills & Utilities' => 'Utilities',
    'Federal Tax' => 'Tax',
    'Dentist' => 'Health Care',
    'Interest Income' => 'Income',
    'Home Insurance' => 'Financial',
    'Pet Food & Supplies' => 'Pets',
    'Hobbies' => 'Shopping',
    'Furnishings' => 'Furnishings',
    'Hotel' => 'Vacation',
    'Tuition' => 'Education',
    '2238 N Leavitt' => '2238',
    'Shipping' => 'Shopping',
    'Office Supplies' => 'Shopping',
    'Health & Fitness' => 'Health Care',
    'Entertainment' => 'Entertainment',
    'Water Bill' => 'Utilities',
    'Toys' => 'Gifts',
    'Kids' => 'Gifts',
    'Fees & Charges' => 'Cash',
    'Kids Birthday' => 'Kids Activities',
    'Business Services' => 'Home Services',
    'Hair' => 'Personal Care',
    'Veterinary' => 'Pets',
    'State Tax' => 'Tax',
    'Printing' => 'Entertainment',
    'Amusement' => 'Kids Activities',
    'Home' => 'Home',


}
outcsv = CSV.open("munged.csv", "wb")
first = true
csv.each { |row|

  date = row['Date']
  row << ['Month', date.strftime('%m')]
  row << ['Year', date.strftime('%Y')]
  row << ['Sortable', date.strftime('%Y-%m')]

  next if (row['Category'] == 'Paycheck')
  next if (row['Category'] == 'Credit Card Payment')
  next if (row['Category'] == 'Income')
  next if (row['Category'] == 'Transfer')

  next unless (row['Sortable'] == '2015-02' or row['Sortable'] == '2015-01' or row['Sortable'] == '2014-12' or row['Sortable'] == '2014-11' or row['Sortable'] == '2014-10' or row['Sortable'] == '2014-09')

  category = categories_map[row['Category']] || row['Category']

  row['Category'] = category
  amount = row['Amount']
  tally = categories_seen[category] ? categories_seen[category] : {:count => 0, :amount => 0}
  tally[:count] += 1
  tally[:amount] += amount
  categories_seen[category] = tally
  puts "#{category} was not expected: $#{amount} #{row['Description']} on #{date}" unless ((categories_map.include?(category)) || (categories_map.values.include?(category)))

  if first then
    outcsv << csv.headers
    first = false
  end

  outcsv << row
}
pp categories_seen.sort_by { |_, tally| -tally[:count] }


