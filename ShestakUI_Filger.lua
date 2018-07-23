﻿local _, ns = ...
local Misc = ns.Misc
--	Misc.back = Misc.Media.."back"
	Misc.border = Misc.Media.."White"
	Misc.barbg = Misc.Media.."Texture"
local LibAura = LibStub:GetLibrary("LibAuraUtil-1.0")

local class = select(2, UnitClass("player"))
local ClassColor = RAID_CLASS_COLORS[class]

local colorTable = {
	["DK"]		= {r = .77, g = .12, b = .23},	-- DeathKnight	196,31,59
	["DH"]		= {r = .09, g = .95, b = .14},	-- DemonHunter	23,242,36
	["DLY"]		= {r = 1, g = 0.49, b = .04},	-- Druid		255,125,10
	["LR"]		= {r = .58, g = .86, b = .49},	-- Hunter		148,219,125 {0.67, 0.83, 0.45}171,212,115
	["FS"]		= {r = 0, g = .76, b = 1},		-- Mage			0,193,255 {0.41, 0.8, 0.94}105,204,240
	["WS"]		= {r = 0, g = 1, b = .59},		-- Monk			0,255,150 {0.0, 0.98 , 0.58}0,250,148
	["QS"]		= {r = 1, g = .22, b = .52},	-- Paladin		255,56,133 {0.96, 0.55, 0.73}245,140,186
	["MS"]		= {r = .8, g = .87, b = .9},	-- Priest		204,222,230 1 1 1
	["DZ"]		= {r = 1, g = .91, b = .2},	-- Rogue		255,232,51 {1.0, 0.96, 0.41}255,245,105
	["SM"]		= {r = 0, g = .44, b = .87},	-- Shaman		0,112,222
	["SS"]		= {r = .6, g = .47, b = .85},	-- Warlock		153,120,217 {0.58, 0.51, 0.79}148,130,201
	["ZS"]		= {r = .9, g = .65, b = .45},	-- Warrior		230,166,115 {0.78, 0.61, 0.43}199,156,110
	["Black"]	= {r = 0, g = 0, b = 0},
	["Gray"]	= {r = .37, g = .3, b = .3},	--				94,77,77
	["OWN"]		= ClassColor,
}

local function SetTemplate(Parent, Size)
	local F = CreateFrame("Frame", nil, Parent)
	F:SetFrameLevel(3)
	F:SetPoint("TOPLEFT", -Size * Misc.mult, Size * Misc.mult)
	F:SetPoint("BOTTOMRIGHT", Size * Misc.mult, -Size * Misc.mult)
	F:SetBackdrop({
	--	bgFile = Misc.back, 
		edgeFile = Misc.border, 
	--	insets = {left = 0 * Misc.mult, right = 0 * Misc.mult, top = 0 * Misc.mult, bottom = 0 * Misc.mult},
	--	tile = false, tileSize = 0, 
		edgeSize = 1 * Misc.mult,
	})
	--F:SetBackdropColor(backcolor.r, backcolor.g, backcolor.b, .5)
	F:SetBackdropBorderColor(colorTable[Misc.modeborder].r, colorTable[Misc.modeborder].g, colorTable[Misc.modeborder].b, 1)

	return F
end

----------------------------------------------------------------------------------------
--	Filger(by Nils Ruesch, editors Affli/SinaC/Ildyria)
----------------------------------------------------------------------------------------
SpellActivationOverlayFrame:SetFrameStrata("BACKGROUND")
local Filger = {}
local MyUnits = {player = true, vehicle = true, pet = true}

function Filger:UnitBuff(unitID, inSpellID, spn, absID)
	if absID then
		for i = 1, 40, 1 do
			local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitBuff(unitID, i)
			if not name then break end
			if inSpellID == spellID then
				return name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID
			end
		end
	else
		return LibAura.UnitBuff(spn,unitID)
	end
	return nil
end

function Filger:UnitDebuff(unitID, inSpellID, spn, absID)
	if absID then
		for i = 1, 40, 1 do
			local name,  icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitDebuff(unitID, i)
			if not name then break end
			if inSpellID == spellID then
				return name,  icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID
			end
		end
	else
		return LibAura.UnitDebuff(spn,unitID)
	end
	return nil
