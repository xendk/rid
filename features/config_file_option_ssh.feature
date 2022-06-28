Feature: SSH agent forwarding

  Scenario: Forward SSH agent socket and env var
    Given I have a "dev" config file:
      """
      commands:
        alpine:
          image: alpine
          entrypoint: bash
          ssh_agent: true
      """
    And I have set the following environment variables:
      | var           | value          |
      | SSH_AUTH_SOCK | /some/ssh/path |
    When I type "rid alpine banana" in "dev"
    Then it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --volume <user home>/dev:<user home>/dev |
      | --volume /some/ssh/path:/some/ssh/path   |
      | --user <user uid>:<user gid>             |
      | --workdir <user home>/dev                |
      | --env SSH_AUTH_SOCK                      |
      | --entrypoint bash                        |
      | alpine                                   |
      | banana                                   |

  Scenario: Mount in known_hosts if it exists.
    Given I have a "dev" config file:
      """
      commands:
        alpine:
          image: alpine
          entrypoint: bash
          ssh_agent: true
      """
    And I have set the following environment variables:
      | var           | value          |
      | SSH_AUTH_SOCK | /some/ssh/path |
    And I have a "known_hosts" file in ".ssh"
    When I type "rid alpine banana" in "dev"
    Then it runs "docker run" with:
      | arg                                                                |
      | --rm                                                               |
      | --interactive                                                      |
      | --init                                                             |
      | --volume <user home>/.ssh/known_hosts:<user home>/.ssh/known_hosts |
      | --volume <user home>/dev:<user home>/dev                           |
      | --volume /some/ssh/path:/some/ssh/path                             |
      | --user <user uid>:<user gid>                                       |
      | --workdir <user home>/dev                                          |
      | --env SSH_AUTH_SOCK                                                |
      | --entrypoint bash                                                  |
      | alpine                                                             |
      | banana                                                             |
