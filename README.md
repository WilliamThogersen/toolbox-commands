# toolbox-commands

A starter marketplace of small, low-permission commands for [toolbox](https://github.com/WilliamThogersen/toolbox) (`tb`).

```console
$ tb self market add starter https://github.com/WilliamThogersen/toolbox-commands.git
$ tb self install starter/crate
```

| Command | What it does | Permissions |
|---------|--------------|-------------|
| `crate` | Latest version, description, downloads and repo URL of a Rust crate | http: `crates.io` |
| `npm` | Latest version, description, last-month downloads and repo URL of an npm package | http: `registry.npmjs.org`, `api.npmjs.org` |
| `pypi` | Latest version, summary, license and links of a PyPI package | http: `pypi.org` |
| `weather` | Current weather and a short forecast for a place name (Open-Meteo, no key) | http: `geocoding-api.open-meteo.com`, `api.open-meteo.com` |
| `hn` | Top N Hacker News front page stories with points and comments link | http: `hn.algolia.com` |
| `gh-repo` | Public info about a GitHub repo: stars, language, latest release, open issues | http: `api.github.com` |
| `gh-prs` | Open pull requests waiting for your review (uses your GitHub token from the vault) | http: `api.github.com`, vault: `github` |

None of them use `exec`, `env`, file access or `http: ["*"]`.

## gh-prs and the vault

`gh-prs` is the one command that needs a key. Store a GitHub token first, then approve the command. The script only ever sees a placeholder, never the token:

```console
$ tb self vault add github --host api.github.com
$ tb self vault allow github gh-prs
$ tb gh-prs
```

## Add your own

See [docs/sharing.md](https://github.com/WilliamThogersen/toolbox/blob/main/docs/sharing.md) in toolbox: one folder per command, folder name equal to the manifest `name`, a `"version"` in `command.json`.

## License

MIT
