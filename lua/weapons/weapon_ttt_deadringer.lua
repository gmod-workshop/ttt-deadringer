AddCSLuaFile()

DEFINE_BASECLASS(engine.ActiveGamemode() == 'terrortown' and 'weapon_tttbase' or 'weapon_base')

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
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'none'
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

    self.CVarChargeTime = GetConVar('ttt_deadringer_cloak_cooldown')
    self.CVarCloakTime = GetConVar('ttt_deadringer_cloak_duration')
    self.CVarCloakTimeReuse = GetConVar('ttt_deadringer_cloak_reuse')
    self.CVarCloakTransparency = GetConVar('ttt_deadringer_cloak_transparency')
    self.CVarCloakTargetid = GetConVar('ttt_deadringer_cloak_targetid')
    self.CVarCloakReactivate = GetConVar('ttt_deadringer_cloak_reactivate')

    self.CVarDamageThreshold = GetConVar('ttt_deadringer_damage_threshold')
    self.CVarDamageReduction = GetConVar('ttt_deadringer_damage_reduction')
    self.CVarDamageReductionTime = GetConVar('ttt_deadringer_damage_reduction_time')
    self.CVarDamageReductionInitial = GetConVar('ttt_deadringer_damage_reduction_initial')

    self.CVarCorpseMode = GetConVar('ttt_deadringer_corpse_mode')

    self.CVarHudPersist = GetConVar('ttt_deadringer_hud_persist')
    self.CVarHudClassic = GetConVar('ttt_deadringer_hud_classic')

    self.CVarSoundRecharge = GetConVar('ttt_deadringer_sound_recharge')
    self.CVarSoundRechargeLocal = GetConVar('ttt_deadringer_sound_recharge_local')
    self.CVarSoundUncloak = GetConVar('ttt_deadringer_sound_uncloak')
    self.CVarSoundUncloakLocal = GetConVar('ttt_deadringer_sound_uncloak_local')
    self.CVarSoundActivate = GetConVar('ttt_deadringer_sound_activate')
    self.CVarSoundActivateLocal = GetConVar('ttt_deadringer_sound_activate_local')
    self.CVarSoundDeactivate = GetConVar('ttt_deadringer_sound_deactivate')
    self.CVarSoundDeactivateLocal = GetConVar('ttt_deadringer_sound_deactivate_local')

    if CLIENT and engine.ActiveGamemode() == 'terrortown' then
        if TTT2 then
            self:AddTTT2HUDHelp('deadringer_primary', 'deadringer_secondary')
        else
            self:AddHUDHelp('deadringer_primary', 'deadringer_secondary', true)
        end
    end

    BaseClass.Initialize(self)
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
        if (SERVER or game.IsDedicated()) and owner:GetActiveWeapon() == wep then return end
        if CLIENT and owner == LocalPlayer() and not game.IsDedicated() then return end

        wep:Think()
    end)

    if CLIENT then
        hook.Add('HUDPaint', self, function(wep)
            -- Run weapon HUDPaint when we are not active weapon
            if not IsValid(wep) then return end
            local owner = wep:GetOwner()
            if not IsValid(owner) then return end
            if owner ~= LocalPlayer() then return end
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
    local status = self:GetStatus()
    if not self:GetCloaked() and status ~= CLOAK.READY and status ~= CLOAK.UNCLOAKED then
        self:SetStatus(not self:IsCharged() and CLOAK.UNCLOAKED or CLOAK.READY)
        if self.CVarSoundActivate:GetBool() then
            self:PlaySound('deadringer_activate', self.CVarSoundActivateLocal:GetBool() and self:GetOwner() or nil)
        end
    end
end

function SWEP:SecondaryAttack()
    local status = self:GetStatus()
    if not self:GetCloaked() and status == CLOAK.READY then
        self:SetStatus(CLOAK.DISABLED)
        if self.CVarSoundDeactivate:GetBool() then
            self:PlaySound('deadringer_deactivate', self.CVarSoundDeactivateLocal:GetBool() and self:GetOwner() or nil)
        end
    end
end

function SWEP:EntityTakeDamage(target, dmginfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    if target ~= self:GetOwner() then return end

    if not target:HasWeapon('weapon_ttt_deadringer') then return end -- This should never happen, but just in case.

    local cloaked = self:GetCloaked()
    local status = self:GetStatus()
    local threshold = self.CVarDamageThreshold:GetInt()

    if not cloaked and status == CLOAK.READY then
        if dmginfo:GetDamage() >= threshold and dmginfo:GetDamage() < target:Health() then
            self:Cloak(target, dmginfo)

            local damageReductionInitial = self.CVarDamageReductionInitial:GetFloat()
            if damageReductionInitial > 0 then
                dmginfo:ScaleDamage(1 - damageReductionInitial)
            else
                return true
            end
        elseif target:IsOnFire() then
            self:Cloak(target, dmginfo)
            target:Extinguish()
        end
    end

    if cloaked then
        local damageReductionTime = target:GetNWFloat('DRDamageReductionTime', 0)
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

    if ply:Alive() and self:GetCloaked() and self:GetStatus() == CLOAK.CLOAKED then
        return true
    end
end

function SWEP:KeyPress(ply, key)
    if CLIENT then return end
    if not IsValid(ply) then return end
    if ply ~= self:GetOwner() then return end
    if not ply:GetNWBool('DRCloaked', false) then return end

    if self:GetStatus() == CLOAK.CLOAKED and key == IN_ATTACK2 then
        self:Uncloak(ply)
    end
end

function SWEP:SetStatus(status)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local oldStatus = owner:GetNWInt('DRStatus', CLOAK.NONE)
    owner:SetNWInt('DRStatus', status)

    hook.Run('DeadRingerStatusChanged', self, owner, oldStatus, status)
end

function SWEP:GetStatus()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    return owner:GetNWInt('DRStatus', CLOAK.NONE)
end

function SWEP:SetCloaked(cloaked)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:SetNWBool('DRCloaked', cloaked)
end

function SWEP:GetCloaked()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    return owner:GetNWBool('DRCloaked', false)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local cloaked = self:GetCloaked()
    local status = self:GetStatus()
    local chargeTime = owner:GetNWFloat('DRChargeTime', 1 / 0)

    if CLIENT and owner.DRNoTarget == nil then
        owner.DRNoTarget = Either(owner.NoTarget == nil, -1, owner.NoTarget and 1 or 0)
    end

    if not cloaked then
        if status == CLOAK.UNCLOAKED and chargeTime < CurTime() then
            if SERVER then
                if self.CVarCloakReactivate:GetBool() then
                    self:SetStatus(CLOAK.READY)
                else
                    self:SetStatus(CLOAK.DISABLED)
                end

                if TTT2 and not self.CVarHudClassic:GetBool() then
                    STATUS:AddStatus(owner, 'deadringer_ready')
                end
            end

            if self.CVarSoundRecharge:GetBool() then
                self:PlaySound('ttt/recharged.wav', self.CVarSoundRechargeLocal:GetBool() and owner or nil)
            end
        end

        if CLIENT then
            if owner.NoTarget and owner.DRNoTarget < 1 then
                owner.NoTarget = Either(owner.DRNoTarget == -1, nil, false)
            end

            for _, wep in ipairs(owner:GetWeapons()) do
                if IsValid(wep) then
                    if wep.DRNoDraw == nil then
                        wep.DRNoDraw = wep:GetNoDraw()
                    end

                    if wep:GetNoDraw() and not wep.DRNoDraw then
                        wep:SetNoDraw(false)
                    end
                end
            end
        end
    else
        if status == CLOAK.CLOAKED then
            if CLIENT then
                if not self.CVarCloakTargetid:GetBool() and owner.NoTarget ~= true then
                    owner.NoTarget = true
                end

                for _, wep in ipairs(owner:GetWeapons()) do
                    if IsValid(wep) then
                        if wep.DRNoDraw == nil then
                            wep.DRNoDraw = wep:GetNoDraw()
                        end

                        if not wep:GetNoDraw() then
                            wep:SetNoDraw(true)
                        end
                    end
                end
            end

            if chargeTime < CurTime() then
                self:Uncloak(owner)
             end
        end
    end

    if SERVER and TTT2 and self.CVarHudClassic:GetBool() then
        STATUS:RemoveStatus(owner, 'deadringer_ready')
        STATUS:RemoveStatus(owner, 'deadringer_cloaked')
        STATUS:RemoveStatus(owner, 'deadringer_cooldown')
    end
end

function SWEP:PlaySound(sound, filter)
    if CLIENT then return end

    if not IsFirstTimePredicted() then return end

    if filter ~= nil then
        net.Start('DR.Sound')
            net.WriteEntity(self)
            net.WriteString(sound)
        net.Send(filter)
    else
        net.Start('DR.Sound')
            net.WriteEntity(self)
            net.WriteString(sound)
        net.Broadcast()
    end
end

function SWEP:Deploy()
    if self.FirstDeploy then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        if SERVER then
            self:SetStatus(CLOAK.NONE)
            self:SetCloaked(false)
            owner:SetNWInt('DRRole', -1)
            owner:SetNWFloat('DRChargeTime', 0)

            if TTT2 and not self.CVarHudClassic:GetBool() then
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
        if self:GetCloaked() then
            self:Uncloak(owner)
        end

        self:SetStatus(CLOAK.NONE)
        self:SetCloaked(false)
        owner:SetNWInt('DRRole', -1)
        owner:SetNWFloat('DRChargeTime', 0)

        if TTT2 then
            STATUS:RemoveStatus(owner, 'deadringer_ready')
            STATUS:RemoveStatus(owner, 'deadringer_cloaked')
            STATUS:RemoveStatus(owner, 'deadringer_cooldown')
        end
    end
end

function SWEP:Cloak(ply, dmginfo)
    if CLIENT then return end

    local result = hook.Run('DeadRingerPreCloak', self, ply, dmginfo)
    if result == false then return end

    net.Start('DR.Cloak')
        net.WriteBool(true)
    net.Send(ply)

    self:SetCloaked(true)
    self:SetStatus(CLOAK.CLOAKED)
    ply:SetNWFloat('DRChargeTime', CurTime() + self.CVarCloakTime:GetInt())
    ply:SetNWFloat('DRDamageReductionTime', CurTime() + self.CVarDamageReductionTime:GetFloat())

    ply:SetBloodColor(DONT_BLEED)
    ply:DrawShadow(false)
    ply:Flashlight(false)
    ply:AllowFlashlight(false)
    ply:DrawWorldModel(false)

    local transparency = self.CVarCloakTransparency:GetFloat()

    ply.DRColor = ply:GetColor()
    ply:SetColor(Color(255, 255, 255, 255 * transparency))
    ply.DRRenderMode = ply:GetRenderMode()
    ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ply.DRMaterial = ply:GetMaterial()
    ply:SetMaterial('sprites/heatwave')

    local weapon = ply:GetActiveWeapon()
    if weapons.IsBasedOn(weapon:GetClass(), 'weapon_tttbase') then
        weapon:SetIronsights(false)
    end

    local ragdoll = self:SpawnRagdoll(ply, dmginfo)
    ply:SetNWInt('DRRole', ragdoll.was_role or -1)

    hook.Run('DeadRingerCloak', self, ply, dmginfo, ragdoll)
end

function SWEP:IsCharged()
    if self:GetCloaked() then
        return false
    end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    return owner:GetNWFloat('DRChargeTime', 0) < CurTime()
end

function SWEP:Uncloak(ply)
    if CLIENT then return end

    local result = hook.Run('DeadRingerPreUncloak', self, ply)
    if result == false then return end

    net.Start('DR.Cloak')
        net.WriteBool(false)
    net.Send(ply)

    self:SetCloaked(false)
    self:SetStatus(CLOAK.UNCLOAKED)
    ply:SetNWInt('DRRole', -1)

    local timeRemaining = 0
    if self.CVarCloakTimeReuse:GetBool() then
        timeRemaining = ply:GetNWFloat('DRChargeTime', 0) - CurTime()
        timeRemaining = math.Clamp(timeRemaining, 0, self.CVarChargeTime:GetInt())
    end

    local chargeTime = math.max(self.CVarChargeTime:GetInt() - timeRemaining, 0)
    ply:SetNWFloat('DRChargeTime', CurTime() + chargeTime)

    if TTT2 then
        STATUS:RemoveStatus(ply, 'deadringer_ready')
        if not self.CVarHudClassic:GetBool() then
            STATUS:AddTimedStatus(ply, 'deadringer_cooldown', chargeTime, true)
        end
    end

    ply:SetBloodColor(BLOOD_COLOR_RED)
    ply:DrawShadow(true)
    ply:AllowFlashlight(true)
    ply:DrawWorldModel(true)

    ply:SetColor(ply.DRColor)
    ply:SetRenderMode(ply.DRRenderMode or RENDERMODE_NORMAL)
    ply:SetMaterial(ply.DRMaterial or '')

    if self.CVarSoundUncloak:GetBool() then
        self:PlaySound(self.UncloakSound, self.CVarSoundUncloakLocal:GetBool() and ply or nil)
    end

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

    hook.Run('DeadRingerUncloak', self, ply)
end

function SWEP:SpawnRagdoll(ply, dmginfo)
    if CLIENT then return end

    local ragdoll
    if engine.ActiveGamemode() == 'terrortown' then
        DamageLog('Dead Ringer: ' .. ply:Nick() .. ' has cloaked after taking ' .. dmginfo:GetDamage() .. ' damage.')

        -- The original addon rewrote CORPSE.Create for some reason... lol
        ragdoll = CORPSE.Create(ply, dmginfo:GetAttacker(), dmginfo)
        if not IsValid(ragdoll) then return end

        local role = self:ChooseRole(ply)
        ragdoll.was_role = role
        ragdoll.bomb_wire = false

        CORPSE.SetCredits(ragdoll, 0)

        if TTT2 then
            local roleData = roles.GetByIndex(role)
            ragdoll.was_team = roleData.defaultTeam
            ragdoll.role_color = roleData.color
            STATUS:RemoveStatus(ply, 'deadringer_ready')
            if not self.CVarHudClassic:GetBool() then
                STATUS:AddTimedStatus(ply, 'deadringer_cloaked', self.CVarCloakTime:GetInt(), true)
            end
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

    return ragdoll
end

function SWEP:ChooseRole(ply)
    if engine.ActiveGamemode() ~= 'terrortown' then
        error('This function is only available in TTT based gamemodes.')
    end

    if not IsValid(ply) then return end

    local corpseMode = self.CVarCorpseMode:GetInt()

    if not TTT2 then
        if ply:IsTraitor() then
            if corpseMode == 0 then
                return ROLE_NONE
            elseif corpseMode == 1 then
                return ply:GetRole()
            end

            return ROLE_INNOCENT
        end

        return ply:GetRole()
    end

    if ply:RoleKnown() then
        return ply:GetSubRole()
    end

    local roleData = ply:GetSubRoleData()
    if roleData.isPublicRole then
        return roleData.index
    end

    if corpseMode == 0 then
        return roles.GetByName('fake').index
    elseif corpseMode == 1 then
        return roleData.index
    end

    return roles.GetByName('innocent').index
end

function SWEP:DrawHUD()
    if TTT2 and not self.CVarHudClassic:GetBool() then
        BaseClass.DrawHUD(self)
        return
    end

    local status = self:GetStatus()
    if not self.CVarHudPersist:GetBool() and status ~= CLOAK.READY and status ~= CLOAK.UNCLOAKED and status ~= CLOAK.CLOAKED then return end

    local background = surface.GetTextureID('vgui/ttt/misc_ammo_area_red')
    local w, h = surface.GetTextureSize(background)
    surface.SetTexture(background)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(13, ScrH() - h - 240, w * 5, h * 5)

    local owner = self:GetOwner()
    local cloaked = self:GetCloaked()
    local chargeTime = owner:GetNWFloat('DRChargeTime', 0)
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
    util.AddNetworkString('DR.Sound')
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

    net.Receive('DR.Sound', function()
        local wep = net.ReadEntity()
        local sound = net.ReadString()
        if not IsValid(wep) then return end

        wep:EmitSound(sound, 100, 100, 1, CHAN_WEAPON)
    end)
end

if CLIENT and TTT2 then
    function SWEP:AddToSettingsMenu(parent)
        local form = vgui.CreateTTT2Form(parent, 'header_equipment_additional')

        form:MakeHelp({
            label = 'help_deadringer_cloak_cooldown'
        })

        form:MakeSlider({
            label = 'label_deadringer_cloak_cooldown',
            serverConvar = 'ttt_deadringer_cloak_cooldown',
            min = 1,
            max = 60,
            decimal = 0,
        })

        form:MakeHelp({
            label = 'help_deadringer_cloak_duration'
        })

        form:MakeSlider({
            label = 'label_deadringer_cloak_duration',
            serverConvar = 'ttt_deadringer_cloak_duration',
            min = 1,
            max = 60,
            decimal = 0,
        })

        form:MakeHelp({
            label = 'help_deadringer_cloak_transparency'
        })

        form:MakeSlider({
            label = 'label_deadringer_cloak_transparency',
            serverConvar = 'ttt_deadringer_cloak_transparency',
            min = 0,
            max = 1,
            decimal = 2,
        })

        form:MakeHelp({
            label = 'help_deadringer_cloak_targetid'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_cloak_targetid',
            serverConvar = 'ttt_deadringer_cloak_targetid'
        })

        form:MakeHelp({
            label = 'help_deadringer_damage_reduction'
        })

        form:MakeSlider({
            label = 'label_deadringer_damage_reduction',
            serverConvar = 'ttt_deadringer_damage_reduction',
            min = 0,
            max = 1,
            decimal = 2,
        })

        form:MakeHelp({
            label = 'help_deadringer_damage_reduction_time'
        })

        form:MakeSlider({
            label = 'label_deadringer_damage_reduction_time',
            serverConvar = 'ttt_deadringer_damage_reduction_time',
            min = 0,
            max = 60,
            decimal = 1,
        })

        form:MakeHelp({
            label = 'help_deadringer_damage_reduction_initial'
        })

        form:MakeSlider({
            label = 'label_deadringer_damage_reduction_initial',
            serverConvar = 'ttt_deadringer_damage_reduction_initial',
            min = 0,
            max = 1,
            decimal = 2,
        })

        form:MakeHelp({
            label = 'help_deadringer_cloak_reuse'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_cloak_reuse',
            serverConvar = 'ttt_deadringer_cloak_reuse'
        })

        form:MakeHelp({
            label = 'help_deadringer_corpse_mode'
        })

        form:MakeSlider({
            label = 'label_deadringer_corpse_mode',
            serverConvar = 'ttt_deadringer_corpse_mode',
            min = 0,
            max = 2,
            decimal = 0,
        })

        form:MakeHelp({
            label = 'help_deadringer_corpse_confirm'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_corpse_confirm',
            serverConvar = 'ttt_deadringer_corpse_confirm'
        })

        form:MakeHelp({
            label = 'help_deadringer_hud_persist'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_hud_persist',
            serverConvar = 'ttt_deadringer_hud_persist'
        })

        form:MakeHelp({
            label = 'help_deadringer_hud_classic'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_hud_classic',
            serverConvar = 'ttt_deadringer_hud_classic'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_cloak'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_cloak',
            serverConvar = 'ttt_deadringer_sound_cloak'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_cloak_local'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_cloak_local',
            serverConvar = 'ttt_deadringer_sound_cloak_local'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_uncloak'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_uncloak',
            serverConvar = 'ttt_deadringer_sound_uncloak'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_uncloak_local'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_uncloak_local',
            serverConvar = 'ttt_deadringer_sound_uncloak_local'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_recharge'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_recharge',
            serverConvar = 'ttt_deadringer_sound_recharge'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_recharge_local'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_recharge_local',
            serverConvar = 'ttt_deadringer_sound_recharge_local'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_activate'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_activate',
            serverConvar = 'ttt_deadringer_sound_activate'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_activate_local'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_activate_local',
            serverConvar = 'ttt_deadringer_sound_activate_local'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_deactivate'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_deactivate',
            serverConvar = 'ttt_deadringer_sound_deactivate'
        })

        form:MakeHelp({
            label = 'help_deadringer_sound_deactivate_local'
        })

        form:MakeCheckBox({
            label = 'label_deadringer_sound_deactivate_local',
            serverConvar = 'ttt_deadringer_sound_deactivate_local'
        })
    end
end