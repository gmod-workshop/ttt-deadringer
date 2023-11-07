function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Angles = data:GetAngles()

    local normal = self.Angles:Up()
    local pos = self.Position + normal * 6

    local emitter = ParticleEmitter(pos)

    for i = 1, math.random(15, 25) do
        local particle = emitter:Add('particles/smokey', pos + normal * math.random(0, 100))
        particle:SetVelocity(VectorRand(-30, 30))
        particle:SetDieTime(math.Rand(2.5, 5))
        particle:SetStartAlpha(150)
        particle:SetStartSize(math.random(15, 40))
        particle:SetEndSize(math.random(40, 55))
        particle:SetRoll(math.Rand(360, 480))
        particle:SetRollDelta(math.Rand(-1, 1))
        particle:SetColor(255, 255, 255)
    end

    emitter:Finish()
end

function EFFECT:Think()
    return true
end

function EFFECT:Render()
end
