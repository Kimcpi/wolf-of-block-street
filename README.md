# Wolf of Block Street

A Roblox experience: a virtual market simulator where players buy and sell
fictional "Trend Shares" based on in-game listings.

## Fictional currency

All money in this experience is fictional and exists only inside the game.
There is no Robux conversion, no real-money value, no cash-out, and no
connection to real investing or real market data. Prices and listings are
invented by the game.

## Project layout

Scripts live on disk and are synced into Roblox Studio by
[Rojo](https://rojo.space). `default.project.json` is the map between the two.

| Folder | Becomes in Studio | Visible to |
| --- | --- | --- |
| `src/server` | `ServerScriptService.Server` | Server only, never sent to players |
| `src/client` | `StarterPlayerScripts.Client` | Runs on each player's machine |
| `src/shared` | `ReplicatedStorage.Shared` | Both server and client |

`WolfOfBlockStreet.rbxl` holds the 3D world. Rojo does not manage it.

Money, holdings, prices, and trade validation belong in `src/server` so that a
player cannot read or modify them. Code in `src/client` only displays values and
requests actions; the server decides whether to allow them.

## Starting work

1. Open this folder in VS Code
2. In a terminal here, start the sync server. It stays running — leave it open:

   ```
   rojo serve
   ```

3. Open `WolfOfBlockStreet.rbxl` in Roblox Studio
4. **Plugins** tab -> **Rojo** -> **Connect** (allow the `localhost` prompt if asked)
5. Edit `.luau` files in VS Code. Saving syncs them into Studio automatically
6. Press **Play** in Studio to run. Read `print` output in the **Output** window
   (**Window** menu -> **Output**)

Stop the server with `Ctrl+C` in the terminal when you are done.

## Rule: do not edit synced scripts inside Studio

Rojo syncs one way, disk to Studio. Anything you type into Studio's script
editor for a file under `src/` is silently overwritten on the next sync. Edit
those files in VS Code only.

Studio is for the 3D world, playtesting, and reading Output.

## Setup, first time only

Requires the Rojo CLI and its Studio plugin at matching versions (7.7.0 here).

1. Download the Rojo release for your platform from
   <https://github.com/rojo-rbx/rojo/releases> and put `rojo.exe` somewhere on
   your `PATH`
2. Install the matching Studio plugin:

   ```
   rojo plugin install
   ```

3. Restart Studio. A **Rojo** button should appear in the **Plugins** tab
