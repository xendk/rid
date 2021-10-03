Feature: Allow for caching directories between runs for tools that cache data.

  Scenario: Single cache configuration
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

  Scenario: Multiple cache entries configuration
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
