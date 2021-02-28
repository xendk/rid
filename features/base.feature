Feature: Smoke test on initially hardcoded commands

  Scenario: Runs php
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
      | -u <user uid>:<user gid>           |
      | -v <user home>/dev:<user home>/dev |
      | -w <user home>/dev                 |
      | --entrypoint php                   |
      | php:7.4                            |
      | somescript.php                     |

  Scenario: Runs phpcs
    Given I have a "dev" config file:
      """
      commands:
        phpcs:
          image: reload/drupal-php7-fpm:7.3
          entrypoint: php
          args: /home/<user name>/php-stuff/vendor/bin/phpcs
      """
    And I have a "phpcs" symlink
    When I type "phpcs ." in "dev"
    Then it runs "docker run" with:
      | arg                                            |
      | --rm                                           |
      | -i                                             |
      | --init                                         |
      | -u <user uid>:<user gid>                       |
      | -v <user home>/dev:<user home>/dev             |
      | -w <user home>/dev                             |
      | --entrypoint php                               |
      | reload/drupal-php7-fpm:7.3                     |
      | /home/<user name>/php-stuff/vendor/bin/phpcs . |

  Scenario: Runs serenata
    Given I have a "dev" config file:
      """
      commands:
        serenata:
          image: serenata
          cache: "/home/$USER/.cache"
          port_from_args: /-u (\d+)/
      """
    And I have a "serenata" symlink
    When I type "serenata -u 1234" in "dev"
    Then it runs "docker run" with:
      | arg                                                                       |
      | --rm                                                                      |
      | -i                                                                        |
      | --init                                                                    |
      | -u <user uid>:<user gid>                                                  |
      | -v <user home>/dev:<user home>/dev                                        |
      | -v <rid cache>/serenata/!home!<user name>!.cache:/home/<user name>/.cache |
      | -w <user home>/dev                                                        |
      | -p 1234:1234                                                              |
      | serenata                                                                  |
      | -u 1234                                                                   |

  Scenario: Runs composer
    Given I have a "dev" config file:
      """
      commands:
        composer:
          image: reload/drupal-php7-fpm:7.3
          entrypoint: composer
          cache: "/home/$USER/.cache"
      """
    And I have a "composer" symlink
    When I type "composer install" in "dev"
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

  Scenario: Runs docker-langserver
    Given I have a "dev" config file:
      """
      commands:
        docker-langserver:
          image: rcjsuen/docker-langserver:latest
      """
    And I have a "docker-langserver" symlink
    When I type "docker-langserver args" in "dev"
    Then it runs "docker run" with:
      | arg                                |
      | --rm                               |
      | -i                                 |
      | --init                             |
      | -u <user uid>:<user gid>           |
      | -v <user home>/dev:<user home>/dev |
      | -w <user home>/dev                 |
      | rcjsuen/docker-langserver:latest   |
      | args                               |

  Scenario: Runs node
    Given I have a "dev" config file:
      """
      commands:
        node:
          image: node:14
          cache: "/home/$USER"
      """
    And I have a "node" symlink
    When I type "node stuff" in "dev"
    Then it runs "docker run" with:
      | arg                                                     |
      | --rm                                                    |
      | -i                                                      |
      | --init                                                  |
      | -v <user home>/dev:<user home>/dev                      |
      | -u <user uid>:<user gid>                                |
      | -w <user home>/dev                                      |
      | -v <rid cache>/node/!home!<user name>:/home/<user name> |
      | node:14                                                 |
      | stuff                                                   |

  Scenario: Runs hadolint
    Given I have a "dev" config file:
      """
      root: /home/user/dev
      commands:
        hadolint:
          image: hadolint/hadolint
          args: hadolint
          raw: true
      """
    And I have a "hadolint" symlink
    When I type "hadolint -" in "dev"
    Then it runs "docker run" with:
      | arg               |
      | --rm              |
      | -i                |
      | hadolint/hadolint |
      | hadolint -        |

  Scenario: Runs dive
    Given I have a "dev" config file:
      """
      root: /home/user/dev
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

  Scenario: Runs typescript-language-server
    Given I have a "dev" config file:
      """
      commands:
        typescript-language-server:
          image: typescript-language-server
      """
    And I have a "typescript-language-server" symlink
    When I type "typescript-language-server --tsserver-path /usr/bin/something and stuff" in "dev"
    Then it runs "docker run" with:
      | arg                                          |
      | --rm                                         |
      | -i                                           |
      | --init                                       |
      | -u <user uid>:<user gid>                     |
      | -v <user home>/dev:<user home>/dev           |
      | -w <user home>/dev                           |
      | typescript-language-server                   |
      | --tsserver-path /usr/bin/something and stuff |

  Scenario: Runs bash-language-server
    Given I have a "dev" config file:
      """
      commands:
        bash-language-server:
          image: bash-language-server
      """
    # And the following env variables:
    #   | name                     | value    |
    #   | EXPLAINSHELL_ENDPOINT    | endpoint |
    #   | HIGHLIGHT_PARSING_ERRORS | yes      |
    #   | GLOB_PATTERN             | star     |
    And I have a "bash-language-server" symlink
    When I type "bash-language-server and stuff" in "dev"
    Then it runs "docker run" with:
      | arg                                |
      | --rm                               |
      | -i                                 |
      | --init                             |
      | -u <user uid>:<user gid>           |
      | -v <user home>/dev:<user home>/dev |
      | -w <user home>/dev                 |
      | bash-language-server               |
      | and stuff                          |
