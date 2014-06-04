@deliver @request @happy_path @regress

Feature:  Request Page

  Background:
    Given I have a resource
    Given I use the Marc Editor
    Given I create a bib record
    Given I create an instance record
    Given I create an item record
    Given I create a new patron record
 
  Scenario:  Make a Page/Hold Request
    When I open the Request lookup page
    And I click the "Create New Request" link
    And I select an operator type of "Patron"
    And I select a request type of "Page/Hold Request"
    And I select the patron by barcode on the request page
    Then I wait for the patron's name to appear in the patron name field
    When I click the item search icon on the request page
    Then the item lookup screen will appear
    When I enter the item's barcode on the item lookup screen
    And I click the search button on the item lookup screen
    And I click the return link for the item's barcode
    Then I wait for the item's title to appear in the title field
    When I enter a pickup location of "BL_EDUC"
    And I click the submit button on the request page
    Then I see a success message on the request page

  Scenario:  Make a Page/Delivery Request
    When I open the Request lookup page
    And I click the "Create New Request" link
    And I select an operator type of "Patron"
    And I select a request type of "Page/Delivery Request"
    And I select the patron by barcode on the request page
    Then I wait for the patron's name to appear in the patron name field
    When I click the item search icon on the request page
    Then the item lookup screen will appear
    When I enter the item's barcode on the item lookup screen
    And I click the search button on the item lookup screen
    And I click the return link for the item's barcode
    Then I wait for the item's title to appear in the title field
    When I click the submit button on the request page
    Then I see a success message on the request page
