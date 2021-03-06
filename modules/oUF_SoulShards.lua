if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local parent, ns = ...
local oUF = ns.oUF or oUF



local SPELL_POWER_SOUL_SHARDS     = Enum.PowerType.SoulShards


local Update = function(self, event, unit, powerType)
  local bar = self.SoulShardPowerBar
  local mod = UnitPowerDisplayMod(7)
  local cur_unmod = UnitPower("player", 7, true)
  local max_unmod = UnitPowerMax("player", 7, true)
  local cur = UnitPower("player", 7)
  local max = UnitPowerMax("player", 7)
  --adjust the width of the soulshard power frame
  local w = 64*(max+1)
  bar:SetWidth(w)
  for i = 1, bar.maxOrbs do
    local orb = self.SoulShards[i]
    if i > max then
       if orb:IsShown() then orb:Hide() end
    else
      if not orb:IsShown() then orb:Show() end
    end
  end
	for i = 1, bar.maxOrbs do
		local orb = self.SoulShards[i]
		local orb2 = self.SoulShards[i+1]
		local full = cur/max
		if(i <= cur) then
			if full == 1 then
				orb.fill:SetVertexColor(1,0,0)
				orb.glow:SetVertexColor(1,0,0)
			else
				orb.fill:SetVertexColor(bar.color.r,bar.color.g,bar.color.b)
				orb.glow:SetVertexColor(bar.color.r,bar.color.g,bar.color.b)
			end
			orb.fill:Show()
			orb.glow:Show()
			orb.highlight:Show()
		else
			orb.fill:Hide()
			orb.glow:Hide()
			orb.highlight:Hide()
		end
		if(i > cur) then
			if cur_unmod/mod > cur then
				orb.fill:SetVertexColor(0,1,0)
				orb.glow:SetVertexColor(0,1,0)
				orb.fill:Show()
				orb.glow:Show()
				orb.highlight:Show()
			end
		end
	end
end

local Visibility = function(self, event, unit)
  local element = self.SoulShards
  local bar = self.SoulShardPowerBar
  if UnitHasVehicleUI("player")
    or ((HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "")
    or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= ""))
  then
    bar:Hide()
  elseif(select(2, UnitClass("player")) == "WARLOCK") then
    bar:Show()
    element.ForceUpdate(element)
  else
    bar:Hide()
  end
end

local Path = function(self, ...)
  return (self.SoulShards.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
  return Path(element.__owner, "ForceUpdate", element.__owner.unit, "SOUL_SHARDS")
end

local function Enable(self, unit)
  local element = self.SoulShards
  if(element and unit == "player") then
    element.__owner = self
    element.ForceUpdate = ForceUpdate

    self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
    self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
    self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility, true)
    self:RegisterEvent("SPELLS_CHANGED", Visibility, true)
    self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", Visibility, true)
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
    self:RegisterEvent("UNIT_EXITED_VEHICLE", Visibility)

    local helper = CreateFrame("Frame") --this is needed...adding player_login to the visivility events does not do anything
    helper:RegisterEvent("PLAYER_LOGIN")
    helper:SetScript("OnEvent", function() Visibility(self) end)

    return true
  end
end

local function Disable(self)
  local element = self.SoulShards
  if(element) then
    self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
    self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
    self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
    self:UnregisterEvent("SPELLS_CHANGED", Visibility)
    self:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR", Visibility)
    self:UnregisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
    self:UnregisterEvent("UNIT_EXITED_VEHICLE", Visibility)
  end
end

oUF:AddElement("SoulShards", Path, Enable, Disable)