end

function Filger:UpdateCD()
	local time = self.value.start + self.value.duration - GetTime()

	if self:GetParent().Mode == "BAR" then
		self.statusbar:SetValue(time)
		if time <= 60 then
			self.time:SetFormattedText("%.1f", time)
		else
			self.time:SetFormattedText("%d:%.2d", time / 60, time % 60)
		end
	else
		if time < 0 then
			local frame = self:GetParent()
			frame.actives[self.activeIndex] = nil
			self:SetScript("OnUpdate", nil)
			Filger.DisplayActives(frame)
		end
	end
end

function Filger:DisplayActives()
	if not self.actives then return end
	if not self.bars then self.bars = {} end
	local id = self.Id
	local index = 1
	local previous = nil

	for _, _ in pairs(self.actives) do
		local bar = self.bars[index]
		if not bar then
			bar = CreateFrame("Frame", "FilgerAnchor"..id.."Frame"..index, self)
			bar:SetScale(1)
			SetTemplate(bar, 0)

			if index == 1 then
				bar:SetAllPoints(self.movebar)
				--bar:SetPoint(unpack(self.Position))
			----- Next line ----
			elseif self.NumPerLine and index % self.NumPerLine == 1 then
				previous = self.bars[index - self.NumPerLine]
				if self.Direction == "RIGHT" or self.Direction == "LEFT" then
					bar:SetPoint("TOP", previous, "BOTTOM", 0, -self.Interval)
				else
					bar:SetPoint("LEFT", previous, "RIGHT", self.Interval, 0)
				end
			-------------------
			else
				if self.Direction == "UP" then
					bar:SetPoint("BOTTOM", previous, "TOP", 0, self.Interval)
				elseif self.Direction == "RIGHT" then
					bar:SetPoint("LEFT", previous, "RIGHT", self.Mode == "ICON" and self.Interval or (self.BarWidth + self.Interval + 7), 0)
				elseif self.Direction == "LEFT" then
					bar:SetPoint("RIGHT", previous, "LEFT", self.Mode == "ICON" and -self.Interval or -(self.BarWidth + self.Interval + 7), 0)
				else
					bar:SetPoint("TOP", previous, "BOTTOM", 0, -self.Interval)
				end
			end

			if bar.icon then
				bar.icon = _G[bar.icon:GetName()]
			else
				bar.icon = bar:CreateTexture("$parentIcon", "BORDER")
				bar.icon:SetPoint("TOPLEFT", 1 * Misc.mult, -1 * Misc.mult)
				bar.icon:SetPoint("BOTTOMRIGHT", -1 * Misc.mult, 1 * Misc.mult)
				bar.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			end

			if self.Mode == "ICON" then
				if bar.cooldown then
					bar.cooldown = _G[bar.cooldown:GetName()]
				else
					bar.cooldown = CreateFrame("Cooldown", "$parentCD", bar, "CooldownFrameTemplate")
					bar.cooldown:SetAllPoints(bar.icon)
					bar.cooldown:SetReverse(true) -- 反转
					bar.cooldown:SetFrameLevel(2)
				end

				if bar.count then
					bar.count = _G[bar.count:GetName()]
				else
					bar.count = bar:CreateFontString("$parentCount", "OVERLAY")
					bar.count:SetFont(Misc.font, Misc.numsize, "OUTLINE")
					bar.count:SetShadowOffset(1 * Misc.mult, -1 * Misc.mult)
					bar.count:SetPoint("TOPRIGHT", 1, 0)
					bar.count:SetJustifyH("RIGHT")
				end
			else
				if bar.statusbar then
					bar.statusbar = _G[bar.statusbar:GetName()]
				else
					bar.statusbar = CreateFrame("StatusBar", "$parentStatusBar", bar)
					bar.statusbar:SetWidth(self.BarWidth * Misc.mult)
					bar.statusbar:SetHeight(7 * Misc.mult)
					bar.statusbar:SetStatusBarTexture(Misc.barfg)			-- bar_FG
					bar.statusbar:SetStatusBarColor(colorTable[Misc.modefg].r, colorTable[Misc.modefg].g, colorTable[Misc.modefg].b, 1)
					if self.IconSide == "LEFT" then
						bar.statusbar:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 3 * Misc.mult, 2 * Misc.mult)
					elseif self.IconSide == "RIGHT" then
						bar.statusbar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -3 * Misc.mult, 2 * Misc.mult)
					end
				end
				bar.statusbar:SetMinMaxValues(0, 1)
				bar.statusbar:SetValue(0)

				if bar.bg then
					bar.bg = _G[bar.bg:GetName()]
				else
					bar.bg = CreateFrame("Frame", "$parentBG", bar.statusbar)
					bar.bg:SetPoint("TOPLEFT", -1 * Misc.mult, 1 * Misc.mult)
					bar.bg:SetPoint("BOTTOMRIGHT", 1 * Misc.mult, -1 * Misc.mult)
					bar.bg:SetFrameStrata("BACKGROUND")
					SetTemplate(bar.bg, 0)
				end

				if bar.background then
					bar.background = _G[bar.background:GetName()]
				else
					bar.background = bar.statusbar:CreateTexture(nil, "BACKGROUND")
					bar.background:SetAllPoints()
					bar.background:SetTexture(Misc.barbg)		-- bar_BG
					bar.background:SetVertexColor(0, 0, 0, .25)
				end

				if bar.time then
					bar.time = _G[bar.time:GetName()]
				else
					bar.time = bar.statusbar:CreateFontString("$parentTime", "OVERLAY")
					bar.time:SetFont(Misc.font, Misc.numsize, "OUTLINE")
					bar.time:SetShadowOffset(1 * Misc.mult, -1 * Misc.mult)
					bar.time:SetPoint("RIGHT", bar.statusbar, 0, 5)
					bar.time:SetJustifyH("RIGHT")
				end

				if bar.count then
					bar.count = _G[bar.count:GetName()]
				else
					bar.count = bar:CreateFontString("$parentCount", "OVERLAY")
					bar.count:SetFont(Misc.font, Misc.numsize, "OUTLINE")
					bar.count:SetShadowOffset(1 * Misc.mult, -1 * Misc.mult)
					bar.count:SetPoint("TOPRIGHT", 1, 0)
					bar.count:SetJustifyH("RIGHT")
				end

				if bar.spellname then
					bar.spellname = _G[bar.spellname:GetName()]
				else
					bar.spellname = bar.statusbar:CreateFontString("$parentSpellName", "OVERLAY")
					bar.spellname:SetFont(GameFontNormal:GetFont(), Misc.namesize, "OUTLINE")
					bar.spellname:SetShadowOffset(1 * Misc.mult, -1 * Misc.mult)
					bar.spellname:SetPoint("LEFT", bar.statusbar, 2, 10)
					bar.spellname:SetPoint("RIGHT", bar.time, "LEFT")
					bar.spellname:SetJustifyH("LEFT")
				end
			end
			bar.spellID = 0
			self.bars[index] = bar
		end
		previous = bar
		index = index + 1
	end

	if not self.sortedIndex then self.sortedIndex = {} end

	for n in pairs(self.sortedIndex) do
		self.sortedIndex[n] = 999
	end

	local activeCount = 1
	local limit = ((self.IconSize + self.Interval) * 9)/self.IconSize
	for n in pairs(self.actives) do
		self.sortedIndex[activeCount] = n
		activeCount = activeCount + 1
		if activeCount > limit then activeCount = limit end
	end
	table.sort(self.sortedIndex)

	index = 1

	for n in pairs(self.sortedIndex) do
		if n >= activeCount then
			break
		end
		local activeIndex = self.sortedIndex[n]
		local value = self.actives[activeIndex]
		local bar = self.bars[index]
		bar.spellName = GetSpellInfo(value.spid)
		if self.Mode == "BAR" then
			bar.spellname:SetText(bar.spellName)
		end
		bar.icon:SetTexture(value.icon)
		if value.count and value.count > 1 then
			bar.count:SetText(value.count)
			bar.count:Show()
		else
			bar.count:Hide()
		end
		if value.duration and value.duration > 0 then
			if self.Mode == "ICON" then
				CooldownFrame_Set(bar.cooldown, value.start, value.duration, 1) --CooldownFrame_Set
				if value.data.filter == "CD" or value.data.filter == "ICD" then
					bar.value = value
					bar.activeIndex = activeIndex
					bar:SetScript("OnUpdate", Filger.UpdateCD)
				else
					bar:SetScript("OnUpdate", nil)
				end
				bar.cooldown:Show()
			else
				bar.statusbar:SetMinMaxValues(0, value.duration)
				bar.value = value
				bar.activeIndex = activeIndex
				bar:SetScript("OnUpdate", Filger.UpdateCD)
			end
		else
			if self.Mode == "ICON" then
				bar.cooldown:Hide()
			else
				bar.statusbar:SetMinMaxValues(0, 1)
				bar.statusbar:SetValue(1)
				bar.time:SetText("")
			end
			bar:SetScript("OnUpdate", nil)
		end
		bar.spellID = value.spid
		bar:SetWidth(self.IconSize or 37)
		bar:SetHeight(self.IconSize or 37)
		bar:SetAlpha(value.data.opacity or 1)
		if self.enable == "OFF" then
			bar:Hide()
		elseif self.enable == "ON" then
			bar:Show()
		else
			bar:Show()
		end
		index = index + 1
	end

	for i = index, #self.bars, 1 do
		local bar = self.bars[i]
		bar:Hide()
	end
