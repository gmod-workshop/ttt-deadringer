# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.1.0]

### Fixed
- Fixed sound networking so that sounds should now play appropriately on only the owner or all clients
- Fixed the classic HUD not drawing on TTT2 when the `ttt_deadringer_hud_classic` setting is active

### Added
- Added many new settings for adjusting what sounds are played and who hears them
    - Settings
        - `ttt_deadringer_sound_recharge`
        - `ttt_deadringer_sound_uncloak`
        - `ttt_deadringer_sound_activate`
        - `ttt_deadringer_sound_deactivate`
    - You can also suffix these settings with `_local` to change if they are only played to the owner or everyone
        - Ex: `ttt_deadringer_sound_uncloak_local 0` will make it so only the owner hears the uncloak sound
- Added `ttt_deadringer_hud_classic`
    - Want to use the classic Dead Ringer HUD even in TTT2? Now you can!
- Added `ttt_deadringer_hud_persist`
    - If you are using the classic HUD, this will make the HUD persist on even if the Dead Ringer isn't active
- Added `ttt_deadringer_cloak_reactivate`
    - When this setting is enabled the Dead Ringer will automatically reactivate when charged


### Changed
- Changed the classic HUD to only draw when the Dead Ringer is activated, cloaked, or on cooldown.
    - You can change this with the new `ttt_deadringer_hud_persist` setting

## [3.0.1]

### Fixed
- Fixed custom think hook not being called properly on dedicated servers

## [3.0.0]

### Fixed
- Fixed even more issues with a player's weapons still being visible to other players
    - This had to do with the weapon's `SWEP:Think` not being called properly at all times
- Fixed a player's role being forcibly set when being confirmed
- Fixed weapon think code not being called on clients for listen servers
- Fixed several hooks not being registered properly by ensuring they are registered after the gamemode has loaded
    - `TTT2` is not a valid global until *after* the gamemode has loaded (post `GM:Initialize`)

### Added
- Added `ttt_deadringer_cloak_transparency`
    - You can change how transparent the Dead Ringer cloak is for balance reasons (0.0 - 1.0)
    - By default it is completely transparent (0.0), if you want some subtle balance I recommend a setting of 0.05
- Added `ttt_deadringer_cloak_targetid`
    - By default the target id of the player will be hidden (setting of `0`) so you can't immediately follow where they are
    - You can set this to `1` if you want to be able to see the player's name when hovering over them still
- Added `ttt_deadringer_damage_threshold`
    - Previously the threshold to trigger the Dead Ringer was 2 damage, this is now a setting you can change
- The addon will now more closely mimic the Death Faker addon
    - While cloaked, if your body is discovered, the scoreboard will show you as confirmed dead
    - This will use your `ttt_deadringer_corpse_confirm` setting
        - If it is 0, you will just show as confirmed dead and no role
        - If it is 1, you will be shown as confirmed dead with your real role
        - If it is 2, you will be shown as confirmed dead as an innocent
    - This does NOT apply to public roles like Detective, your real role will always show
    - When the cloak ends, your death will automatically be unconfirmed when the corpse disappears
- Added some help test for TTT and TTT2 do show what the primary and secondary buttons do

### Changed
- Renamed `ttt_deadringer_chargetime` to `ttt_deadringer_cloak_cooldown` to be more consistent with the new transparency convar
- Renamed `ttt_deadringer_cloaktime` to `ttt_deadringer_cloak_duration` to be more consistent with other convars
- Renamed `ttt_deadringer_cloaktime_reuse` to `ttt_deadringer_cloak_reuse` to be more consistent with other convars
- Changed the weapon to use NW variables instead of NW2 variables
    - This may be temporary, NW2 variables are strongly preferred but I want to see if the addon is stable first

## [2.2.0]

### Fixed
- Fixed a cloaked player's weapons still be visible to other players

## [2.1.1]

### Fixed
- Fixed an issue where the ammo pickup sound was being played when buying the equipment from the shop

## [2.0.0]

### Added
- Added new setting `ttt_deadringer_corpse_mode`
    - There are currently 3 modes:
        * 0 (default) - A corpse with a 'Fake' role/team will be spawned for TTT2, for TTT this will just show innocent
        * 1 - A corpse will spawn with the player's REAL role (traitors will show as traitors, jackals as jackals, etc.) for both TTT2 and TTT
        * 2 - A corpse will spawn with a spoofed innocent role (traitors appear as innocent)

### Removed
- Removed the `ttt_deadringer_corpse_role` setting, use the new `ttt_deadringer_corpse_mode` setting

### Changed
- Changed the `ttt_deadringer_corpse_confirm` setting to default to off

## [1.1.0]

### Added
- Added new setting `ttt_deadringer_corpse_role`
    - Determines if a player's real role or a fake innocent role will be shown on the corpse
- Added new setting `ttt_deadringer_corpse_confirm`
    - Determines if the fake corpse will confirm the player's role when checked
    - This may be used in tandem with `ttt_deadringer_corpse_role` to confirm fake/real roles

## [1.0.1]

### Fixed
- Fixed misleading text for the `ttt_deadringer_damage_reduction_time` setting to mention that the value is in absolute seconds and not a percentage.

## [1.0.0]

### Fixed
- Fixed addon settings not being set correctly for TTT2 (#1)

[Unreleased]: https://github.com/gmod-workshop/ttt-deadringer/compare/3.1.0...HEAD
[3.1.0]: https://github.com/gmod-workshop/ttt-deadringer/compare/3.0.1...3.1.0
[3.0.1]: https://github.com/gmod-workshop/ttt-deadringer/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/gmod-workshop/ttt-deadringer/compare/2.2.0...3.0.0
[2.2.0]: https://github.com/gmod-workshop/ttt-deadringer/compare/2.1.1...2.2.0
[2.1.1]: https://github.com/gmod-workshop/ttt-deadringer/compare/2.0.0...2.1.1
[2.0.0]: https://github.com/gmod-workshop/ttt-deadringer/compare/1.1.0...2.0.0
[1.1.0]: https://github.com/gmod-workshop/ttt-deadringer/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/gmod-workshop/ttt-deadringer/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/gmod-workshop/ttt-deadringer/releases/tag/1.0.0
