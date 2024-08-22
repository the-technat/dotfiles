# dotfiles

My engineering environment as code managed by [chezmoi](https://chezmoi.io). 

## Scope

chezmoi is the first and only tool I install manually using this command:

```console
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin init --apply the-technat
```

chezmoi will then install all desktop/cli tools I need to work as a systems engineer and also configure these tools to work together.

### Exceptions
Since the world isn't perfectly as code, some exceptions to the above scope exist:

- VS Code Settings are synced via Github Settings Sync

## OS Support

My engineering environment is used on two types of computers:
1. Mac's for primary work
2. headless linux systems (e.g local VM, codespace, devcontainer, server...)

For the later, we focus on flavors of Ubuntu and exclude compatibility with other distros. 

## Concepts

### Tools

Tools are installed using [homebrew](https://brew.sh). This has the benefit that updating the tools is as simple as running a `brew update` and that I can also easily install desktop tools on Mac. I'm still a bit sceptical about the security of homebrew, but since it has almost 100% adoption in the Mac world, it's a no-brainer to still choose it.

### Secrets

chezmoi on Mac's has access to my iCloud Keychain and thus to any kind of secret I might want to inject into a cli tool. For linux machines, these secrets must be added manually if needed.

### Interactive

Mac-specific things are allowed to prompt for input sometimes, but everything that's used on linux as well should be completely non-interactive so that it can be installed automatically in let's say a codespace.