if SERVER then
    AddCSLuaFile()

    resource.AddFile('materials/vgui/ttt/dynamic/roles/icon_fake.vmt')
end

roles.InitCustomTeam(ROLE.name, {
    icon = 'vgui/ttt/dynamic/roles/icon_fake',
    color = Color(102, 102, 102, 255)
})

function ROLE:PreInitialize()
    self.color = Color(102, 102, 102)

    self.abbr = 'fake'
    self.unknownTeam = true

    self.defaultTeam = TEAM_FAKE
    self.notSelectable = true

    self.conVarData = {
        pct = 0,
        maximum = 0,
        minPlayers = 0,
        toggleable = false,
        traitorButton = 0,
        random = 100
    }
end
