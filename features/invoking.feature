Feature: Program should handle arguments.

  Scenario: Error out if no command specified
    Given I have a "dev" config file:
      """
      """
    When I type "rid" in "dev"
    Then it should exit with a "rid: no command given" error

  Scenario: Should error out on unknown options
    Given I have a "dev" config file:
      """
      commands:
        platform:
          image: platform
          entrypoint: /usr/local/bin/platform
          args: some arg
      """
    When I type "rid --banana platform" in "dev"
    Then it should exit with a "rid: unknown option --banana" error


  Scenario: --shell should launch a shell instead of entrypoint
    Given I have a "dev" config file:
      """
      commands:
        platform:
          image: platform
          entrypoint: /usr/local/bin/platform
          args: some arg
      """
    When I type "rid --shell platform" in "dev"
    # The final line is missing the needed quotes around the if statement, because the shell script we use as can't see them.
    Then it runs "docker run" with:
      | arg                                                                                                                 |
      | --rm                                                                                                                |
      | -i                                                                                                                  |
      | --init                                                                                                              |
      | -v <user home>/dev:<user home>/dev                                                                                  |
      | -u <user uid>:<user gid>                                                                                            |
      | -w <user home>/dev                                                                                                  |
      | --entrypoint sh                                                                                                     |
      | platform                                                                                                            |
      | -c                                                                                                                  |
      | if [ -e /usr/bin/fish ]; then exec /usr/bin/fish; elif [ -e /bin/bash ]; then exec /bin/bash; else exec /bin/sh; fi |

  Scenario: Should propagate some env variables
    Given I have a "dev" config file:
      """
      commands:
        php:
          image: php:7.4
          entrypoint: php
      """
    And I have a "php" symlink
    When I type "php somescript.php" in "dev"
    Then it runs "docker run" with:
      | arg                                |
      | --rm                               |
      | -i                                 |
      | --init                             |
      | -e HOME                            |
      | -e USER                            |
      | -e USERNAME                        |
      | -e LOGNAME                         |
      | -u <user uid>:<user gid>           |
      | -v <user home>/dev:<user home>/dev |
      | -w <user home>/dev                 |
      | --entrypoint php                   |
      | php:7.4                            |
      | somescript.php                     |
