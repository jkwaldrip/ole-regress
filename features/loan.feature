@deliver @Loan @happy_path

Feature: Loan Item

  Background:
    Given I create a new patron record
    And I create an item record
    And I log in as dev2

  Scenario: Make a Hold/Hold Request
    When I open the Loan page
    And I select a Circulation Desk of "BL_EDUC"
    Then I wait for the Confirmation dialogue to appear
    When I click the "Yes" button
    Then the loan screen will appear
    When I enter the patron barcode
    Then the item field appears
    And I enter the item barcode
    Then I see a success message