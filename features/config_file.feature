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
      | arg                                |
      | --rm                               |
      | -i                                 |
      | --init                             |
      | -v <user home>/dev:<user home>/dev |
      | -u <user uid>:<user gid>           |
      | -w <user home>/dev                 |
      | hadolint/hadolint                  |
      | hadolint -                         |

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
      | -i                |
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
      | -i                |
      | hadolint/hadolint |
      | hadolint -        |

  Scenario: Uses mounts configuration
    Given I have a "dev" config file:
      """
      commands:
        dive:
          image: wagoodman/dive:latest
          mounts:
            - /var/run/docker.sock
          raw: true
      """
    And I have a "dive" symlink
    When I type "dive image" in "dev"
    Then it runs "docker run" with:
      | arg                                          |
      | --rm                                         |
      | -i                                           |
      | -v /var/run/docker.sock:/var/run/docker.sock |
      | wagoodman/dive:latest                        |
      | image                                        |

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
      | arg                                |
      | --rm                               |
      | -i                                 |
      | --init                             |
      | -v <user home>/dev:<user home>/dev |
      | -u <user uid>:<user gid>           |
      | -w <user home>/dev                 |
      | --entrypoint php                   |
      | php:7.4                            |
      | script.php                         |

  Scenario: Uses cache configuration
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
      | arg                                                                       |
      | --rm                                                                      |
      | -i                                                                        |
      | --init                                                                    |
      | -v <user home>/dev:<user home>/dev                                        |
      | -u <user uid>:<user gid>                                                  |
      | -w <user home>/dev                                                        |
      | -v <rid cache>/composer/!home!<user name>!.cache:/home/<user name>/.cache |
      | --entrypoint composer                                                     |
      | reload/drupal-php7-fpm:7.3                                                |
      | install                                                                   |

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
      | -i                     |
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
      | arg                                |
      | --rm                               |
      | -i                                 |
      | --init                             |
      | -v <user home>/dev:<user home>/dev |
      | -u <user uid>:<user gid>           |
      | -w <user home>/dev                 |
      | --entrypoint php                   |
      | php:7.4                            |
      | -p 1234:1234                       |
      | /serenata.phar -u 1234             |

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
      | -i                |
      | hadolint/hadolint |
      | hadolint -        |
