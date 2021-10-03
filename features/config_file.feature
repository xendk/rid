Feature: Commands can be configured.

  Scenario: Error out if command doensn't specify an image
    Given I have a "dev" config file:
      """
      commands:
        hadolint:
          args: hadolint
      """
    When I type "rid hadolint -" in "dev"
    Then it should exit with a "rid: no image given for hadolint" error

  Scenario: Use image and args configuration
    Given I have a "dev" config file:
      """
      commands:
        hadolint:
          image: hadolint/hadolint
          args: hadolint
          raw: true
      """
    When I type "rid hadolint -" in "dev"
    Then it runs "docker run" with:
      | arg               |
      | --rm              |
      | --interactive     |
      | hadolint/hadolint |
      | hadolint -        |

  Scenario: Use entry point configuration
    Given I have a "dev" config file:
      """
      commands:
        php:
          image: php:7.4
          entrypoint: php
      """
    When I type "rid php script.php" in "dev"
    Then it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --volume <user home>/dev:<user home>/dev |
      | --user <user uid>:<user gid>             |
      | --workdir <user home>/dev                |
      | --entrypoint php                         |
      | php:7.4                                  |
      | script.php                               |

  Scenario: Can extract a port number from args
    Given I have a "dev" config file:
      """
      commands:
        serenata:
          image: php:7.4
          entrypoint: php
          args: /serenata.phar
          port_from_args: /-u (\d+)/
      """
    When I type "rid serenata -u 1234" in "dev"
    Then it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --volume <user home>/dev:<user home>/dev |
      | --user <user uid>:<user gid>             |
      | --workdir <user home>/dev                |
      | --entrypoint php                         |
      | php:7.4                                  |
      | --publish 1234:1234                      |
      | /serenata.phar -u 1234                   |

  Scenario: Don't remove container when keep specified.
    Given I have a "dev" config file:
      """
      commands:
        hadolint:
          image: hadolint/hadolint
          args: hadolint
          raw: true
          keep: true
      """
    When I type "rid hadolint -" in "dev"
    Then it runs "docker run" with:
      | arg               |
      | --interactive     |
      | hadolint/hadolint |
      | hadolint -        |
