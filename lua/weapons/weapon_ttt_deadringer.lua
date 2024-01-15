AddCSLuaFile()

if engine.ActiveGamemode() ~= 'terrortown' then
    SWEP.PrintName = 'Dead Ringer'

    SWEP.Author = 'NECROSSIN (Niandra Lades, Porter, Gamefreak, dhkatz)'
    SWEP.Purpose = 'Fake your death!'
    SWEP.Instructions = 'Left click to activate, right click to deactivate.'

    SWEP.Category = 'Team Fortress 2'
    SWEP.Spawnable = true
    SWEP.AdminOnly = false

    SWEP.Base = 'weapon_base'

    SWEP.Slot = 4
    SWEP.SlotPos = 1

    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
    SWEP.Weight = 1
else
    SWEP.PrintName = 'deadringer_name'

    SWEP.Base = 'weapon_tttbase'

    SWEP.Slot = 6
    SWEP.Icon = 'vgui/ttt/icon_deadringer'

    SWEP.EquipMenuData = {
        type = 'item_weapon',
        name = 'deadringer_name',
        desc = 'deadringer_desc'
    }

    SWEP.Kind = WEAPON_EQUIP2
    SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
    SWEP.LimitedStock = true

    SWEP.AllowDrop = true
    SWEP.NoSights = true
end

SWEP.FiresUnderwater = true

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

if CLIENT then
    SWEP.BounceWeaponIcon = false
    SWEP.WepSelectIcon = surface.GetTextureID('models/ttt/c_pocket_watch.vtf')
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'AR2AltFire'
SWEP.Primary.Delay = 0.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

SWEP.HoldType = 'slam'

SWEP.ViewModel = 'models/ttt/v_models/v_watch_pocket_spy.mdl'
SWEP.WorldModel = 'models/ttt/w_models/w_pocket_watch.mdl'

SWEP.UncloakSound = Sound('ttt/spy_uncloak_feigndeath.wav')

local CLOAK = {
    NONE = 0,
    READY = 1,
    DISABLED = 2,
    CLOAKED = 3,
    UNCLOAKED = 4
}

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    self:SetupHooks()

    self.FirstDeploy = true

    self.CVarChargeTime = GetConVar('ttt_deadringer_chargetime')
    self.CVarCloakTime = GetConVar('ttt_deadringer_cloaktime')
    self.CVarDamageReduction = GetConVar('ttt_deadringer_damage_reduction')
    self.CVarDamageReductionTime = GetConVar('ttt_deadringer_damage_reduction_time')
    self.CVarDamageReductionInitial = GetConVar('ttt_deadringer_damage_reduction_initial')
    self.CVarCloakTimeReuse = GetConVar('ttt_deadringer_cloaktime_reuse')
end

function SWEP:SetupHooks()
    if SERVER then
        hook.Add('EntityTakeDamage', self, self.EntityTakeDamage)
        hook.Add('KeyPress', self, self.KeyPress)
    end

    hook.Add('PlayerFootstep', self, self.PlayerFootstep)

    hook.Add('Think', self, function(wep)
        -- Run weapon think when we are not active weapon
        if not IsValid(wep) then return end
        local owner = wep:GetOwner()
        if not IsValid(owner) then return end
        if owner:GetActiveWeapon() == wep then return end

        wep:Think()
    end)

    if CLIENT and not TTT2 then
        hook.Add('HUDPaint', self, function(wep)
            -- Run weapon HUDPaint when we are not active weapon
            if not IsValid(wep) then return end
            local owner = wep:GetOwner()
            if not IsValid(owner) then return end
            if owner:GetActiveWeapon() == wep then return end

            wep:DrawHUD()
        end)
    end
end

