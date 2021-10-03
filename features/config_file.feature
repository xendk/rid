Feature: The program should apply the configuration in the config file.

  Scenario: Should error out if command doensn't specify an image
    Given I have a "dev" config file:
      """
      commands:
        hadolint:
          args: hadolint
      """
    When I type "rid hadolint -" in "dev"
    Then it should exit with a "rid: no image given for hadolint" error

  Scenario: Should add init, user id, root mountpoint and cwd per default.
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

  Scenario: Should not add init, user id, root mountpoint and cwd for "raw" commands.
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

  Scenario: Uses image and args configuration
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

  Scenario: Supports single mount
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

  Scenario: Supports multiple mounts
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

  Scenario: Uses entry point configuration
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

  Scenario: Supports single cache configuration
    Given I have a "dev" config file:
      """
      commands:
        composer:
          image: reload/drupal-php7-fpm:7.3
          entrypoint: composer
          cache: "/home/$USER/.cache"
      """
    When I type "rid composer install" in "dev"
    Then it runs "docker run" with:
      | arg                                                                             |
      | --rm                                                                            |
      | --interactive                                                                   |
      | --init                                                                          |
      | --volume <user home>/dev:<user home>/dev                                        |
      | --user <user uid>:<user gid>                                                    |
      | --workdir <user home>/dev                                                       |
      | --volume <rid cache>/composer/!home!<user name>!.cache:/home/<user name>/.cache |
      | --entrypoint composer                                                           |
      | reload/drupal-php7-fpm:7.3                                                      |
      | install                                                                         |

  Scenario: Supports multiple cache entries configuration
    Given I have a "dev" config file:
      """
      commands:
        composer:
          image: reload/drupal-php7-fpm:7.3
          entrypoint: composer
          cache:
            - "/home/$USER/.cache"
            - "/home/$USER/.local"
      """
    When I type "rid composer install" in "dev"
    Then it runs "docker run" with:
      | arg                                                                             |
      | --rm                                                                            |
      | --interactive                                                                   |
      | --init                                                                          |
      | --volume <user home>/dev:<user home>/dev                                        |
      | --user <user uid>:<user gid>                                                    |
      | --workdir <user home>/dev                                                       |
      | --volume <rid cache>/composer/!home!<user name>!.cache:/home/<user name>/.cache |
      | --volume <rid cache>/composer/!home!<user name>!.local:/home/<user name>/.local |
      | --entrypoint composer                                                           |
      | reload/drupal-php7-fpm:7.3                                                      |
      | install                                                                         |

  Scenario: Should allow for inheriting from another command
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

  Scenario: Should not remove container when keep specified.
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

  Scenario: Should mount in configured args
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
