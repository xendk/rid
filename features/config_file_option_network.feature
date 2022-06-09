Feature: Allows for specifying network

  Scenario: Single env variable
    Given I have a "dev" config file:
      """
      commands:
        alpine:
          image: alpine
          entrypoint: bash
          network: some_default
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
      | --entrypoint bash                        |
      | --network some_default                   |
      | alpine                                   |
      | banana                                   |
