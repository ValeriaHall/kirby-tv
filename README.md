# Kirby TV Script

A fully functional FiveM TV script that allows players to play, pause, and stop videos on in-game TVs.

## Features

- Play videos from URLs with `/tvplay {Link}`
- Pause playback with `/tvpause`
- Stop playback with `/tvstop`
- Server-synchronized TV state for all players
- Multiple TV model support
- Chat notifications for actions

## Installation

1. Clone or download this script into your resources folder
2. Add `ensure kirby-tv` to your server.cfg
3. Restart your server or start the resource

## Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `/tvplay` | `/tvplay {url}` | Start playing a video from the provided URL |
| `/tvpause` | `/tvpause` | Pause the currently playing video |
| `/tvstop` | `/tvstop` | Stop the TV and remove it |

## Example Usage

```
/tvplay https://www.youtube.com/watch?v=dQw4w9WgXcQ
/tvpause
/tvstop
```

## Configuration

Edit `shared.lua` to customize:
- TV Models
- Supported video platforms
- Other settings

## Files

- `client.lua` - Client-side script handling commands and TV entity management
- `server.lua` - Server-side script for state synchronization
- `shared.lua` - Configuration and shared data
- `fxmanifest.lua` - Resource manifest

## Notes

- The TV spawns in front of the player when `/tvplay` is used
- All players on the server see the same video
- The TV state persists when new players join
- Use full URLs for best compatibility

## Support

For issues or suggestions, contact the script author.
