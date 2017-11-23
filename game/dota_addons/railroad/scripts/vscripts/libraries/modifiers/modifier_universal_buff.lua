modifier_universal_buff = class({})

function modifier_universal_buff:DeclareFunctions()
  local funcs = {
    --MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }

  return funcs
end


function modifier_universal_buff:GetModifierSpellAmplify_Percentage()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).spellamplify
end

function modifier_universal_buff:GetModifierMagicalResistanceBonus()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).magicres
end

function modifier_universal_buff:GetModifierExtraHealthBonus()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).health
end

function modifier_universal_buff:GetModifierConstantHealthRegen()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).healthregen
end

function modifier_universal_buff:GetModifierPercentageManacost()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).manacost
end

function modifier_universal_buff:GetModifierConstantManaRegen()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).mpregen
end

function modifier_universal_buff:GetModifierPreAttack_BonusDamage()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).damage
end

function modifier_universal_buff:GetModifierPhysicalArmorBonus()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).armour
end

function modifier_universal_buff:GetModifierCooldownReduction_Constant()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).cdr
end

function modifier_universal_buff:GetModifierAttackSpeedBonus_Constant()
  return CustomNetTables:GetTableValue("universal_buff", tostring(self:GetParent():GetPlayerOwnerID())).attackspeed
end

function modifier_universal_buff:IsHidden()
  return false
end
