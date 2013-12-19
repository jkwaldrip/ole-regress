Feature:  Marc Editor

  Scenario:  Create a Bib Record with Title Only
    Given I am using the Marc Editor
    When I add a random title
    Then I can save the record

  Scenario:  Create a Bib Record with Title and Author
    Given I am using the Marc Editor
    When I add a random title
    And I add a random author
    Then I can save the record
