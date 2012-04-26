Feature: Managing Line Items

  @culerity
  Scenario: Viewing Main Page
    Given I have one line item
    When I visit the main page
    Then I should see the table

  @culerity
  Scenario: Adding line item
    Given I visit the main page
    When I file expense for 30 paid to Uzi for Automobile on 1/10
    Then 1st line item will show Expense,2011-10-1,30.00,Uzi,Automobile,-30

#  Scenario: Register new line_item
#    Given I am on the new line_item page
#    When I fill in "Type" with "type 1"
#    And I fill in "Amount" with "amount 1"
#    And I fill in "Event date" with "event_date 1"
#    And I fill in "Comment" with "comment 1"
#    And I fill in "Category name" with "category_name 1"
#    And I fill in "Payee name" with "payee_name 1"
#    And I press "Create"
#    Then I should see "type 1"
#    And I should see "amount 1"
#    And I should see "event_date 1"
#    And I should see "comment 1"
#    And I should see "category_name 1"
#    And I should see "payee_name 1"
#
#  Scenario: Delete line_item
#    Given the following line_items:
#      |type|amount|event_date|comment|category_name|payee_name|
#      |type 1|amount 1|event_date 1|comment 1|category_name 1|payee_name 1|
#      |type 2|amount 2|event_date 2|comment 2|category_name 2|payee_name 2|
#      |type 3|amount 3|event_date 3|comment 3|category_name 3|payee_name 3|
#      |type 4|amount 4|event_date 4|comment 4|category_name 4|payee_name 4|
#    When I delete the 3rd line_item
#    Then I should see the following line_items:
#      |Type|Amount|Event date|Comment|Category name|Payee name|
#      |type 1|amount 1|event_date 1|comment 1|category_name 1|payee_name 1|
#      |type 2|amount 2|event_date 2|comment 2|category_name 2|payee_name 2|
#      |type 4|amount 4|event_date 4|comment 4|category_name 4|payee_name 4|
