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

local flags = {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}

CreateConVar('ttt_deadringer_chargetime', '20', flags, 'Time it takes to recharge the Dead Ringer.')
CreateConVar('ttt_deadringer_cloaktime', '7', flags, 'Time that the Dead Ringer will cloak you for.')
CreateConVar('ttt_deadringer_damage_reduction', '0.65', flags, 'Damage reduction while cloaked.')
CreateConVar('ttt_deadringer_damage_reduction_time', '3', flags, 'Damage reduction time while cloaked.')
CreateConVar('ttt_deadringer_damage_reduction_initial', '0.75', flags, 'Percentage of damage reduction for the initial hit which triggers the Dead Ringer. (0.75 = 75%)')
CreateConVar('ttt_deadringer_cloaktime_reuse', '0', flags, 'Whether or not the Dead Ringer will convert unused cloak time into charge time.')

-- Sandbox Compatibility

hook.Add('AddToolMenuCategories', 'DeadringerAddToolMenuCategories', function()
	spawnmenu.AddToolCategory('Utilities', 'Dead Ringer', 'Dead Ringer')
end)

local DEADRINGER_DEFAULTS = {
	ttt_deadringer_chargetime = 20,
	ttt_deadringer_cloaktime = 7,
	ttt_deadringer_damage_reduction = 0.65,
	ttt_deadringer_damage_reduction_time = 3,
	ttt_deadringer_damage_reduction_initial = 0.75,
	ttt_deadringer_cloaktime_reuse = 0
}

hook.Add('PopulateToolMenu', 'DeadringerPopulateToolMenu', function()
	spawnmenu.AddToolMenuOption('Utilities', 'Dead Ringer', 'dead_ringer', 'Settings', '', '', function(panel)
		panel:Help('Dead Ringer Settings')

		panel:ToolPresets('ttt_deadringer_presets', DEADRINGER_DEFAULTS)

		panel:Help('General Settings')

		panel:NumSlider('Charge Time', 'ttt_deadringer_chargetime', 1, 60, 0)
		panel:ControlHelp('Time it takes to recharge the Dead Ringer.')

		panel:Help('Cloak Settings')

		panel:NumSlider('Cloak Time', 'ttt_deadringer_cloaktime', 1, 60, 0)
		panel:ControlHelp('Time that the Dead Ringer will cloak you for.')

		panel:CheckBox('Cloak Time Reuse', 'ttt_deadringer_cloaktime_reuse')
		panel:ControlHelp('Whether or not the Dead Ringer will convert unused cloak time into charge time.')

		panel:Help('Damage Reduction Settings')

		panel:NumSlider('Damage Reduction', 'ttt_deadringer_damage_reduction', 0, 60, 2)
		panel:ControlHelp('Damage reduction while cloaked.')

		panel:NumSlider('Damage Reduction Time', 'ttt_deadringer_damage_reduction_time', 0, 1, 2)
		panel:ControlHelp('Percentage of damage reduction time while cloaked. (0.5 = 50%)')

		panel:NumSlider('Damage Reduction Initial', 'ttt_deadringer_damage_reduction_initial', 0, 1, 2)
		panel:ControlHelp('Percentage of damage reduction for the initial hit which triggers the Dead Ringer. (0.75 = 75%)')
	end)
end)

-- TTT/2 Compatibility

if CLIENT then
	hook.Add('InitPostEntity', 'DeadringerInitPostEntity', function()
		if LANG == nil then return end

		local lang = TTT2 and 'en' or 'english'

		LANG.AddToLanguage(lang, 'deadringer_name', 'Dead Ringer')
		LANG.AddToLanguage(lang, 'deadringer_desc', 'A watch that feigns your death when you take damage. You will be cloaked for a short time and your attacker will be fooled.')
	end)
end

-- TTT ULX Compatibility

