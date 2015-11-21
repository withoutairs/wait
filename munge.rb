require 'csv'
CSV::Converters[:mint] = lambda { |s|
  begin
    DateTime.strptime(s, '%m/%d/%Y')
  rescue ArgumentError
    s
  end
}
csv = CSV.read('mint-transactions.csv', :headers => true, :converters => [:all, :mint])
categories_seen = {}
sortables = {}
categories_map = {
    'Home Improvement' => 'Home Improvement',
    '1508 Mortgage' => 'Mortgage: 1508',
    'Mortgage & Rent' => 'Mortgage: 2238',
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
    'Auto Insurance' => 'Car',
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
    '2238 N Leavitt' => '0 Income: 2238',
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
    'Paycheck' => 'Paycheck',


}
first = true
details_csv = File.open('details.csv','wb')
csv.each { |row|

  next if (row['Category'] == 'Credit Card Payment')
  next if (row['Category'] == 'Transfer')

  date = row['Date']
  sortable = date.strftime('%Y-%m')
  row << ['Month', date.strftime('%m')]
  row << ['Year', date.strftime('%Y')]

  next unless (row['Year'] == '2015' or sortable == '2014-12' or sortable == '2014-11' or sortable == '2014-10' or sortable == '2014-09')

  sortables[sortable] = ""
  row << ['Sortable', sortable]
  category = categories_map[row['Category']] || row['Category']
  description = row['Description']
  amount = row['Amount']
  if (category == 'Paycheck') then
    if (description == 'Aurora Investmen Payrolldirect') then
      category = '0 Chris Paycheck'
    elsif (description == 'Direct Deposit Rally') then
      category = '0 Chris Paycheck'
    elsif (description == 'Direct Deposit Aon') then
      category = '0 Katey Paycheck'
    elsif (description == 'Aon Direct Paydirect') then
      category = '0 Katey Paycheck'
    elsif (description == 'Aon Service Corp') then
      category = '0 Katey Paycheck'
    elsif (description == 'Hewitt Associate Dir') then
      category = '0 Katey Paycheck'

    # one-offs
    elsif (description == 'Direct Deposit Vgi') then
      next
    elsif (description == 'Direct Deposit Jpmorgan') then
      next
    elsif (description == 'Nordstrom Transdirect Deposit') then
     amount = amount * -1
     category = 'Clothing'
    else
      category = description
      puts "Strange 'Paycheck': " + description + " for " + amount.to_s + " on " + date.to_s
    end
    categories_map[category] = category
  end

  row['Category'] = category
  unless (categories_seen[category]) then 
    categories_seen[category] = {}
  end
  if (categories_seen[category] and categories_seen[category].has_key?(sortable)) then
    tally = categories_seen[category][sortable]
  else
    tally = {:count => 0, :amount => 0}
  end
  tally[:count] += 1
  tally[:amount] += amount
  categories_seen[category][sortable] = tally
  puts "#{category} was not expected: $#{amount} #{row['Description']} on #{date}" unless ((categories_map.include?(category)) || (categories_map.values.include?(category)))

  if first then
    first = false
    details_csv << csv.headers.join(',')
    details_csv << "\n"
  end

  details_csv << row
}

# the header's first column is blank, this is where the categories go
summary_csv = File.open('summary.csv','wb')
summary_csv << ""
sortables.keys.each { |sortable| summary_csv << ',' + sortable }
summary_csv << "\n"

# each cell in the summary is the sortables for the category
categories_seen.keys.sort.each { |category|
  summary_csv << category
  sortables.keys.each { |sortable| 
    amount = categories_seen[category][sortable] ? categories_seen[category][sortable][:amount].round(2).to_s : "0"
    summary_csv << "," + amount
  }
  summary_csv << "\n"
}


