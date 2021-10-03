Feature: Commands can inherit from other commands.

  Scenario: Allow for inheriting from another command in the same file
    Given I have a "dev" config file:
      """
      commands:
        base:
          image: node:14
          entrypoint: node
          args: test
          raw: true
        extending:
          inherit: base
          entrypoint: someother
      """
    When I type "rid extending -" in "dev"
    Then it runs "docker run" with:
      | arg                    |
      | --rm                   |
      | --interactive          |
      | node:14                |
      | --entrypoint someother |
      | test -                 |

  Scenario: Commands can inherit from their namesake in a parent file
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
      | arg           |
      | --rm          |
      | --interactive |
      | not-a-test    |
      | testargs      |

  Scenario: Inheriting should override parent
    Given I have a "dev" config file:
      """
      commands:
        test:
          image: test
          args: testargs
        test2:
          image: test2
      """
    Given I have a "dev/test" config file:
      """
      commands:
        test:
          inherit: test2
          raw: true
      """
    When I type "rid test" in "dev/test"
    Then it runs "docker run" with:
      | arg           |
      | --rm          |
      | --interactive |
      | test2         |
