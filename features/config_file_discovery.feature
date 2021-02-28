Feature: The program should find the appropiate config files.

  Scenario: Error out if no config file
    When I type "rid test"
    Then it should exit with a "rid: no config file found" error

  Scenario: Error out if config is invalid
    Given I have a 'dev' config file:
      """
      --
      banana: true
      """
    When I type "rid test" in "dev"
    Then it should exit with a "rid: error loading config file: (/tmp/rid/home/dev/.rid.yml): mapping values are not allowed in this context at line 2 column 7" error

  Scenario: Error out if config is file empty
    Given I have a "dev" config file:
      """
      """
    When I type "rid test" in "dev"
    Then it should exit with a "rid: unknown program test" error

  Scenario: Should run command in nearest config file
    Given I have a "dev" config file:
      """
      """
    Given I have a "dev/test" config file:
      """
      commands:
        test:
          image: test
          raw: true
      """
    When I type "rid test" in "dev/test"
    Then it runs "docker run" with:
      | arg  |
      | --rm |
      | -i   |
      | test |

  Scenario: Should run command in parent config file
    Given I have a "dev" config file:
      """
      commands:
        test:
          image: test
          raw: true
      """
    Given I have a "dev/test" config file:
      """
      """
    When I type "rid test" in "dev/test"
    Then it runs "docker run" with:
      | arg  |
      | --rm |
      | -i   |
      | test |

  Scenario: Commands should shadow their parent per default
    Given I have a "dev" config file:
      """
      commands:
        test:
          image: test
          args: testargs
      """
    Given I have a "dev/test" config file:
      """
      commands:
        test:
          image: not-a-test
          raw: true
      """
    When I type "rid test" in "dev/test"
    Then it runs "docker run" with:
      | arg        |
      | --rm       |
      | -i         |
      | not-a-test |

  Scenario: Commands should inherit form their parent if specified
    Given I have a "dev" config file:
      """
      commands:
        test:
          image: test
          args: testargs
      """
    Given I have a "dev/test" config file:
      """
      commands:
        test:
          inherit: true
          image: not-a-test
          raw: true
      """
    When I type "rid test" in "dev/test"
    Then it runs "docker run" with:
      | arg        |
      | --rm       |
      | -i         |
      | not-a-test |
      | testargs   |
