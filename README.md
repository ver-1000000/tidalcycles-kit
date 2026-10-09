<p align="center">
  English · <a href="./README.ja.md">日本語</a>
</p>

# tidalcycles-kit

A container toolkit for running TidalCycles.
Play from VS Code or Neovim without installing Haskell or SuperCollider directly on your computer.

Support for Windows and macOS is something we'd like to add in the future.

## Getting started

You need Linux with PipeWire, Bash 4+, Git, and `docker compose` or `podman compose` running containers on the same host.

The instructions below use Docker. For Podman, replace `docker compose` with `podman compose`.

```sh
git clone https://github.com/ver-1000000/tidalcycles-kit.git
cd tidalcycles-kit
docker compose up
```

The first run may take several minutes to download the software and samples and build the images.

**When `TIDAL_KIT_AUDIO_READY` appears, the music environment is ready.**
Keep the terminal open and continue with the editor setup below.

### Start and stop commands

Run these commands from the repository directory.

| Task | Command |
| --- | --- |
| Start in the background | `docker compose up -d` |
| Start in the background and wait until ready | `docker compose up --wait` |
| Build the images without starting | `docker compose build` |
| Rebuild and start after an update | `docker compose up --build` |
| Shut down the music environment | `docker compose down` |

After an update, reconnect the editor's Tidal session as well.

## Use your editor

Keep the music environment running while you configure your editor.
Replace the paths with **absolute paths** to this repository, and open your editor with your song folder as its working directory.

### VS Code

1. Install the [TidalCycles extension](https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles)
2. Replace both paths in the [example settings](editors/vscode.settings.json) and add the entries to your project's VS Code settings
3. Open a `.tidal` file and play using the extension's evaluation and stop commands

Use a repository path **without spaces** because the extension launches through a shell.

You can start the music environment in VS Code's integrated terminal. Leave `docker compose up` running while you play, then press `Ctrl+C` in that terminal to stop it.

### Neovim: vim-tidal

Install [vim-tidal](https://github.com/tidalcycles/vim-tidal) and source this configuration **before loading the plugin**:

```vim
source /path/to/tidalcycles-kit/editors/vim-tidal.vim
```

Open a `.tidal` file to use the plugin's evaluation and stop commands. Stop playback with `:TidalHush`.

### Neovim: tidal.nvim

Install [tidal.nvim](https://github.com/grddavies/tidal.nvim) and load this configuration:

```lua
dofile('/path/to/tidalcycles-kit/editors/tidal.nvim.lua')
```

Open a `.tidal` file and connect with `:TidalLaunch`, then use the plugin's evaluation and stop commands.

## Troubleshooting

First, check the status and audio logs from the repository directory:

```sh
docker compose ps -a
docker compose logs --tail=100 audio
```

- **Both Docker and Podman are installed**
  - Editor connections prefer Podman, so to use Docker, launch your editor from a shell with `export TIDAL_KIT_ENGINE=docker`
- **The PipeWire socket cannot be found**
  - Run from a terminal belonging to the user running PipeWire, and check `XDG_RUNTIME_DIR` and the `pipewire-0` socket inside it
  - SSH and `sudo` may use a different environment
- **`UDP 57110 is occupied` / `UDP 57120 is occupied` appears**
  - Use `ss -lunp` to identify SuperCollider, SuperDirt, or another process using the same port, and stop the conflicting music session
- **The editor cannot connect**
  - Check the absolute paths in your settings and the engine used by Compose and your editor
  - Sharing your entire home directory or `/` as the working directory is rejected
- **The music environment is ready but there is no sound**
  - Check editor evaluation errors, the PipeWire output device, mute, and volume
  - Increase volume gradually
- **The editor's Tidal session remains after shutdown**
  - The editor connection runs in a separate container. Use the plugin's session shutdown command or send `:quit` to GHCi
  - `hush` only stops playback

## License

The kit's own code is licensed under the [MIT License](LICENSE). Dependencies retain their respective licenses.

See [third-party software](THIRD_PARTY.md) for details.
