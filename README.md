# bwg — BuildWithGit CLI

The command-line tool for [buildwithgit.com](https://buildwithgit.com). Clone challenges, test locally, submit with one command.

---

## Install

### macOS & Linux

Open your terminal and run:

```
curl -sSL https://raw.githubusercontent.com/buildwithgitstarter/buildwithgit-cli/main/install.sh | sh
```

Verify with:

```
bwg --version
```

### Windows

1. Go to the [latest release](https://github.com/buildwithgitstarter/buildwithgit-cli/releases/latest)
2. Download the `.zip` file for your system:
   - `bwg_x.x.x_windows_amd64.zip` for most Windows PCs
   - `bwg_x.x.x_windows_arm64.zip` for ARM-based Windows devices
3. Extract the zip
4. Move `bwg.exe` to a folder in your PATH (e.g. `C:\Users\YourName\bin`)
5. Open a new terminal and run `bwg --version`

---

## Usage

### 1. Start a challenge

Go to a challenge on [buildwithgit.com](https://buildwithgit.com), click **"Copy bwg init"**, then paste it in your terminal:

```
bwg init byogit/your-hash build-your-own-git
```

This sets up `build-your-own-git/`. Enter the directory:

```
cd build-your-own-git
```

Or browse and clone challenges interactively:

```
bwg list
```

### 2. Write your code

Open `main.py` in your editor and solve the current stage.

### 3. Test locally

```
bwg run
```

Runs the current stage's tests on your machine using [uv](https://docs.astral.sh/uv/). If uv isn't installed, bwg will offer to install it for you.

You can also test a specific stage:

```
bwg run --stage 3
```

### 4. Submit

```
bwg submit
```

Stages, commits, and pushes your code. The server runs tests automatically and shows the result right in your terminal.

Local tests must pass before submitting. If you haven't run `bwg run` yet, submit will run them automatically.

You can also pass a message:

```
bwg submit -m "implement hash-object"
```

No limit on submissions. Fix and run `bwg submit` again.

---

## Update

```
bwg update
```

Downloads and installs the latest version automatically.

---

## All commands

| Command | What it does |
|---|---|
| `bwg init <challenge/hash> <dir>` | Set up a challenge |
| `bwg list` | Browse and clone challenges interactively |
| `bwg run` | Test current stage locally |
| `bwg run --stage 3` | Test a specific stage locally |
| `bwg submit` | Run local tests, then push to server |
| `bwg submit -m "msg"` | Submit with a custom commit message |
| `bwg update` | Update bwg to latest version |
| `bwg --version` | Show installed version |
| `bwg --help` | Show help |

---

## Troubleshooting

**"command not found: bwg"**
- macOS/Linux: Make sure `/usr/local/bin` is in your PATH
- Windows: Make sure the folder containing `bwg.exe` is in your PATH

**"uv is not installed"**
- bwg will offer to install it automatically, or install manually: `curl -LsSf https://astral.sh/uv/install.sh | sh`

**Tests failed**
- Read the error output — it tells you what went wrong
- Fix your code and run `bwg run` to test locally, then `bwg submit`

---

Built by [buildwithgit.com](https://buildwithgit.com)