hook.Add('TTTUlxInitCustomCVar', 'DeadringerTTTUlxInitCustomCVar', function(name)
	ULib.replicatedWritableCvar('ttt_deadringer_chargetime', 'rep_ttt_deadringer_chargetime', GetConVar('ttt_deadringer_chargetime'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_deadringer_cloaktime', 'rep_ttt_deadringer_cloaktime', GetConVar('ttt_deadringer_cloaktime'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_deadringer_damage_reduction', 'rep_ttt_deadringer_damage_reduction', GetConVar('ttt_deadringer_damage_reduction'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_deadringer_damage_reduction_time', 'rep_ttt_deadringer_damage_reduction_time', GetConVar('ttt_deadringer_damage_reduction_time'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_deadringer_damage_reduction_initial', 'rep_ttt_deadringer_damage_reduction_initial', GetConVar('ttt_deadringer_damage_reduction_initial'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_deadringer_cloaktime_reuse', 'rep_ttt_deadringer_cloaktime_reuse', GetConVar('ttt_deadringer_cloaktime_reuse'):GetBool(), true, false, name)
end)

if CLIENT then
	hook.Add('TTTUlxModifyAddonSettings', 'DeadringerTTTUlxModifyAddonSettings', function(panel)
		local root = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

		-- Basic Settings
		local basicCategory = vgui.Create('DCollapsibleCategory', root)
		basicCategory:SetSize(390, 50)
		basicCategory:SetExpanded(1)
		basicCategory:SetLabel('Basic Settings')

		local basicList = vgui.Create('DPanelList', basicCategory)
		basicList:SetPos(5, 25)
		basicList:SetSize(390, 150)
		basicList:SetSpacing(5)

		local chargeTime = xlib.makeslider{label = 'Charge Time (def. 10)', repconvar = 'rep_ttt_deadringer_chargetime', min = 1, max = 60, decimal = 0, parent = basicList}
		basicList:AddItem(chargeTime)

		-- Cloak Settings
		local cloakCategory = vgui.Create('DCollapsibleCategory', root)
		cloakCategory:SetSize(390, 50)
		cloakCategory:SetExpanded(1)
		cloakCategory:SetLabel('Cloak Settings')

		local cloakList = vgui.Create('DPanelList', cloakCategory)
		cloakList:SetPos(5, 25)
		cloakList:SetSize(390, 150)
		cloakList:SetSpacing(5)

		local cloakTime = xlib.makeslider{label = 'Cloak Time (def. 6)', repconvar = 'rep_ttt_deadringer_cloaktime', min = 1, max = 60, decimal = 0, parent = basicList}
		cloakList:AddItem(cloakTime)

		local cloakTimeReuse = xlib.makecheckbox{label = 'Cloak Time Reuse (def. 1)', repconvar = 'rep_ttt_deadringer_cloaktime_reuse', parent = cloakList}
		cloakList:AddItem(cloakTimeReuse)

		-- Damage Reduction Settings
		local damageCategory = vgui.Create('DCollapsibleCategory', root)
		damageCategory:SetSize(390, 50)
		damageCategory:SetExpanded(1)
		damageCategory:SetLabel('Damage Reduction Settings')

		local damageList = vgui.Create('DPanelList', damageCategory)
		damageList:SetPos(5, 25)
		damageList:SetSize(390, 150)
		damageList:SetSpacing(5)

		local damageReduction = xlib.makeslider{label = 'Damage Reduction (def. 0.65)', repconvar = 'rep_ttt_deadringer_damage_reduction', min = 0, max = 1, decimal = 2, parent = damageList}
		damageList:AddItem(damageReduction)

		local damageReductionTime = xlib.makeslider{label = 'Damage Reduction Time (def. 0.5)', repconvar = 'rep_ttt_deadringer_damage_reduction_time', min = 0, max = 60, decimal = 2, parent = damageList}
		damageList:AddItem(damageReductionTime)

		local damageReductionInitial = xlib.makeslider{label = 'Damage Reduction Initial (def. 0.75)', repconvar = 'rep_ttt_deadringer_damage_reduction_initial', min = 0, max = 1, decimal = 2, parent = damageList}
		damageList:AddItem(damageReductionInitial)

		xgui.hookEvent('onProcessModules', nil, root.processModules)
		xgui.addSubModule('Dead Ringer', root, nil, panel)
	end)
end

-- TTT2 Compatibility

if CLIENT then
	hook.Add('Initialize', 'DeadringerInitialize', function()
		if not TTT2 or STATUS == nil then return end

		STATUS:RegisterStatus('deadringer_cloaked', {
			hud = Material('vgui/ttt/hud_icon_deadringer.png'),
			type = 'default'
		})

		STATUS:RegisterStatus('deadringer_ready', {
			hud = Material('vgui/ttt/hud_icon_deadringer.png'),
			type = 'good',
			DrawInfo = function()
				local status = LocalPlayer():GetNW2Int('DRStatus', 0)

				return status == 1 and 'READY' or 'INACTIVE'
			end
		})

		STATUS:RegisterStatus('deadringer_cooldown', {
			hud = Material('vgui/ttt/hud_icon_deadringer.png'),
			type = 'bad'
		})
	end)
end
