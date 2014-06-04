@recall @request @happy_path @regress

Feature:  Request Recall

  Background:
    Given I loan an item to a patron
    Given I create a second new patron record
    
  Scenario:  Make a Recall/Hold Request
    When I open the Request lookup page
    And I click the "Create New Request" link
    When I select a request type of "Recall/Hold Request"
    And I select an operator type of "Operator"
    Then I wait for the operator ID to appear in the operator ID field
    When I select the second patron by barcode on the request page
    Then I wait for the second patron's name to appear in the patron name field
    When I click the item search icon on the request page
    Then the item lookup screen will appear
    When I enter the item's barcode on the item lookup screen
    And I click the search button on the item lookup screen
    And I click the return link for the item's barcode
    Then I wait for the item's title to appear in the title field
    When I enter a pickup location of "BL_EDUC"
    And I click the submit button on the request page
    Then I see a success message on the request page