function SWEP:RemoveHooks()
    if SERVER then
        hook.Remove('EntityTakeDamage', self)
        hook.Remove('KeyPress', self)
    end

    hook.Remove('PlayerFootstep', self)
    hook.Remove('Think', self)

    if CLIENT and not TTT2 then
        hook.Remove('HUDPaint', self)
    end
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local status = owner:GetNW2Int('DRStatus')
    if not owner:GetNW2Bool('DRCloaked', false) and status ~= CLOAK.READY and status ~= CLOAK.UNCLOAKED then
        owner:SetNW2Int('DRStatus', CLOAK.READY)
        if not self:IsCharged() then
            owner:SetNW2Int('DRStatus', CLOAK.UNCLOAKED)
        end

        if (CLIENT and self:IsCarriedByLocalPlayer()) or game.SinglePlayer() then
            owner:EmitSound('buttons/blip1.wav', 100, 100, 1, CHAN_AUTO)
        end
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local status = owner:GetNW2Int('DRStatus')
    if not owner:GetNW2Bool('DRCloaked', false) and status == CLOAK.READY then
        owner:SetNW2Int('DRStatus', CLOAK.DISABLED)
        if (CLIENT and self:IsCarriedByLocalPlayer()) or game.SinglePlayer() then
            owner:EmitSound('buttons/blip1.wav', 100, 73, 1, CHAN_AUTO)
        end
    end
end

