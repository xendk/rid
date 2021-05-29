# rid

`rid`, which is the unimaginative ancronym for "run in docker", is the
spiritual successor to [dce])(https://github.com/xendk/dce).

# ⚠ Warning ⚠

Per default `rid` gives images run access to everything in the
directory containing the `.rid.yml` file. If the `.rid.yml` file is
located in your home directory, this means that any rid run image
(unless the image uses the `raw` option) can read any file, including
sensitive files in, for instance, `.ssh` and `.gnupg`. In *theory*
this means a malicious image could steal your keys.

So it is *not* recommended to put a `.rid.yml` file in your home
directory (and future versions of `rid` might refuse to run if it
finds one). Instead you can add a `.rid.yml` file to each project, or
use a directory for all your project and put your root `.rid.yml` file
there.

# Invoking

To run a configured command with arguments:

``` shell
rid composer install
```

Or you can symlink a command to rid, and invoke it as:

``` shell
composer install
```

You can also start a shell in the container instead:

``` shell
rid -s composer
```

The latter can be handy for debugging why stuff doesn't work.

# rid options

Options can only be specified when running rid, not when using a
symlink, and needs to come before the command name. Everything after
the command name is still passed to the command.

`-s`/`--shell`: Launch an interactive shell in the container. Will try
`/usr/bin/fish`, `/bin/bash` and `/bin/sh`, in that order.

`-n`/`--dry-run`: Print the docker command that would be run.

# `.rid.yml` file format.

A `.rid.yml` file contains a `commands` key, and not much else at the
moment. `commands` are a hash of commands, which in turn are hashes
specifying how to run the command.

An example:

``` yaml
commands:
  php:
    image: php:7.4-cli-alpine
    entrypoint: php
  composer:
    image: reload/drupal-php7-fpm:7.4
    entrypoint: composer
    cache: "/home/$USER/.cache"
  serenata:
    image: serenata
    cache: "/home/$USER/.cache"
    port_from_args: /-u (\d+)/
  node:
    image: node:14
    cache: "/home/$USER"
  npm:
    inherit: node
    entrypoint: npm
  npx:
    inherit: node
    entrypoint: npx
  cypress:
    inherit: node
    image: cypress/included:3.8.3
  docker-langserver:
    image: rcjsuen/docker-langserver:latest
  bash-language-server:
    # Local image.
    image: bash-language-server
  css-languageserver:
    image: css-languageserver
  typescript-language-server:
    image: typescript-language-server
  hadolint:
    image: hadolint/hadolint
    # Image has no ENTRYPOINT so command line overrides command, so we
    # have to specify hadolint on the command line.
    args: hadolint
    # Flycheck runs hadolint in stdin mode, so no need to clone environment.
    raw: true
  dive:
    image: wagoodman/dive:latest
    mount:
      - /var/run/docker.sock
    raw: true
  platform:
    image: platform
    mount:
      # The installed command and setings.
      - /home/xen/.platformsh/
      # Platform.sh uses ssh
      - /home/xen/.ssh/
    entrypoint: /home/xen/.platformsh/bin/platform
```

## Command options

`args`
`cache`
`entrypoint`
`image`
`inherit`
`mount`
`ports_from_args`
`raw`
`keep`
