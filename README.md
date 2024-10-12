# dotfiles

My engineering environment as code managed by [chezmoi](https://chezmoi.io). 

## OS Support

My main computers are Mac's running either Intel or Apple Silicon. All desktop/credential related stuff is installed only there.

For various side-usages I have also added support for linux, but there only `amd64`-based systems and without desktop tools (homebrew currently doesn't support `arm64` on linux).

## Usage

chezmoi is the first and only tool I install manually using this command:

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin init --apply the-technat
```

chezmoi will then install all desktop/cli tools I need to work as a systems engineer and also configure these tools to work together.

Some notes for MacOS:
- before you can install any tools chezmoi will prompt for the installation of XCode command line tools only on MacOS), do that and then rerun chezmoi
- In case some keychain items are missing, you have to manually create the entires in the `login` keychain based on the `iCloud` keychain entires as the `login` keychain is not synced using iCloud.

### Exceptions
Since the world isn't perfectly as code, some exceptions to my "as-code" workflow exist:

- VS Code Settings are synced via Github Settings Sync
- Any general MacOS settings 
- Productivity tools like a clipboard or window manager
- VPN clients (they are used for more than just coding)

## Concepts

### Tools

Tools are installed using [homebrew](https://brew.sh). This has the benefit that updating the tools is as simple as running a `brew upgrade` and that I can also easily install desktop tools on Mac. I'm still a bit sceptical about the security of homebrew, but since it has almost 100% adoption in the Mac world, it's a no-brainer to still choose it.

Homebrew currently doesn't support `arm64`-based linux distros, but we can live with that.

### Secrets

chezmoi has access to the keychain on my mac and thus to any kind of secret I might want to inject into a tool. 

Putting secrets into keyring is explained here: https://www.chezmoi.io/user-guide/password-managers/keychain-and-windows-credentials-manager/

For SSH keys you can additionally store it's passphrase permanently in the keychain. To do so, hit this command once:

```
ssh-add --apple-use-keychain ~/.ssh/id_gh
```

This will store the passphrase for `id_gh` in your keychain. Note: the ssh key itself is still required to be on disk.

I'm currently evaluating whether I need secrets to be present on remote linux systems as well, or if forwarding of the credentials is sufficient.
