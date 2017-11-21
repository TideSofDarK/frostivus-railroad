modifier_out_of_game = class({})

function modifier_out_of_game:DeclareFunctions()
    local funcs = {
        --MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
    }

    return funcs
end

function modifier_out_of_game:CheckState()
  local state = {
    [MODIFIER_STATE_OUT_OF_GAME] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_ATTACK_IMMUNE] = true,
    [MODIFIER_STATE_NIGHTMARED] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
    [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
  }

  return state
end

function modifier_out_of_game:GetAbsoluteNoDamageMagical()
  return 1
end

function modifier_out_of_game:GetAbsoluteNoDamagePhysical()
  return 1
end

function modifier_out_of_game:GetAbsoluteNoDamagePure()
  return 1
end

function modifier_out_of_game:IsHidden()
    return false--true
end