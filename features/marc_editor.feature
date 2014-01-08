Feature:  Marc Editor

  Background:
    Given I am using the Marc Editor

  Scenario:  Create a Bib Record
    When I enter a title
    Then I can save the bib record

  Scenario:  Create an Instance Record
    When I create a bib record
    And I add an instance record
    And I enter a location of B-EDUC/BED-STACKS
    And I enter a call number
    And I select a call number type
    Then I can save the instance record

  Scenario:  Create an Item Record
    When I create a bib record
    And I create an instance record
    Then I add an item record
    And I select the item type "Book"
    And I select the item status "Available"
    And I enter a barcode
    Then I can save the item record
