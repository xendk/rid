# rid

`rid`, which is the unimaginative ancronym for "run in docker", is the
spiritual successor to [dce])(https://github.com/xendk/dce).

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
