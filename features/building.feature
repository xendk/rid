Feature: rid should build images

  Scenario: Build image explicitly
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image
      """
    And I have a "Dockerfile" file in "my-image"
    When I type "rid --build custom-image" in "dev"
    Then it should output:
      """
      rid: building image...
      [docker build output]
      rid: done
      """
    And it runs "docker build" with:
      | arg                         |
      | --label dk.xen.rid=my-image |
      | --tag my-image:rid          |
      | .                           |

  Scenario: Should support relative file paths
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:docker-images/my-image
      """
    And I have a "Dockerfile" file in "dev/docker-images/my-image"
    When I type "rid --build custom-image" in "dev/subdir"
    Then it should output:
      """
      rid: building image...
      [docker build output]
      rid: done
      """
    And it runs "docker build" with:
      | arg                         |
      | --label dk.xen.rid=my-image |
      | --tag my-image:rid          |
      | .                           |

  Scenario: Support alternative Dockerfile names
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image/Dockerfile.example
      """
    And I have a "Dockerfile.example" file in "my-image"
    When I type "rid --build custom-image" in "dev"
    Then it should output:
      """
      rid: building image...
      [docker build output]
      rid: done
      """
    And it runs "docker build" with:
      | arg                                            |
      | --label dk.xen.rid=my-image-example |
      | --tag my-image-example:rid          |
      | --file Dockerfile.example                      |
      | .                                              |

  Scenario: Should error if not a buildable image
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: someimage
      """
    And I have a "Dockerfile" file in "some"
    When I type "rid --build custom-image" in "dev"
    Then it should exit with a "rid: someimage not a buildable image. Use \"file:<path>\" to build a dockerfile" error

  Scenario: It should complain if Dockerfile doesn't exist
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image
      """
    When I type "rid --build custom-image" in "dev"
    Then it should exit with a "rid: cannot find <user home>/my-image" error

  Scenario: Should not try to build non-file paths
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: <user home>/my-image
      """
    And I have a "Dockerfile" file in "my-image"
    When I type "rid custom-image" in "dev"
    Then it should output nothing
    And it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --user <user uid>:<user gid>             |
      | --volume <user home>/dev:<user home>/dev |
      | --workdir <user home>/dev                |
      | <user home>/my-image                     |

  Scenario: Should build image automatically if not built
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image
      """
    And I have a "Dockerfile" file in "my-image"
    When I type "rid custom-image" in "dev"
    Then it should output nothing
    And it runs "docker images" with:
      | arg                               |
      | --format {{.Tag}}\t{{.CreatedAt}} |
      | my-image:rid                      |
    And it runs "docker build" with:
      | arg                         |
      | --label dk.xen.rid=my-image |
      | --tag my-image:rid          |
      | .                           |
    And it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --user <user uid>:<user gid>             |
      | --volume <user home>/dev:<user home>/dev |
      | --workdir <user home>/dev                |
      | my-image:rid                             |

  Scenario: --dry-run should also print build command
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image
      """
    And I have a "Dockerfile" file in "my-image"
    When I type "rid --dry-run custom-image" in "dev"
    Then it should output:
      """
      rid: would run: docker build --label dk.xen.rid\=my-image --tag my-image:rid .
      rid: would run: docker run --rm --interactive --init --user 1000:1000 --workdir /tmp/rid/home/dev --volume /tmp/rid/home/dev:/tmp/rid/home/dev --env HOME --env USER --env USERNAME --env LOGNAME my-image:rid
      """

  Scenario: Should not re-build image if image is newer
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image2
      """
    And I have a "Dockerfile" file in "my-image2"
    And "my-image2" has modification time "2022-04-18 02:32:42 +0200 CEST"
    And "my-image2/Dockerfile" has modification time "2022-04-18 02:32:42 +0200 CEST"
    When I type "rid custom-image" in "dev"
    Then it should output nothing
    And it runs "docker images" with:
      | arg                               |
      | --format {{.Tag}}\t{{.CreatedAt}} |
      | my-image2:rid                     |
    And it should not run "docker build"
    And it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --user <user uid>:<user gid>             |
      | --volume <user home>/dev:<user home>/dev |
      | --workdir <user home>/dev                |
      | my-image2:rid                            |

  Scenario: Should rebuild image automatically if Dockerfile changed
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image2
      """
    And I have a "Dockerfile" file in "my-image2"
    And "my-image2" has modification time "2022-04-20 02:32:42 +0200 CEST"
    And "my-image2/Dockerfile" has modification time "2022-04-20 02:32:42 +0200 CEST"
    When I type "rid custom-image" in "dev"
    Then it should output nothing
    And it runs "docker images" with:
      | arg                               |
      | --format {{.Tag}}\t{{.CreatedAt}} |
      | my-image2:rid                     |
    And it runs "docker build" with:
      | arg                          |
      | --label dk.xen.rid=my-image2 |
      | --tag my-image2:rid          |
      | .                            |
    And it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --user <user uid>:<user gid>             |
      | --volume <user home>/dev:<user home>/dev |
      | --workdir <user home>/dev                |
      | my-image2:rid                            |

  Scenario: Should show build output when configured to
    Given I have a "dev" config file:
      """
      commands:
        custom-image:
          image: file:<user home>/my-image
          show_build: true
      """
    And I have a "Dockerfile" file in "my-image"
    When I type "rid custom-image" in "dev"
    Then it should output:
      """
      rid: building image...
      [docker build output]
      rid: done
      """
    And it runs "docker images" with:
      | arg                               |
      | --format {{.Tag}}\t{{.CreatedAt}} |
      | my-image:rid                      |
    And it runs "docker build" with:
      | arg                         |
      | --label dk.xen.rid=my-image |
      | --tag my-image:rid          |
      | .                           |
    And it runs "docker run" with:
      | arg                                      |
      | --rm                                     |
      | --interactive                            |
      | --init                                   |
      | --user <user uid>:<user gid>             |
      | --volume <user home>/dev:<user home>/dev |
      | --workdir <user home>/dev                |
      | my-image:rid                             |

  Scenario: Should use image relative to the file it was referenced in
    Given I have a "dev" config file:
      """
      commands:
        base-image:
          image: file:<user home>/my-image
      """
    Given I have a "dev/sub" config file:
      """
      commands:
        custom-image:
          inherit: base-image
      """
    And I have a "Dockerfile" file in "my-image"
    When I type "rid custom-image" in "dev/sub"
    Then it should output nothing
    And it runs "docker images" with:
      | arg                               |
      | --format {{.Tag}}\t{{.CreatedAt}} |
      | my-image:rid                      |
    And it runs "docker build" in "my-image" with:
      | arg                         |
      | --label dk.xen.rid=my-image |
      | --tag my-image:rid          |
      | .                           |
    And it runs "docker run" with:
      | arg                                              |
      | --rm                                             |
      | --interactive                                    |
      | --init                                           |
      | --user <user uid>:<user gid>                     |
      | --volume <user home>/dev/sub:<user home>/dev/sub |
      | --workdir <user home>/dev/sub                    |
      | my-image:rid                                     |
