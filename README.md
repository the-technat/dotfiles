# dotfiles

My engineering environment as code managed by [chezmoi](https://chezmoi.io). 

## Scope

chezmoi is the first and only tool I install manually using this command:

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin init --apply the-technat
```

chezmoi will then install all desktop/cli tools I need to work as a systems engineer and also configure these tools to work together.

Some notes:
- before you can install any tools chezmoi will prompt for the installation of XCode command line tools, do that and then rerun chezmoi
- In case some keychain items are missing, you have to manually create the entires in the `login` keychain based on the `iCloud` keychain entires as the `login` keychain is not synced.

### Exceptions
Since the world isn't perfectly as code, some exceptions to the above scope exist:

- VS Code Settings are synced via Github Settings Sync

## OS Support

My engineering environment is used only on `darwin`-based systems. Either `amd64` or `arm64` architecture.

## Concepts

### Tools

Tools are installed using [homebrew](https://brew.sh). This has the benefit that updating the tools is as simple as running a `brew upgrade` and that I can also easily install desktop tools on Mac. I'm still a bit sceptical about the security of homebrew, but since it has almost 100% adoption in the Mac world, it's a no-brainer to still choose it.

### Secrets

chezmoi has access to the keychain on my mac and thus to any kind of secret I might want to inject into a tool. 

Putting secrets into keyring is explained here: https://www.chezmoi.io/user-guide/password-managers/keychain-and-windows-credentials-manager/

For SSH keys you can additionally store it's passphrase permanently in the keychain. To do so, hit this command once:

```
ssh-add --apple-use-keychain ~/.ssh/id_gh
```

This will store the passphrase for `id_gh` in your iCloud Keychain. Note: the ssh key itself is still required to be on disk.
