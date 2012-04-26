#Given /^the following line_items:$/ do |line_items|
#  LineItem.create!(line_items.hashes)
#end
#
#When /^I delete the (\d+)(?:st|nd|rd|th) line_item$/ do |pos|
#  visit line_items_path
#  within("table tr:nth-child(#{pos.to_i+1})") do
#    click_link "Destroy"
#  end
#end
#
#Then /^I should see the following line_items:$/ do |expected_line_items_table|
#  expected_line_items_table.diff!(tableish('table tr', 'td,th'))
#end
Given /^I have one line item$/ do
  @line_item = LineItem.create(:comment => 'XBox', :amount => 100, :event_date => Time.now, :category_name => 'Software', :payee_name => 'Microsoft')
  LineItem.reset_balance
end

When /^I visit the main page$/ do
  visit line_items_path
end
Then /^I should see the table$/ do
  assert page.has_css? 'tr#line_item_' + @line_item.id.to_s + ' td:nth-child(3)', :text => "100"
end

When /^I file expense for (\d+) paid to (\w+) for (\w+) on ([0-9\/]+)$/ do |amount, payee, category, date|
  choose 'line_item_type_1'
  fill_in 'line_item_event_date', :with => date
  fill_in 'line_item_amount', :with => amount
  fill_in 'line_item_payee_name', :with => payee
  fill_in 'line_item_category_name', :with => category
  click_on 'Create Line item'
end
Then /^(\d+)\w+ line item will show Expense,(.+),(.+),(.+),(.+),(.+)$/ do |line_number, col1, col2, col3, col4, col5|

  line_item = LineItem.first

  column_values = [col1, col2, col3, col4, col5]
  column_index = 0

  puts page.all(:css, 'html body div#line_items_list').inspect

  assert page.has_css? 'tr#line_item_' + line_item.id.to_s

  page.all(:css, 'tr#line_item_' + line_item.id.to_s + ' td') do |column|
    assert column.has_content?(column_values[column_index])
    column_index += 1
  end
end