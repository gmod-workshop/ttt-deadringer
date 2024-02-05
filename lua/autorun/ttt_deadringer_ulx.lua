AddCSLuaFile()

hook.Add('Initialize', 'DR.Initialize.Ulx', function()
    -- TTT ULX Compatibility
    if CLIENT and not TTT2 then
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

            local chargeTime = xlib.makeslider{label = 'Cloak Cooldown (def. 10)', repconvar = 'rep_ttt_deadringer_cloak_cooldown', min = 1, max = 60, decimal = 0, parent = basicList}
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

            local cloakTime = xlib.makeslider{label = 'Cloak Duration (def. 6)', repconvar = 'rep_ttt_deadringer_cloak_duration', min = 1, max = 60, decimal = 0, parent = basicList}
            cloakList:AddItem(cloakTime)

            local cloakTimeReuse = xlib.makecheckbox{label = 'Cloak Time Reuse (def. 1)', repconvar = 'rep_ttt_deadringer_cloak_reuse', parent = cloakList}
            cloakList:AddItem(cloakTimeReuse)

            local cloakTransparency = xlib.makeslider{label = 'Cloak Transparency (def. 0)', repconvar = 'rep_ttt_deadringer_cloak_transparency', min = 0, max = 1, decimal = 2, parent = cloakList}
            cloakList:AddItem(cloakTransparency)

            local cloakTargetid = xlib.makecheckbox{label = 'Cloak TargetID (def. 1)', repconvar = 'rep_ttt_deadringer_cloak_targetid', parent = cloakList}
            cloakList:AddItem(cloakTargetid)

            -- Damage Reduction Settings
            local damageCategory = vgui.Create('DCollapsibleCategory', root)
            damageCategory:SetSize(390, 50)
            damageCategory:SetExpanded(1)
            damageCategory:SetLabel('Damage Reduction Settings')

            local damageList = vgui.Create('DPanelList', damageCategory)
            damageList:SetPos(5, 25)
            damageList:SetSize(390, 150)
            damageList:SetSpacing(5)

            -- The threshold is a flat value, not a percentage
            local damageThreshold = xlib.makeslider{label = 'Damage Threshold (def. 2)', repconvar = 'rep_ttt_deadringer_damage_threshold', min = 0, max = 100, decimal = 0, parent = damageList}
            damageList:AddItem(damageThreshold)

            local damageReduction = xlib.makeslider{label = 'Damage Reduction (def. 0.65)', repconvar = 'rep_ttt_deadringer_damage_reduction', min = 0, max = 1, decimal = 2, parent = damageList}
            damageList:AddItem(damageReduction)

            local damageReductionTime = xlib.makeslider{label = 'Damage Reduction Time (def. 3)', repconvar = 'rep_ttt_deadringer_damage_reduction_time', min = 0, max = 60, decimal = 1, parent = damageList}
            damageList:AddItem(damageReductionTime)

            local damageReductionInitial = xlib.makeslider{label = 'Damage Reduction Initial (def. 0.75)', repconvar = 'rep_ttt_deadringer_damage_reduction_initial', min = 0, max = 1, decimal = 2, parent = damageList}
            damageList:AddItem(damageReductionInitial)

            -- Corpse Settings
            local corpseCategory = vgui.Create('DCollapsibleCategory', root)
            corpseCategory:SetSize(390, 50)
            corpseCategory:SetExpanded(1)
            corpseCategory:SetLabel('Corpse Settings')

            local corpseList = vgui.Create('DPanelList', corpseCategory)
            corpseList:SetPos(5, 25)
            corpseList:SetSize(390, 150)
            corpseList:SetSpacing(5)

            local corpseRole = xlib.makeslider{label = 'Corpse Mode (def. 0)', repconvar = 'rep_ttt_deadringer_corpse_mode', min = 0, max = 2, decimal = 0, parent = corpseList}
            corpseList:AddItem(corpseRole)

            local corpseConfirm = xlib.makecheckbox{label = 'Corpse Confirm (def. 0)', repconvar = 'rep_ttt_deadringer_corpse_confirm', parent = corpseList}
            corpseList:AddItem(corpseConfirm)

            xgui.hookEvent('onProcessModules', nil, root.processModules)
            xgui.addSubModule('Dead Ringer', root, nil, panel)
        end)
    end

    if SERVER and not TTT2 then
        hook.Add('TTTUlxInitCustomCVar', 'DeadringerTTTUlxInitCustomCVar', function(name)
            ULib.replicatedWritableCvar('ttt_deadringer_cloak_cooldown', 'rep_ttt_deadringer_cloak_cooldown', GetConVar('ttt_deadringer_cloak_cooldown'):GetFloat(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_cloak_duration', 'rep_ttt_deadringer_cloak_duration', GetConVar('ttt_deadringer_cloak_duration'):GetFloat(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_cloak_reuse', 'rep_ttt_deadringer_cloak_reuse', GetConVar('ttt_deadringer_cloak_reuse'):GetBool(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_cloak_transparency', 'rep_ttt_deadringer_cloak_transparency', GetConVar('ttt_deadringer_cloak_transparency'):GetFloat(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_cloak_targetid', 'rep_ttt_deadringer_cloak_targetid', GetConVar('ttt_deadringer_cloak_targetid'):GetBool(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_damage_threshold', 'rep_ttt_deadringer_damage_threshold', GetConVar('ttt_deadringer_damage_threshold'):GetFloat(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_damage_reduction', 'rep_ttt_deadringer_damage_reduction', GetConVar('ttt_deadringer_damage_reduction'):GetFloat(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_damage_reduction_time', 'rep_ttt_deadringer_damage_reduction_time', GetConVar('ttt_deadringer_damage_reduction_time'):GetFloat(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_damage_reduction_initial', 'rep_ttt_deadringer_damage_reduction_initial', GetConVar('ttt_deadringer_damage_reduction_initial'):GetFloat(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_corpse_mode', 'rep_ttt_deadringer_corpse_mode', GetConVar('ttt_deadringer_corpse_mode'):GetInt(), true, false, name)
            ULib.replicatedWritableCvar('ttt_deadringer_corpse_confirm', 'rep_ttt_deadringer_corpse_confirm', GetConVar('ttt_deadringer_corpse_confirm'):GetBool(), true, false, name)
        end)
    end
end)