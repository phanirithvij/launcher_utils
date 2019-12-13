# launcher_utils

A flutter plugin that exposes some android APIs to help build home screen replacement apps.

**LICENSE:** [BSD 3-Clause](LICENSE)

**Status:** WIP

## Todo

- [ ] Wallpaper
  - [x] Get Wallpaper
    - [x] As an image
    - [ ] WallpaperInfo (for live wallpapers)
  - [ ] Set Wallpaper
    - [ ] Through Image
    - [ ] Live Wallpapers
    - [ ] Set wallpaper options (all avaialable activities)
    - [ ] Set wallpaper methods
      - [ ] Crop and set wallpaper
      - [ ] Set using ...
  - [ ] Set Wallpaper Offsets
  - [ ] Set Wallpaper Offset Hints (?)
  - [ ] Link to a pageview controller
  - [ ] Colors
    - [ ] Get wallpaper colors
- [ ] Apps
  - [ ] Get a list of apps
  - [ ] Cache appinfos
  - [ ] refresh appinfos
  - [ ] cache icons
  - [ ] icons of different sizes (?)
  - [ ] AppCacheProvider
  - [ ] New app installed/uninstalled events
    - [ ] Also provides a flag to check if it's an icon pack
  - [ ] Launch an App
- [ ] Icon Packs
  - [ ] Get supported icon packs
  - [ ] For each icon pack provide icon path and label
  - [ ] A method to get the icon (?)
- [ ] Send events to live wallpaper

---

Extra (for my launcher) still open source

- [ ] App categories
  - [ ] By color
  - [ ] All apps which are installed in debug mode.
  - [ ] App categories based on this
- [ ] Apps
  - [ ] Save given configuration in db
- [ ] App shortcut info
  - [ ] Get app shortcuts
  - [ ] Subscribe to these events
    - [ ] Add shortcut to home page
- [ ] Search Apps
  - [ ] By name
  - [ ] Open search term in play store
- [ ] Expose this as a BLOC (?, ??)

(?) denotes it's unclear whether to implement it.
(??) denotes it's unclear how to implement it.

> Move this to top once it's done.
> Check out my Launcher [play store link]() [coming soon].
