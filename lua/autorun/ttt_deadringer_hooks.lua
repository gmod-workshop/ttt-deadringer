AddCSLuaFile()

hook.Add('Initialize', 'DR.Initialize.Hooks', function()
    if SERVER and TTT2 then
        hook.Add('TTT2ConfirmPlayer', 'DR.TTT2ConfirmPlayer', function(victim, ply, ragdoll)
            if not IsValid(ply) or not IsValid(ragdoll) then return end
            if not ragdoll.deadringer_ragdoll then return end

            if ragdoll.was_role == roles.GetByName('fake').index then
                return false
            end
        end)

        hook.Add('TTTBodyFound', 'DR.TTTBodyFound', function(ply, victim, ragdoll)
            -- We have to manually confirm the body if the ragdoll is a Dead Ringer ragdoll
            -- because TTT2 checks if the victim is alive and cloaked player is still alive

            if not IsValid(ply) or not IsValid(victim) or not IsValid(ragdoll) then return end
            if not ragdoll.deadringer_ragdoll then return end

            local corpseConfirm = GetConVar('ttt_deadringer_corpse_confirm'):GetBool()
            if not corpseConfirm or ply:TTT2NETGetBool('body_found', false) then return end

            victim:ConfirmPlayer(true)
        end)
    end

    hook.Add('TTTScoreGroup', 'DR.TTTScoreGroup', function(ply)
        if not IsValid(ply) then return end

        if ply:GetNWBool('DRCloaked', false) then
            if TTT2 then
                return ply:TTT2NETGetBool('body_found', false) and GROUP_FOUND or nil
            end

            return ply:GetNWBool('body_found', false) and GROUP_FOUND or nil
        end
    end)

    hook.Add('TTTPrepareRound', 'DR.TTTPrepareRound', function()
        for k, v in ipairs(player.GetAll()) do
            if SERVER then
                v:SetNWBool('DRCloaked', false)
                v:SetNWInt('DRRole', -1)
            end

            if CLIENT then
                v.NoTarget = Either(v.DRNoTarget == -1, nil, v.DRNoTarget == 1)
            end
        end
    end)

    if TTT2 then
        hook.Add('TTTScoreboardRowColorForPlayer', 'DR.TTTScoreboardRowColorForPlayer', function(ply)
            if not IsValid(ply) then return end

            if ply:GetNWBool('DRCloaked', false) and ply:TTT2NETGetBool('body_found', false) then
                local role = ply:GetNWInt('DRRole', -1)
                if role == -1 then return end

                local roleData = roles.GetByIndex(role)
                if not roleData then return end

                return roleData.color
            end
        end)
    else
        hook.Add('TTTScoreboardColorForPlayer', 'DR.TTTScoreboardColorForPlayer', function(ply)
            if not IsValid(ply) then return end

            if ply:GetNWBool('DRCloaked', false) and ply:GetNWBool('body_found') then
                local role = ply:GetNWInt('DRRole', -1)
                if role == -1 then return end

                if role == ROLE_INNOCENT then
                    return Color(0, 0, 0, 0)
                elseif role == ROLE_TRAITOR then
                    return Color(255, 0, 0, 30)
                elseif role == ROLE_DETECTIVE then
                    return Color(0, 0, 255, 30)
                elseif ConVarExists('ttt_vote') then
                    local roleData = GetRoleTableByID(role).DefaultColor

                    return Color(roleData.r, roleData.g, roleData.b, 70)
                end
            end
        end)
    end
end)
