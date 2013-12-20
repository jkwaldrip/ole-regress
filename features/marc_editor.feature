Feature:  Marc Editor

  Background:
    Given I am using the Marc Editor


  Scenario:  Create a Bib Record with Title Only
    When I add a random title
    Then I can save the record

  Scenario:  Create a Bib Record with Title and Author
    When I add a random title
    And I add a random author
    Then I can save the record
