Feature:  Patron

  Scenario:  Enter a New Patron
    Given I have new patron information
    Given I open the patron editor
    When I set the patron's first name to "Darren"
    And I set the patron's last name to "Smith"
    And I set the patron's barcode
    And I set the patron's borrower type
    And I add a patron address line
    And I set the patron's address type
    And I set the patron's address
    And I set the patron's city
    And I set the patron's state
    And I set the patron's postal code
    And I set the patron's country
    And I set the patron's email address
    And I add the patron's email line
    And I set the patron's phone number
    And I add the patron's phone number line
    Then I submit the patron record

  Scenario:  Search for a Patron by Name
    Given I create a new patron record
    Given I am using Patron Search
    When I enter the patron's first name
    And I enter the patron's last name
    And I click the search button on the patron lookup page
    Then I see the first name in the patron search results
    And I see the last name in the patron search results

  Scenario:  Search for a Patron by Email
    Given I create a new patron record
    Given I am using Patron Search
    When I enter the patron's email address
    And I click the search button on the patron lookup page
    Then I see the barcode in the patron search results

  Scenario:  Search for a Patron by Barcode
    Given I create a new patron record
    Given I am using Patron Search
    When I enter the patron's barcode
    And I click the search button on the patron lookup page
    Then I see the barcode in the patron search results

  Scenario: Edit a Patron
    Given I create a new patron record
    Given I am using Patron Search
    When I enter the patron first name
    And I enter the patron last name
    And I enter the patron barcode
    Then I see the barcode in the patron search results
    And I click the "edit" link
    And I set a new barcode
    And I save the patron record
    When I use the Patron Search
    And I enter the patron first name
    And I enter the patron last name
    And I enter the patron barcode
    Then I see the patron barcode in the patron search results
