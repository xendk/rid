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

# What it does

`rid` runs commands in containers, trying to hide the fact that the
command is run in a container as much as possible. It does this by:

1. Mounting in the root directory (the directory containing the
   `.rid.yml` file) to the same path inside the container. This
   ensures file paths will be the same on both sides, and that the
   running command has access to files it works with.
2. Change the UID/GID of the command to the UID/GID of the running
   user. This limits the commands privileges (many images run as root
   per default) and fixes many file permission issues.
3. Exports the `HOME`, `USER`, `USERNAME` and `LOGNAME` variables into
   the container.
4. Changes the current working directory of the command in the
   container to the current working directory. This makes any relative
   file names work seamlessly.
5. Tells docker it's an "interactive" command, and give it a TTY if
   rid has one.

These steps makes most commands behave as if they where run locally.

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

# `rid` options

Options can only be specified when running `rid`, not when using a
symlink, and needs to come before the command name. Everything after
the command name is still passed to the command.

`-s`/`--shell`: Launch an interactive shell in the container. Will try
`/usr/bin/fish`, `/bin/bash` and `/bin/sh`, in that order.

`-n`/`--dry-run`: Print the docker command that would be run.

# Configuration file

`rid` will look for `.rid.yml` files from the current directory and
upwards in the file-system and read all it finds. Configuration files
inherit from each other, with commands lower in the file-system
overriding those found nearer the file-system root, unless told
otherwise with the `inherit` option.

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

* `image` (string): The image to run for this command.
* `entrypoint` (string): Override image entrypoint.
* `args` (string): Additional args for the image. If the images entrypoint is
  the desired command, this is provided as command arguments. Any
  extra arguments from the command line is appended to this.
* `cache` (string or list of strings): Cache a directory. A cached directory is persistent between
  command invocations. Behind the scenes `rid` creates a directory per
  command and mounts it in.
* `inherit` (bool or string): Inherit from another command. If set to
  `true`, inherit from a command with the same name in a parent
  `.rid.yml` file. If set to a string, inherit from the named command.
* `mount` (string or list of strings): Mount in additional directories.
* `ports_from_args` (regexp string): Matches the regexp against the
  command args to extract a port number to bind to the host.
* `raw` (bool): Don't mount in root filesystem, change effective
  uid/gid, forward selected env vars or change the working directory.
  This basically makes rid behave like a vanilla `docker run`. This
  option is going to be renamed to something more sensible at some
  time.
* `keep`: Don't remove the container when the command exits. Useful
  for debugging.
* `mount_args` (regexp string or list of regexps): Mount in files
   given in the arguments that exists and matches regexp.
* `network` (string): Network type or name. Same as the --network
  argument to docker.
