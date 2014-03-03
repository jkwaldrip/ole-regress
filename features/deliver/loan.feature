@deliver @loan @happy_path

Feature: Loan Item

  Background:
    Given I create a new patron record
    Given I have a resource
    And I use the Marc Editor
    Then I create a bib record
    And I create an instance record
    And I create an item record
    Then I log in as dev2

  Scenario: Loan an Item to a Patron
    When I open the loan page
    And I select a Circulation Desk of "BL_EDUC"
    Then I wait for the confirmation dialogue to appear
    When I click the "yes" button
    Then the loan screen will appear
    When I select a patron by barcode
    Then the item field appears
    And I select the item by barcode
    Then I see the item barcode in current items