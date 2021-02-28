Feature: Program should handle arguments.

  Scenario: Error out if no command specified
    Given I have a "dev" config file:
      """
      """
    When I type "rid" in "dev"
    Then it should exit with a "rid: no command given" error
