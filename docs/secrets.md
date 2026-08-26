# Secrets

Secrets are managed by [`pass`](https://www.passwordstore.org/): one GPG-encrypted file per secret under `~/.password-store/`, versioned with git. `./install.sh pass` installs it, creates a GPG key if you have none (asks for a passphrase once; the agent then caches it for 8h), and initialises the store.

Until that step has been run, `dots-secret` transparently uses the GNOME keyring instead (already running, unlocked by your login, nothing to set up). `dots-secret backend` tells you which one is active; the commands are identical.

```bash
dots-secret set aws/sandbox          # prompts for the value (or pipe it in)
dots-secret get aws/sandbox          # print (first line)
dots-secret copy aws/sandbox         # clipboard, cleared after 45s
dots-secret gen github/token 40      # generate + store
dots-secret edit aws/sandbox         # multi-line: secret on line 1, notes below
dots-secret ls | find aws | grep txt # list, search names, search contents
dots-secret rm aws/sandbox
dots-secret sync                     # git pull + push (after: pass git remote add origin <private repo>)
export OPENAI_API_KEY="$(dots-secret get openai)"   # in scripts / .envrc
```

Search `secret` in `Mod+Alt+Space` to pick one and copy it. Plain `pass` commands work on the same store.
