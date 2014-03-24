@editor @describe @happy_path
Feature:  Marc Editor

  Background:
    Given I have a resource
    Given I am using the Marc Editor

  Scenario:  Create a Bib Record
    When I enter a title of Title
    And I enter an author of John Q. Author
    Then I can save the bib record

  Scenario:  Create a Bib, Instance, and Item Record
    When I create a bib record
    And I create an instance record
    Then I add an item record
    And I select an item type of Book
    And I select an item status of Available
    And I enter a barcode
    Then I can save the item record
    And I return to the bib editor window
