# rid

`rid`, which is the unimaginative ancronym for "run in docker", is the
spiritual successor to [dce])(https://github.com/xendk/dce).

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
