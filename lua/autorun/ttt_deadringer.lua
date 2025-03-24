AddCSLuaFile()

-- Resource Caching

if SERVER then
	resource.AddFile( 'sound/ttt/recharged.wav' )
	resource.AddFile( 'sound/ttt/spy_uncloak_feigndeath.wav' )

	resource.AddFile( 'models/ttt/w_models/w_pocket_watch.mdl' )
	resource.AddFile( 'models/ttt/v_models/v_watch_pocket_spy.mdl' )
	resource.AddFile( 'models/ttt/c_models/c_pocket_watch.mdl' )

	resource.AddFile( 'materials/vgui/ttt/gradient_red.vtf' )
	resource.AddFile( 'materials/vgui/ttt/icon_deadringer.vmt' )
	resource.AddFile( 'materials/vgui/ttt/icon_deadringer.vtf' )
	resource.AddFile( 'materials/vgui/ttt/misc_ammo_area_mask.vtf' )
	resource.AddFile( 'materials/vgui/ttt/misc_ammo_area_red.vmt' )
	resource.AddFile( 'materials/vgui/ttt/weapon_dead_ringer.vmt' )
	resource.AddFile( 'materials/vgui/ttt/weapon_dead_ringer.vtf' )

	resource.AddFile( 'materials/models/weapons/c_items/c_pocket_watch.vmt' )
	resource.AddFile( 'materials/models/weapons/c_items/c_pocket_watch.vtf' )
	resource.AddFile( 'materials/models/weapons/c_items/c_pocket_watch_lightwarp.vtf' )
	resource.AddFile( 'materials/models/weapons/c_items/c_pocket_watch_phongwarp.vtf' )

	resource.AddFile( 'materials/models/ttt/c_pocket_watch/c_pocket_watch.vmt' )
	resource.AddFile( 'materials/models/ttt/c_pocket_watch/c_pocket_watch.vtf' )

	resource.AddFile( 'materials/models/player/spy/spy_exponent.vtf' )
	resource.AddFile( 'materials/models/player/spy/spy_hands_blue.vmt' )
	resource.AddFile( 'materials/models/player/spy/spy_hands_blue.vtf' )
	resource.AddFile( 'materials/models/player/spy/spy_hands_normal.vtf' )
	resource.AddFile( 'materials/models/player/spy/spy_hands_red.vmt' )
	resource.AddFile( 'materials/models/player/spy/spy_hands_red.vtf' )

	resource.AddFile( 'materials/models/player/pyro/pyro_lightwarp.vtf' )

	resource.AddFile( 'materials/vgui/ttt/hud_icon_deadringer.png' )
end

-- ConVars

local flags = {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}

CreateConVar('ttt_deadringer_cloak_cooldown', '20', flags, 'Time it takes to recharge the Dead Ringer.')
CreateConVar('ttt_deadringer_cloak_duration', '7', flags, 'Time that the Dead Ringer will cloak you for.')
CreateConVar('ttt_deadringer_cloak_reuse', '0', flags, 'Whether or not the Dead Ringer will convert unused cloak time into charge time.')
CreateConVar('ttt_deadringer_cloak_transparency', '0.0', flags, 'Transparency of the Dead Ringer cloak. (0.0 = invisible, 1.0 = visible)')
CreateConVar('ttt_deadringer_cloak_targetid', '0', flags, 'Whether or not the Dead Ringer will show the target ID while cloaked.')
CreateConVar('ttt_deadringer_cloak_reactivate', '0', flags, 'Whether or not the Dead Ringer will automatically reactivate after recharging.')
CreateConVar('ttt_deadringer_cloak_attack', '1', flags, 'Whether or not the Dead Ringer will allow you to attack while cloaked.')

CreateConVar('ttt_deadringer_damage_threshold', '2', flags, 'Threshold to trigger the Dead Ringer. The threshold is a flat value, not a percentage')
CreateConVar('ttt_deadringer_damage_reduction', '0.65', flags, 'Damage reduction while cloaked.')
CreateConVar('ttt_deadringer_damage_reduction_time', '3', flags, 'Damage reduction time while cloaked. (1.0 = 1 second of damage reduction)')
CreateConVar('ttt_deadringer_damage_reduction_initial', '0.75', flags, 'Percentage of damage reduction for the initial hit which triggers the Dead Ringer. (0.75 = 75%)')

CreateConVar('ttt_deadringer_corpse_mode', '0', flags, 'Whether or not the Dead Ringer will show the real role of the player on the corpse. (0 = fake, 1 = real, 2 = innocent)')
CreateConVar('ttt_deadringer_corpse_confirm', '0', flags, 'Whether or not the Dead Ringer will confirm the death of the player on the corpse. (Not recommended for TTT2)')

CreateConVar('ttt_deadringer_hud_persist', '0', flags, 'Whether or not the Dead Ringer HUD will persist even while it is not activated.')
CreateConVar('ttt_deadringer_hud_classic', '0', flags, 'Whether or not the Dead Ringer HUD will use the classic style. (TTT2 only)')

CreateConVar('ttt_deadringer_sound_cloak', '0', flags, 'Whether or not the Dead Ringer will play a sound when cloaking.')
CreateConVar('ttt_deadringer_sound_cloak_local', '0', flags, ' Where or not the cloaking sound is played locally only.')
CreateConVar('ttt_deadringer_sound_uncloak', '1', flags, 'Whether or not the Dead Ringer will play a sound when uncloaking.')
CreateConVar('ttt_deadringer_sound_uncloak_local', '0', flags, 'Where or not the uncloaking sound is played locally only.')
CreateConVar('ttt_deadringer_sound_recharge', '1', flags, 'Whether or not the Dead Ringer will play a sound when recharged.')
CreateConVar('ttt_deadringer_sound_recharge_local', '1', flags, 'Where or not the recharging sound is played locally only.')
CreateConVar('ttt_deadringer_sound_activate', '1', flags, 'Whether or not the Dead Ringer will play a sound when activated.')
CreateConVar('ttt_deadringer_sound_activate_local', '1', flags, 'Where or not the activating sound is played locally only.')
CreateConVar('ttt_deadringer_sound_deactivate', '1', flags, 'Whether or not the Dead Ringer will play a sound when deactivated.')
CreateConVar('ttt_deadringer_sound_deactivate_local', '1', flags, 'Where or not the deactivating sound is played locally only.')

hook.Add('Initialize', 'DeadringerInitialize', function()
	-- TTT2 Compatibility

	if CLIENT and TTT2 and STATUS then
		STATUS:RegisterStatus('deadringer_cloaked', {
			hud = Material('vgui/ttt/hud_icon_deadringer.png'),
			type = 'default'
		})

		STATUS:RegisterStatus('deadringer_ready', {
			hud = Material('vgui/ttt/hud_icon_deadringer.png'),
			type = 'good',
			DrawInfo = function()
				local status = LocalPlayer():GetNWInt('DRStatus', 0)

				return status == 1 and 'on' or 'off'
			end
		})

		STATUS:RegisterStatus('deadringer_cooldown', {
			hud = Material('vgui/ttt/hud_icon_deadringer.png'),
			type = 'bad'
		})
		return
	end
end)
