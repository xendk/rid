Feature: Allows for specifying additional env vars

  Scenario: Single env variable
    Given I have a "dev" config file:
      """
      commands:
        alpine:
          image: alpine
          entrypoint: bash
          env: MY_VAR
      """
    And I have set the following environment variables:
      | var    |
      | MY_VAR |
    When I type "rid alpine banana" in "dev"
    Then it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --volume <user home>/dev:<user home>/dev |
      | --user <user uid>:<user gid>             |
      | --workdir <user home>/dev                |
      | --env MY_VAR                             |
      | --entrypoint bash                        |
      | alpine                                   |
      | banana                                   |

  Scenario: Multiple env variables
    Given I have a "dev" config file:
      """
      commands:
        alpine:
          image: alpine
          entrypoint: bash
          env:
            - MY_VAR
            - MY_VAR2
      """
    And I have set the following environment variables:
      | var     |
      | MY_VAR  |
      | MY_VAR2 |
    When I type "rid alpine banana" in "dev"
    Then it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --volume <user home>/dev:<user home>/dev |
      | --user <user uid>:<user gid>             |
      | --workdir <user home>/dev                |
      | --env MY_VAR                             |
      | --env MY_VAR2                            |
      | --entrypoint bash                        |
      | alpine                                   |
      | banana                                   |
