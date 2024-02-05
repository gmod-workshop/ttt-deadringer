AddCSLuaFile()

hook.Add('AddToolMenuCategories', 'DeadringerAddToolMenuCategories', function()
	spawnmenu.AddToolCategory('Utilities', 'Dead Ringer', 'Dead Ringer')
end)

local DEADRINGER_DEFAULTS = {
	ttt_deadringer_cloak_cooldown = 20,
	ttt_deadringer_cloak_duration = 7,
	ttt_deadringer_cloak_reuse = 0,
	ttt_deadringer_cloak_transparency = 0,
	ttt_deadringer_cloak_targetid = 0,

	ttt_deadringer_damage_reduction = 0.65,
	ttt_deadringer_damage_reduction_time = 3,
	ttt_deadringer_damage_reduction_initial = 0.75,
	ttt_deadringer_damage_threshold = 2,

	ttt_deadringer_corpse_mode = 0,
	ttt_deadringer_corpse_confirm = 0,

	ttt_deadringer_hud_persist = 0,
	ttt_deadringer_hud_classic = 0,

	ttt_deadringer_sound_cloak = 0,
	ttt_deadringer_sound_cloak_local = 0,
	ttt_deadringer_sound_uncloak = 1,
	ttt_deadringer_sound_uncloak_local = 0,
	ttt_deadringer_sound_recharge = 1,
	ttt_deadringer_sound_recharge_local = 1,
	ttt_deadringer_sound_activate = 1,
	ttt_deadringer_sound_activate_local = 1,
	ttt_deadringer_sound_deactivate = 1,
	ttt_deadringer_sound_deactivate_local = 1
}

hook.Add('PopulateToolMenu', 'DeadringerPopulateToolMenu', function()
	spawnmenu.AddToolMenuOption('Utilities', 'Dead Ringer', 'dead_ringer', 'Settings', '', '', function(panel)
		panel:Help('Dead Ringer Settings')

		panel:ToolPresets('ttt_deadringer_presets', DEADRINGER_DEFAULTS)

		panel:Help('General Settings')

		panel:NumSlider('Charge Time', 'ttt_deadringer_cloak_cooldown', 1, 60, 0)
		panel:ControlHelp('Time it takes to recharge the Dead Ringer.')

		panel:Help('Cloak Settings')

		panel:NumSlider('Cloak Time', 'ttt_deadringer_cloak_duration', 1, 60, 0)
		panel:ControlHelp('Time that the Dead Ringer will cloak you for.')

		panel:CheckBox('Cloak Time Reuse', 'ttt_deadringer_cloak_reuse')
		panel:ControlHelp('Whether or not the Dead Ringer will convert unused cloak time into charge time.')

		panel:NumSlider('Cloak Transparency', 'ttt_deadringer_cloak_transparency', 0, 1, 2)
		panel:ControlHelp('Transparency of the Dead Ringer cloak. (0.0 = invisible, 1.0 = visible)')

		panel:CheckBox('Cloak Target ID', 'ttt_deadringer_cloak_targetid')
		panel:ControlHelp('Whether or not the Dead Ringer will show the target ID while cloaked.')

		panel:Help('Damage Reduction Settings')

		panel:NumSlider('Damage Threshold', 'ttt_deadringer_damage_threshold', 0, 100, 0)
		panel:ControlHelp('The threshold is a flat value, not a percentage')

		panel:NumSlider('Damage Reduction', 'ttt_deadringer_damage_reduction', 0, 1, 2)
		panel:ControlHelp('Damage reduction while cloaked.')

		panel:NumSlider('Damage Reduction Time', 'ttt_deadringer_damage_reduction_time', 0, 60, 2)
		panel:ControlHelp('Damage reduction time while cloaked. (1.0 = 1 second of damage reduction)')

		panel:NumSlider('Damage Reduction Initial', 'ttt_deadringer_damage_reduction_initial', 0, 1, 2)
		panel:ControlHelp('Percentage of damage reduction for the initial hit which triggers the Dead Ringer. (0.75 = 75%)')

		panel:Help('Corpse Settings')

		panel:NumSlider('Role Mode', 'ttt_deadringer_corpse_mode', 0, 2, 0)
		panel:ControlHelp('Whether or not the Dead Ringer will show the real role of the player on the corpse. (0 = fake, 1 = real, 2 = innocent)')

		panel:CheckBox('Confirm Death', 'ttt_deadringer_corpse_confirm')
		panel:ControlHelp('Whether or not the Dead Ringer will confirm the death of the player on the corpse. (Not recommended for TTT2)')

		panel:Help('HUD Settings')

		panel:CheckBox('Persist HUD', 'ttt_deadringer_hud_persist')
		panel:ControlHelp('Whether or not the Dead Ringer HUD will persist even while it is not activated.')

		panel:CheckBox('Classic HUD', 'ttt_deadringer_hud_classic')
		panel:ControlHelp('Whether or not the Dead Ringer HUD will use the classic style. (TTT2 only)')

		panel:Help('Sound Settings')

		panel:CheckBox('Cloak Sound', 'ttt_deadringer_sound_cloak')
		panel:ControlHelp('Whether or not the Dead Ringer will play a sound when cloaking.')

		panel:CheckBox('Cloak Sound Local', 'ttt_deadringer_sound_cloak_local')
		panel:ControlHelp('Where or not the cloaking sound is played locally only.')

		panel:CheckBox('Uncloak Sound', 'ttt_deadringer_sound_uncloak')
		panel:ControlHelp('Whether or not the Dead Ringer will play a sound when uncloaking.')

		panel:CheckBox('Uncloak Sound Local', 'ttt_deadringer_sound_uncloak_local')
		panel:ControlHelp('Where or not the uncloaking sound is played locally only.')

		panel:CheckBox('Recharge Sound', 'ttt_deadringer_sound_recharge')
		panel:ControlHelp('Whether or not the Dead Ringer will play a sound when recharged.')

		panel:CheckBox('Recharge Sound Local', 'ttt_deadringer_sound_recharge_local')
		panel:ControlHelp('Where or not the recharging sound is played locally only.')

		panel:CheckBox('Activate Sound', 'ttt_deadringer_sound_activate')
		panel:ControlHelp('Whether or not the Dead Ringer will play a sound when activated.')

		panel:CheckBox('Activate Sound Local', 'ttt_deadringer_sound_activate_local')
		panel:ControlHelp('Where or not the activating sound is played locally only.')

		panel:CheckBox('Deactivate Sound', 'ttt_deadringer_sound_deactivate')
		panel:ControlHelp('Whether or not the Dead Ringer will play a sound when deactivated.')

		panel:CheckBox('Deactivate Sound Local', 'ttt_deadringer_sound_deactivate_local')
		panel:ControlHelp('Where or not the deactivating sound is played locally only.')
	end)
end)
