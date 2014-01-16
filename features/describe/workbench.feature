Feature:  Describe Workbench

  Background:
    Given I have a resource
    Given I use the Marc Editor
    Given I create a bib record
    Given I create an instance record
    Given I create an item record
    Given I am using the Describe Workbench

  Scenario:  Find a Bib by Title
    When I search for a bib record
    And I enter the title in the first search field
    And I set the first search selector to Title
    And I click the search button on the workbench page
    Then I see the title in the workbench search results

  Scenario:  Find a Bib by Author
    When I search for a bib record
    And I enter the author in the first search field
    And I set the first search selector to Author
    And I click search on the workbench page
    Then I see the author in the workbench search results

  Scenario:  Find a Holdings by Call Number
    When I search for a holdings record
    And I enter the call number in the first search field
    And I set the first search selector to Call Number
    And I click search on the workbench page
    Then I see the call number in the workbench search results

  Scenario:  Find an Item by Barcode
    When I search for an item record
    And I enter the barcode in the first search field
    And I set the first search selector to Item Barcode
    And I click search on the workbench page
    Then I see the barcode in the workbench search results
