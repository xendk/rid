Feature: Clone the running environment so that it seems like the command is running locally.

  Scenario: Add init, user id, root mountpoint and cwd per default.
    Given I have a "dev" config file:
      """
      commands:
        hadolint:
          image: hadolint/hadolint
          args: hadolint
      """
    When I type "rid hadolint -" in "dev"
    Then it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --volume <user home>/dev:<user home>/dev |
      | --user <user uid>:<user gid>             |
      | --workdir <user home>/dev                |
      | hadolint/hadolint                        |
      | hadolint -                               |

  Scenario: "raw" does not add init, user id, root mountpoint and cwd.
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
