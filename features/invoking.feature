Feature: Program should handle arguments.

  Scenario: Error out if no command specified
    Given I have a "dev" config file:
      """
      """
    When I type "rid" in "dev"
    Then it should exit with a "rid: no command given" error

  Scenario: Error out on unknown options
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


  Scenario: --shell launches a shell instead of entrypoint
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
      | --interactive                                                                                                       |
      | --init                                                                                                              |
      | --volume <user home>/dev:<user home>/dev                                                                            |
      | --user <user uid>:<user gid>                                                                                        |
      | --workdir <user home>/dev                                                                                           |
      | --entrypoint sh                                                                                                     |
      | platform                                                                                                            |
      | -c                                                                                                                  |
      | if [ -e /usr/bin/fish ]; then exec /usr/bin/fish; elif [ -e /bin/bash ]; then exec /bin/bash; else exec /bin/sh; fi |

  Scenario: Propagate some env variables
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
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --env HOME                               |
      | --env USER                               |
      | --env USERNAME                           |
      | --env LOGNAME                            |
      | --user <user uid>:<user gid>             |
      | --volume <user home>/dev:<user home>/dev |
      | --workdir <user home>/dev                |
      | --entrypoint php                         |
      | php:7.4                                  |
      | somescript.php                           |

  Scenario: --dry-run prints command
    Given I have a "dev" config file:
      """
      commands:
        platform:
          image: platform
          entrypoint: /usr/local/bin/platform
          args: some arg
      """
    When I type "rid --dry-run platform" in "dev"
    # This is brittle, but really no way around it.
    Then it should output:
      """
      rid: would run: docker run --rm --interactive --init --user <user uid>:<user gid> --workdir /tmp/rid/home/dev --volume /tmp/rid/home/dev:/tmp/rid/home/dev --env HOME --env USER --env USERNAME --env LOGNAME --entrypoint /usr/local/bin/platform platform some arg
      """
