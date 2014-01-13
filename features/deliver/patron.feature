Feature:  Patron

  Background:
    Given I create a patron record

  Scenario:  Search for a Patron by Name
    Given I am using Patron Search
    When I enter the patron first name
    And I enter the patron last name
    And I search for a patron
    Then I see the patron first name in the results
    And I see the patron last name in the results

  Scenario:  Search for a Patron by Email
    Given I am using Patron Search
    When I enter the patron email address
    And I search for a patron
    Then I see the patron email address in the results

  Scenario:  Search for a Patron by Barcode
    Given I am using Patron Search
    When I enter the patron barcode
    And I search for a patron
    Then I see the patron barcode in the results

  Scenario: Edit a Patron
    Given I am using Patron Search
    When I enter the patron first name
    And I enter the patron last name
    And I enter the patron barcode
    Then I see the patron barcode in the results
    And I edit the patron record
    And I set a new barcode
    And I save the patron record
    When I use a Patron Search
    And I enter the patron first name
    And I enter the patron last name
    And I enter the patron barcode
    Then I see the patron barcode in the results
