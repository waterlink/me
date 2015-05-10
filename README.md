# Me

Small tool for switching common identities (ssh keys, git config, etc)

## TODO

- [x] Split `Store` into 3 independent stores and remove how much small domain logic it has left
- [x] Cover mappers and `Store2` with unit specs
- [x] Kill `Store`. And leave `Store2` with its name (it sounds cool :D )
- [ ] Implement actual activation of configurations for ssh and git (probably invoked by `me`)

## Installation

```
gem install me
```

## Usage

```
me --help
```

### Switching identity

```
me switch NAME

# Example:
me switch personal
me switch work
```

### Checking which identity is active

```
me
# or
me whoami
```

### Configuring git identity

```
me config git NAME GIT_FULL_NAME GIT_EMAIL

# Example:
me config git personal 'John Smith' 'john.smith@example.org'
me config git work 'John S.' 'john.s@corporation.com'
```

### Configuring ssh identity

```
me config ssh NAME SSH_KEYS

# Example
me config ssh personal ~/.ssh.personal/github ~/.ssh.personal/bitbucket ~/.ssh.personal/id_vps
me config ssh work ~/.ssh.work/id_rsa
```

## Contributing

1. Fork it ( https://github.com/waterlink/me/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) - Oleksii Fedorov, creator, maintainer