function SWEP:EntityTakeDamage(target, dmginfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    if target ~= self:GetOwner() then return end

    if not target:HasWeapon('weapon_ttt_deadringer') then return end -- This should never happen, but just in case.

    local cloaked = target:GetNW2Bool('DRCloaked', false)
    local status = target:GetNW2Int('DRStatus', CLOAK.NONE)

    if not cloaked and status == CLOAK.READY then
        if dmginfo:GetDamage() >= 2 and dmginfo:GetDamage() < target:Health() then
            self:Cloak(target, dmginfo)

            local damageReductionInitial = self.CVarDamageReductionInitial:GetFloat()
            if damageReductionInitial > 0 then
                dmginfo:ScaleDamage(1 - damageReductionInitial)
            else
                return true
            end
        elseif target:IsOnFire() then
            target:Extinguish()
            self:Cloak(target, dmginfo)
        end
    end

    if cloaked then
        local damageReductionTime = target:GetNW2Float('DRDamageReductionTime', 0)
        if damageReductionTime > CurTime() then
            local damageReduction = self.CVarDamageReduction:GetFloat()
            if damageReduction > 0 then
                dmginfo:ScaleDamage(1 - damageReduction)
            else
                return true
            end
        end
    end
end

function SWEP:PlayerFootstep(ply)
    if ply ~= self:GetOwner() then return end

    if ply:Alive() and ply:GetNW2Bool('DRCloaked', false) and ply:GetNW2Int('DRStatus') == CLOAK.CLOAKED then
        return true
    end
end

function SWEP:KeyPress(ply, key)
    if CLIENT then return end
    if not IsValid(ply) then return end
    if ply ~= self:GetOwner() then return end
    if not ply:GetNW2Bool('DRCloaked', false) then return end

    if ply:GetNW2Int('DRStatus', CLOAK.NONE) == CLOAK.CLOAKED and key == IN_ATTACK2 then
        self:Uncloak(ply)
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local cloaked = owner:GetNW2Bool('DRCloaked', false)
    local status = owner:GetNW2Int('DRStatus', CLOAK.NONE)
    local chargeTime = owner:GetNW2Float('DRChargeTime', 1 / 0)

    if not cloaked then
        if status == CLOAK.UNCLOAKED and chargeTime < CurTime() then
            if SERVER then
                owner:SetNW2Int('DRStatus', CLOAK.DISABLED)

                if TTT2 then
                    STATUS:AddStatus(owner, 'deadringer_ready')
                end
            elseif self:IsCarriedByLocalPlayer() then
                surface.PlaySound('ttt/recharged.wav')
            end
        end
    else
        if status == CLOAK.CLOAKED and chargeTime < CurTime() then
            self:Uncloak(owner)
        end
    end
end

function SWEP:Deploy()
    if self.FirstDeploy then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        if SERVER then
            owner:SetNW2Int('DRStatus', CLOAK.NONE)
            owner:SetNW2Bool('DRCloaked', false)
            owner:SetNW2Float('DRChargeTime', 0)

            if TTT2 then
                STATUS:AddStatus(owner, 'deadringer_ready')
            end
        end

        self.FirstDeploy = false
    end

    self:SendWeaponAnim(ACT_VM_DRAW)
    return true
end

function SWEP:Equip()
    self:SetupHooks()
end

function SWEP:OnDrop()
    self.FirstDeploy = true
    self:RemoveHooks()
end

function SWEP:PreDrop()
    if TTT2 then
        local owner = self:GetOwner()
        STATUS:RemoveStatus(owner, 'deadringer_ready')
        STATUS:RemoveStatus(owner, 'deadringer_cloaked')
        STATUS:RemoveStatus(owner, 'deadringer_cooldown')
    end
end

function SWEP:OnRemove()
    self:RemoveHooks()

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER then
        if owner:GetNW2Bool('DRCloaked', false) then
            self:Uncloak(owner)
        end

        owner:SetNW2Int('DRStatus', CLOAK.NONE)
        owner:SetNW2Bool('DRCloaked', false)
        owner:SetNW2Float('DRChargeTime', 0)

        if TTT2 then
            STATUS:RemoveStatus(owner, 'deadringer_ready')
            STATUS:RemoveStatus(owner, 'deadringer_cloaked')
            STATUS:RemoveStatus(owner, 'deadringer_cooldown')
        end
    end
end

function SWEP:Cloak(ply, dmginfo)
    if CLIENT then return end

    net.Start('DR.Cloak')
    net.WriteBool(true)
    net.Send(ply)

    ply:SetNW2Bool('DRCloaked', true)
    ply:SetNW2Int('DRStatus', CLOAK.CLOAKED)
    ply:SetNW2Float('DRChargeTime', CurTime() + self.CVarCloakTime:GetInt())
    ply:SetNW2Float('DRDamageReductionTime', CurTime() + self.CVarDamageReductionTime:GetFloat())

    ply:SetBloodColor(DONT_BLEED)
    ply:DrawShadow(false)
    ply:Flashlight(false)
    ply:AllowFlashlight(false)
    ply:SetFOV(0, 0.2)
    ply:SetNoDraw(true)

    local weapon = ply:GetActiveWeapon()
    if weapons.IsBasedOn(weapon:GetClass(), 'weapon_tttbase') then
        weapon:SetIronsights(false)
    end

    self:SpawnRagdoll(ply, dmginfo)
    self:CloakWeapons(ply, true)
end

function SWEP:IsCharged()
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end

    if owner:GetNW2Bool('DRCloaked', false) then
        return false
    end

    return owner:GetNW2Int('DRStatus', CLOAK.NONE) == CLOAK.READY
end

function SWEP:Uncloak(ply)
    if CLIENT then return end

    net.Start('DR.Cloak')
    net.WriteBool(false)
    net.Send(ply)

    ply:SetNW2Bool('DRCloaked', false)
    ply:SetNW2Int('DRStatus', CLOAK.UNCLOAKED)

    local timeRemaining = 0
    if self.CVarCloakTimeReuse:GetBool() then
        timeRemaining = ply:GetNW2Float('DRChargeTime', 0) - CurTime()
        timeRemaining = math.Clamp(timeRemaining, 0, self.CVarChargeTime:GetInt())
    end

    local chargeTime = math.max(self.CVarChargeTime:GetInt() - timeRemaining, 0)
    ply:SetNW2Float('DRChargeTime', CurTime() + chargeTime)

    if TTT2 then
        STATUS:RemoveStatus(ply, 'deadringer_ready')
        STATUS:AddTimedStatus(ply, 'deadringer_cooldown', chargeTime, true)
    end

    ply:SetBloodColor(BLOOD_COLOR_RED)
    ply:DrawShadow(true)
    ply:AllowFlashlight(true)
    ply:SetNoDraw(false)
    ply:DrawWorldModel(true)

    ply:EmitSound(self.UncloakSound, 100, 100, 1, CHAN_AUTO)

    -- Reset the body_found status of the player so they appear alive again.
    if engine.ActiveGamemode() == 'terrortown' then
        DamageLog('Dead Ringer: ' .. ply:Nick() .. ' has uncloaked.')

        if TTT2 then
            ply:TTT2NETSetBool('body_found', false)
            STATUS:RemoveStatus(ply, 'deadringer_cloaked')
        else
            ply:SetNWBool('body_found', false)
        end
    end

    local effectdata = EffectData()
    effectdata:SetOrigin(ply:GetPos())
    util.Effect('env_cloak', effectdata, true, true)

    for _, ent in ipairs(ents.FindByClass('prop_ragdoll')) do
        if ent.deadringer_ragdoll and ent.sid == ply:SteamID() then
            ent:Remove()
        end
    end

    self:CloakWeapons(ply, false)
end

function SWEP:SpawnRagdoll(ply, dmginfo)
    local ragdoll
    if engine.ActiveGamemode() == 'terrortown' then
        DamageLog('Dead Ringer: ' .. ply:Nick() .. ' has cloaked after taking ' .. dmginfo:GetDamage() .. ' damage.')

        -- The original addon rewrote CORPSE.Create for some reason... lol
        ragdoll = CORPSE.Create(ply, dmginfo:GetAttacker(), dmginfo)
        if not IsValid(ragdoll) then return end

        ragdoll.was_role = ROLE_INNOCENT
        ragdoll.bomb_wire = false

        CORPSE.SetCredits(ragdoll, 0)

        if TTT2 then
            ragdoll.was_team = TEAM_INNOCENT
            STATUS:RemoveStatus(ply, 'deadringer_ready')
            STATUS:AddTimedStatus(ply, 'deadringer_cloaked', self.CVarCloakTime:GetInt(), true)
        end
    else
        ragdoll = ents.Create('prop_ragdoll')
        ragdoll:SetPos(ply:GetPos())
        ragdoll:SetModel(ply:GetModel())
        ragdoll:SetAngles(ply:GetAngles())
        ragdoll:SetColor(ply:GetColor())
        ragdoll:SetSkin(ply:GetSkin())
        ragdoll:SetOwner(ply)
        ragdoll:Spawn()
        ragdoll:Activate()
        ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        ragdoll.sid = ply:SteamID()
    end

    ragdoll.deadringer_ragdoll = true
end

function SWEP:CloakWeapons(ply, cloaked)
    net.Start('DR.WeaponCloak')
        net.WriteEntity(ply)
        net.WriteBool(cloaked)
    net.Broadcast()
end

function SWEP:DrawHUD()
    if TTT2 then return end -- TTT2 handles this itself through STATUS:AddStatus

    local background = surface.GetTextureID('vgui/ttt/misc_ammo_area_red')
    local w, h = surface.GetTextureSize(background)
    surface.SetTexture(background)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(13, ScrH() - h - 240, w * 5, h * 5)

    local owner = self:GetOwner()
    local cloaked = owner:GetNW2Bool('DRCloaked', false)
    local chargeTime = owner:GetNW2Float('DRChargeTime', 0)
    local divisor = cloaked and self.CVarCloakTime:GetInt() or self.CVarChargeTime:GetInt()
    local charge = (chargeTime - CurTime()) / divisor
    charge = math.Clamp(cloaked and charge or 1 - charge, 0, 1)

    draw.RoundedBox(2, 44, ScrH() - h - 208, charge * 77, 15, color_white)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawOutlinedRect(44, ScrH() - h - 208, 77, 15)

    draw.DrawText('CLOAK', 'DebugFixed', 65, ScrH() - h - 190, color_white)
end

if SERVER then
    util.AddNetworkString('DR.Cloak')
    util.AddNetworkString('DR.WeaponCloak')
else
    net.Receive('DR.Cloak', function()
        local cloak = net.ReadBool()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        if cloak then
            ply:GetViewModel():SetMaterial('models/props_c17/fisheyelens')
        else
            ply:GetViewModel():SetMaterial('models/weapons/v_crowbar.mdl')
        end
    end)

    net.Receive('DR.WeaponCloak', function()
        local ply = net.ReadEntity()
        local cloak = net.ReadBool()

        if not IsValid(ply) then return end

        for _, wep in ipairs(ply:GetWeapons()) do
            if not IsValid(wep) then continue end
            if wep:GetNoDraw() == cloak then continue end

            wep:SetNoDraw(cloak)
        end
    end)
end