end

function Filger:OnEvent(event, unit, _, _, _, spellID)
	if event == "SPELL_UPDATE_COOLDOWN" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "UNIT_AURA" and (unit == "target" or unit == "player" or unit == "pet" or unit == "focus") or (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player") then
		local ptt = GetSpecialization()
		local needUpdate = false
		local id = self.Id

		for i = 1, #Filger_Spells[class][id], 1 do
			local data = Filger_Spells[class][id][i]
			local found = false
			local name, icon, count, duration, start, spid
			spid = 0

			if data.filter == "BUFF" and (not data.spec or data.spec == ptt) then
				local caster, spn, expirationTime
				spn, _, _ = GetSpellInfo(data.spellID)
				if spn then
					name,  icon, count, _, duration, expirationTime, caster, _, _, spid = Filger:UnitBuff(data.unitID, data.spellID, spn, data.absID)
					if name and (data.caster ~= 1 and (caster == data.caster or data.caster == "all") or MyUnits[caster]) then
						if not data.count or count >= data.count then
							start = expirationTime - duration
							found = true
						end
					end
				end
			elseif data.filter == "DEBUFF" and (not data.spec or data.spec == ptt) then
				local caster, spn, expirationTime
				spn, _, _ = GetSpellInfo(data.spellID)
				if spn then
					name,  icon, count, _, duration, expirationTime, caster, _, _, spid = Filger:UnitDebuff(data.unitID, data.spellID, spn, data.absID)
					if name and (data.caster ~= 1 and (caster == data.caster or data.caster == "all") or MyUnits[caster]) then
						start = expirationTime - duration
						found = true
					end
				end
			elseif data.filter == "CD" and (not data.spec or data.spec == ptt) then
				if data.spellID then
					name, _, icon = GetSpellInfo(data.spellID)
					if name then
						if data.absID then
							start, duration = GetSpellCooldown(data.spellID)
						else
							start, duration = GetSpellCooldown(name)
						end
						spid = data.spellID
					end
				elseif data.slotID then
					spid = data.slotID
					local slotLink = GetInventoryItemLink("player", data.slotID)
					if slotLink then
						name, _, _, _, _, _, _, _, _, icon = GetItemInfo(slotLink)
						start, duration = GetInventoryItemCooldown("player", data.slotID)
					end
				end
				if name and (duration or 0) > 1.5 then
					found = true
				end
			elseif data.filter == "ICD" and (not data.spec or data.spec == ptt) then
				if data.trigger == "BUFF" then
					local spn
					spn, _, icon = GetSpellInfo(data.spellID)
					if spn then
						name, _, _, _, _, _, _, _, _, spid = Filger:UnitBuff("player", data.spellID, spn, data.absID)
					end
				elseif data.trigger == "DEBUFF" then
					local spn
					spn, _, icon = GetSpellInfo(data.spellID)
					if spn then
						name, _, _, _, _, _, _, _, _, spid = Filger:UnitDebuff("player", data.spellID, spn, data.absID)
					end
				elseif data.trigger == "NONE" and event == "UNIT_SPELLCAST_SUCCEEDED" then
					if spellID == data.spellID then
						name, _, icon = GetSpellInfo(data.spellID)
						spid = data.spellID
					end
				end
				if name then
					if data.slotID then
						local slotLink = GetInventoryItemLink("player", data.slotID)
						_, _, _, _, _, _, _, _, _, icon = GetItemInfo(slotLink)
					end
					duration = data.duration
					start = GetTime()
					found = true
				end
			end

			if found then
				if not self.actives then self.actives = {} end
				if not self.actives[i] then
					self.actives[i] = {data = data, name = name, icon = icon, count = count, start = start, duration = duration, spid = spid}
					needUpdate = true
					if class == "DEATHKNIGHT" and self.actives[i].duration == 10 and data.filter == "CD" then
						self.actives[i] = nil
					end
				else
					if data.filter ~= "ICD" and (self.actives[i].count ~= count or self.actives[i].start ~= start or self.actives[i].duration ~= duration) then
						self.actives[i].count = count
						self.actives[i].start = start
						self.actives[i].duration = duration
						needUpdate = true
					end
				end
			else
				if data.filter ~= "ICD" and self.actives and self.actives[i] then
					if event == "UNIT_SPELLCAST_SUCCEEDED" then return end
					self.actives[i] = nil
					needUpdate = true
				end
			end
		end

		if needUpdate and self.actives then
			Filger.DisplayActives(self)
		end
	end
end

if Filger_Spells and Filger_Spells["ALL"] then
	if not Filger_Spells[class] then
		Filger_Spells[class] = {}
	end

	for i = 1, #Filger_Spells["ALL"], 1 do
		local merge = false
		local spellListAll = Filger_Spells["ALL"][i]
		local spellListClass = nil
		for j = 1, #Filger_Spells[class], 1 do
			spellListClass = Filger_Spells[class][j]
			local mergeAll = spellListAll.Merge or false
			local mergeClass = spellListClass.Merge or false
			if spellListClass.Name == spellListAll.Name and (mergeAll or mergeClass) then
				merge = true
				break
			end
		end
		if not merge or not spellListClass then
			table.insert(Filger_Spells[class], Filger_Spells["ALL"][i])
		else
			for j = 1, #spellListAll, 1 do
				table.insert(spellListClass, spellListAll[j])
			end
		end
	end
end

if Filger_Spells and Filger_Spells[class] then
	for index in pairs(Filger_Spells) do
		if index ~= class then
			Filger_Spells[index] = nil
		end
	end

	local idx = {}
	for i = 1, #Filger_Spells[class], 1 do
		local jdx = {}
		local data = Filger_Spells[class][i]

		for j = 1, #data, 1 do
			local spn
			if data[j].spellID then
				spn = GetSpellInfo(data[j].spellID)
			else
				local slotLink = GetInventoryItemLink("player", data[j].slotID)
				if slotLink then
					spn = GetItemInfo(slotLink)
				end
			end
			if not spn and not data[j].slotID then
				print("|cffff0000WARNING: spell/slot ID ["..(data[j].spellID or data[j].slotID or "UNKNOWN").."] no longer exists! Report this to Shestak.|r")
				table.insert(jdx, j)
			end
		end

		for _, v in ipairs(jdx) do
			table.remove(data, v)
		end

		if #data == 0 then
			print("|cffff0000WARNING: section ["..data.Name.."] is empty! Report this to Shestak.|r")
			table.insert(idx, i)
		end
	end

	for _, v in ipairs(idx) do
		table.remove(Filger_Spells[class], v)
	end

	for i = 1, #Filger_Spells[class], 1 do
		local data = Filger_Spells[class][i]

		local movebar = CreateFrame("Frame", "FilgerFrame"..i.."_"..data.Name.."Movebar", UIParent)
		movebar:SetFrameStrata("TOOLTIP")
		movebar:EnableMouse(true)
		movebar:SetMovable(true)
		movebar:SetClampedToScreen(true)
		movebar:RegisterForDrag("LeftButton")
		movebar:SetScript("OnDragStart", function(self) self:StartMoving() end)
		movebar:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		movebar:SetBackdrop({  
			bgFile = "Interface\\Buttons\\WHITE8x8", 
			insets = {left = 1, right = 1, top = 1, bottom = 1},
		})
		movebar:SetBackdropColor(0, 1, 0, 0.6)
		movebar:SetSize(data.IconSize or 37, data.IconSize or 37)
		movebar.Position = data.Position or "CENTER"
		movebar:SetPoint(unpack(data.Position))
		movebar:Hide()

		movebar.name = movebar:CreateFontString(nil, "OVERLAY")
		movebar.name:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
		movebar.name:SetPoint("CENTER")
		movebar.name:SetText(data.Name)

		local frame = CreateFrame("Frame", "FilgerFrame"..i.."_"..data.Name, UIParent)
		frame.Id = i
		frame.Name = data.Name
		frame.Direction = data.Direction or "DOWN"
		frame.IconSide = data.IconSide or "LEFT"
		frame.NumPerLine = data.NumPerLine		-- 注册换行
		frame.enable = data.enable or "ON"
		frame.Mode = data.Mode or "ICON"
		frame.Interval = data.Interval or 3
		frame:SetAlpha(data.Alpha or 1)
		frame.IconSize = data.IconSize or 37
		frame.BarWidth = data.BarWidth or 186
		frame.Position = data.Position or "CENTER"
		--frame:SetPoint(unpack(data.Position))

		for j = 1, #Filger_Spells[class][i], 1 do
			local data = Filger_Spells[class][i][j]
			if data.filter == "CD" then
				frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
				break
			elseif data.trigger == "NONE" then
				frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
				break
			end
		end
		frame:RegisterEvent("UNIT_AURA")
		frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
		frame:RegisterEvent("PLAYER_TARGET_CHANGED")
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame:SetScript("OnEvent", Filger.OnEvent)
		frame.movebar = movebar
	end
end

-- Test function
local InitTest = function(msg)
	msg = string.lower(msg)
	if msg == "test" then
		if UnitAffectingCombat("player") then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
		testMode = not testMode
		for i = 1, #Filger_Spells[class], 1 do	
			local data = Filger_Spells[class][i]
			local frame = _G["FilgerFrame"..i.."_"..data.Name]
			frame.actives = {}
			if testMode then
				for j = 1, math.min(Misc.maxTestIcon, #Filger_Spells[class][i]), 1 do
					local data = Filger_Spells[class][i][j]
					local name, icon
					if data.spellID then
						name, _, icon = GetSpellInfo(data.spellID)
					elseif data.slotID then
						local slotLink = GetInventoryItemLink("player", data.slotID)
						if slotLink then
							name, _, _, _, _, _, _, _, _, icon = GetItemInfo(slotLink)
						end
					end
					frame.actives[j] = {data = data, name = name, icon = icon, count = 9, start = 0, duration = 0, spid = data.spellID or data.slotID}
				end
				frame:SetScript("OnEvent", nil)
				frame.movebar:Show()
			else
				frame:SetScript("OnEvent", Filger.OnEvent)
				frame.movebar:Hide()
			end
			Filger.DisplayActives(frame)
		end
	elseif msg == "reset" then
		for i = 1, #Filger_Spells[class], 1 do
			local data = Filger_Spells[class][i]
			local frame = _G["FilgerFrame"..i.."_"..data.Name]
			frame.movebar:ClearAllPoints()
			frame.movebar:SetPoint(unpack(data.Position))
		end
	else
		print("|cffffff00/Filger test   解锁/锁定|r")
		print("|cffffff00/Filger reset  重置|r")
	end
end

SlashCmdList.FilgerTest = InitTest
SLASH_FilgerTest1 = "/sf"
SLASH_FilgerTest2 = "/filger"