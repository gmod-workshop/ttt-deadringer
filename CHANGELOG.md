# CHANGELOG

Inspired from [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [v2.1.1]
### Fixed
- Fixed an issue where the ammo pickup sound was being played when buying the equipment from the shop

## [v2.0.0]
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

## [v1.1.0]
### Added
- Added new setting `ttt_deadringer_corpse_role`
    - Determines if a player's real role or a fake innocent role will be shown on the corpse
- Added new setting `ttt_deadringer_corpse_confirm`
    - Determines if the fake corpse will confirm the player's role when checked
    - This may be used in tandem with `ttt_deadringer_corpse_role` to confirm fake/real roles

## [v1.0.1]
### Fixed
- Fixed misleading text for the `ttt_deadringer_damage_reduction_time` setting to mention that the value is in absolute seconds and not a percentage.

## [v1.0.0]
### Fixed
- Fixed addon settings not being set correctly for TTT2 (#1)
