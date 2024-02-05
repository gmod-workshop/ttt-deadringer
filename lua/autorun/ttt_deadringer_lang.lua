AddCSLuaFile()

if CLIENT then
	hook.Add('InitPostEntity', 'DR.InitPostEntity.English', function()
		if LANG == nil or TTT2 then return end

		LANG.AddToLanguage('english', 'deadringer_name', 'Dead Ringer')
		LANG.AddToLanguage('english', 'deadringer_desc', 'A watch that feigns your death when you take damage. You will be cloaked for a short time and your attacker will be fooled.')

		LANG.AddToLanguage('english', 'deadringer_primary', 'Activate')
		LANG.AddToLanguage('english', 'deadringer_secondary', 'Deactivate')
	end)
end
