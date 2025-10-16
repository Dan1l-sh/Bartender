--[[
	Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local MicroMenuMod = Bartender4:NewModule("MicroMenu", "AceHook-3.0")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

-- create prototype information
local MicroMenuBar = setmetatable({}, {__index = ButtonBar})

local table_insert = table.insert

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	vertical = false,
	visibility = {
		possess = false,
	},
	padding = -3,
	position = {
		scale = 0.8,
	},
}, Bartender4.ButtonBar.defaults) }

function MicroMenuMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("MicroMenu", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function MicroMenuMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.ButtonBar:Create("MicroMenu", self.db.profile, L["Micro Menu"]), {__index = MicroMenuBar})
		local buttons = {}
		local order = {
		"CharacterMicroButton",
		"SpellbookMicroButton",
		"TalentMicroButton",
		"AchievementMicroButton",
		"QuestLogMicroButton",
		"SocialsMicroButton",
		"PVPMicroButton",
		"LFDMicroButton",
		"EncounterJournalMicroButton",
		"StoreMicroButton",
		"MainMenuMicroButton"
		}
		for _, name in ipairs(order) do
		local b = _G[name]
		if b then table_insert(buttons, b) end
		end
		self.bar.buttons = buttons

		MicroMenuMod.button_count = #buttons

		self:SecureHook("UpdateMicroButtons")

		if MoveMicroButtons then
			self:SecureHook("MoveMicroButtons", "RestoreButtons")
		end
		if VehicleMenuBar_MoveMicroButtons then
			self:SecureHook("VehicleMenuBar_MoveMicroButtons", "RestoreButtons")
		end
		if UIParent_ManageFramePositions then
			self:SecureHook("UIParent_ManageFramePositions", "RestoreButtons")
		end

		for i,v in pairs(buttons) do
			v:SetParent(self.bar)
			v:Show()
			v:SetFrameLevel(self.bar:GetFrameLevel() + 1)
			v.ClearSetPoint = self.bar.ClearSetPoint
		end
	end
	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()

	self:RestoreButtons()
	if C_Timer and C_Timer.After then
		C_Timer.After(0,   function() MicroMenuMod:RestoreButtons() end)
		C_Timer.After(0.5, function() MicroMenuMod:RestoreButtons() end)
	end
end

function MicroMenuMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function MicroMenuMod:RestoreButtons()
	if not self:IsEnabled() then return end
	for k,v in pairs(self.bar.buttons) do
		v:SetParent(self.bar)
		v:Show()
	end
	self.bar:UpdateButtonLayout()
end

function MicroMenuMod:UpdateMicroButtons()
	if MainMenuBar.state == "player" then
		self:RestoreButtons()
	end
end

MicroMenuBar.button_width = 28
MicroMenuBar.button_height = 58
MicroMenuBar.vpad_offset = -21
function MicroMenuBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("CENTER", -105, 30)
		self:SavePosition()
	end

	self:UpdateButtonLayout()
end
