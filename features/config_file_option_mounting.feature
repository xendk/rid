Feature: Mount in custom paths needed by command.

  Scenario: Single mount
    Given I have a "dev" config file:
      """
      commands:
        dive:
          image: wagoodman/dive:latest
          mount: /var/run/docker.sock
          raw: true
      """
    And I have a "dive" symlink
    When I type "dive image" in "dev"
    Then it runs "docker run" with:
      | arg                                                |
      | --rm                                               |
      | --interactive                                      |
      | --volume /var/run/docker.sock:/var/run/docker.sock |
      | wagoodman/dive:latest                              |
      | image                                              |

  Scenario: Multiple mounts
    Given I have a "dev" config file:
      """
      commands:
        dive:
          image: wagoodman/dive:latest
          mount:
            - /var/run/docker.sock
            - /tmp/random
          raw: true
      """
    And I have a "dive" symlink
    When I type "dive image" in "dev"
    Then it runs "docker run" with:
      | arg                                                |
      | --rm                                               |
      | --interactive                                      |
      | --volume /var/run/docker.sock:/var/run/docker.sock |
      | --volume /tmp/random:/tmp/random                   |
      | wagoodman/dive:latest                              |
      | image                                              |

  Scenario: Mount in args which has been configured
    Given I have a "banana" file in "other"
    Given I have a "apple" file in "other"
    Given I have a "dev" config file:
      """
      commands:
        php:
          image: php:7.4
          mount_args: <user home>/other/ba.*
      """
    When I type "rid php script.php <user home>/other/banana <user home>/other/apple" in "dev"
    Then it runs "docker run" with:
      | arg                                                         |
      | --rm                                                        |
      | --interactive                                               |
      | --init                                                      |
      | --volume <user home>/other/banana:<user home>/other/banana  |
      | --volume <user home>/dev:<user home>/dev                    |
      | --user <user uid>:<user gid>                                |
      | --workdir <user home>/dev                                   |
      | php:7.4                                                     |
      | script.php <user home>/other/banana <user home>/other/apple |
