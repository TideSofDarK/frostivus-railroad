function Spawn( keys )
    local caster = thisEntity

    Timers:CreateTimer(function ()
        caster:SetMaterialGroup(tostring(caster:GetKeyValue("MaterialGroup")))
        AddAnimationTranslate(caster, "level_3")
        Wearables:InitDefaultWearables(caster)
    end)
end