# launcher_utils

A flutter plugin that exposes some android APIs to help build home screen replacement apps.

> A Note to self:
> Also start an Icon Pack explorer plugin

**LICENSE:** [BSD 3-Clause](LICENSE)

**Status:** WIP

## Todo

- [ ] Wallpaper
  - [x] Get Wallpaper
    - [x] As an image
    - [ ] WallpaperInfo (for live wallpapers)
  - [x] Set Wallpaper
    - [x] Through Image
    - [x] Live Wallpapers
    - [ ] Set wallpaper options (all avaialable activities)
    - [ ] Set wallpaper methods
      - [ ] Crop and set wallpaper
      - [x] Set using ...
  - [x] Set Wallpaper Offsets
  - [ ] Set Wallpaper Offset Hints (?)
  - [x] Link to a pageview controller
  - [x] Colors
    - [x] Get wallpaper colors
- [ ] Apps
  - [ ] Get a list of apps
    - [ ] Apps currently installed.
    - [ ] Apps that were installed from the beginning i.e., including the apps that were uninstalled. (Might be useful, eg. to show the user recently deleted apps in a page)
  - [ ] Cache appinfos
  - [ ] refresh appinfos
  - [ ] cache icons
  - [ ] icons of different sizes (?)
  - [ ] AppCacheProvider
  - [ ] New app installed/uninstalled events
    - [ ] Also provides a flag to check if it's an icon pack
  - [x] Launch an App
- [ ] Icon Packs (Look at Launcher3, OpenLauncher)
  - [ ] Get supported icon packs
    - [ ] Their icons and labels
  - [ ] For each icon pack provide icon path and label
  - [ ] A method to get the icon (?)
- [x] Send events to live wallpaper

---

Extra (for my launcher) still open source.

- [ ] App categories
  - [ ] By color
  - [ ] All the apps installed in debug mode.
  - [ ] App categories based on this
- [ ] Apps
  - [ ] Save given configuration in a database.
- [ ] App shortcut info
  - [ ] Get app shortcuts
  - [ ] Subscribe to these events
    - [ ] Add shortcut to home page event
- [ ] Widgets (???)
  - [ ] Widget picker
  - [ ] Widget previews, info
  - [ ] WidgetView a view that handles widgets
    - [ ] **Must not use AndroidView which compromises API to be 21 and is extremely expensive**
    - [ ] Try a flutter view and a widget page in a page view. I'm sure it doesn't work. Refer [less-useful-docs](https://github.com/flutter/flutter/wiki/Experimental:-Add-Flutter-View) and [useful-examples](https://github.com/flutter/flutter/tree/master/examples/flutter_view)
- [ ] Search Apps
  - [ ] By name
  - [ ] Open search term in play store
- [ ] Expose this as a BLOC (???)
- [ ] Blurred Wallpaper (??)
- [ ] Refactor the android and dart code
- [ ] Events
  - [ ] App installed/uninstalled events
    - [ ] Whether the app is a icon pack
    - [ ] If using any widgets from this app
  - [ ] Widget add/remove/update events (???)
  - [ ] Wallpaper changed events
  - [ ] Add shortcut to home page event
  - [ ] Along with exposing specific method calls for events, also provide an event queue to flutter to facilitate animating the new changes since the last visit, eg. One can animate the newly installed apps, newly deleted apps, etc.

(?) denotes that it's unclear whether to implement it.
(??) denotes that it's unclear how to implement it.
(???) => ? + ??

> Move this to the top once done.
> Check out my Launcher [play store link]() [coming soon].
