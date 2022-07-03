local addon_name, addon = ...

local _G = _G

_G.RotationMaster = LibStub("AceAddon-3.0"):NewAddon(addon, addon_name, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

local AceConsole = LibStub("AceConsole-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local SpellData = LibStub("AceGUI-3.0-SpellLoader")
local L = LibStub("AceLocale-3.0"):GetLocale("RotationMaster")
local getCached, getRetryCached
local DBIcon = LibStub("LibDBIcon-1.0")

local ThreatClassic = LibStub("ThreatClassic-1.0")
if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then
    UnitThreatSituation = ThreatClassic.UnitThreatSituation

    local LibClassicDurations = LibStub("LibClassicDurations")
    LibClassicDurations:Register(addon_name)
else
    ThreatClassic:Disable()
end

local pairs, color, string = pairs, color, string
local floor = math.floor
local multiinsert, isin, starts_with, isint = addon.multiinsert, addon.isin, addon.starts_with, addon.isint

addon.pretty_name = GetAddOnMetadata(addon_name, "Title")
local DataBroker = LibStub("LibDataBroker-1.1"):NewDataObject("RotationMaster",
        { type = "data source", label = addon.pretty_name, icon = "Interface\\AddOns\\RotationMaster\\textures\\RotationMaster-Minimap" })

--
-- Initialization
--

BINDING_HEADER_ROTATIONMASTER = addon.pretty_name
BINDING_NAME_ROTATIONMASTER_TOGGLE = string.format(L["Toggle %s " .. color.CYAN .. "/rm toggle" .. color.RESET], addon.pretty_name)

local combination_food = {}
local conjured_food = { 22895, 8076, 8075, 1487, 1114, 1113, 5349, }
local conjured_water = { 8079, 8078, 8077, 3772, 2136, 2288, 5350, }
local mana_potions = { 13444, 13443, 6149, 3827, 3385, 2455, }
local healing_potions = { 13446, 3928, 1710, 929, 858, 118, }
local bandages = { 14530, 14529, 8545, 8544, 6451, 6450, 3531, 3530, 2581, 1251, }
local purchased_water = { 8766, 1645, 1708, 1205, 1179, 159, }
local healthstones = {
    "Major Healthstone",
    "Greater Healthstone",
    "Healthstone",
    "Lesser Healthstone",
    "Minor Healthstone",
}

local playerGUID = UnitGUID("player")
--1238964532348905534567670980
local CrazyFrame = {}
local EventFrame = CreateFrame("Frame") 
local _CBLD = {}
local currentAddon = ""
local BindingTable = {id = {}, bind = {}, spellType = {}, numberSlot = {}, stringFieldBind = {}, buttonTextureTo = {}, buttonTextureFrom = {}, buttonTextureBind = {}, buttonTextureType = {}}










--local debugFrame = CreateFrame("Frame", "DragFrame2", UIParent)
--debugFrame:SetMovable(true)
--debugFrame:EnableMouse(true)
--debugFrame:RegisterForDrag("LeftButton")
--debugFrame:SetScript("OnDragStart", debugFrame.StartMoving)
--debugFrame:SetScript("OnDragStop", debugFrame.StopMovingOrSizing)
---- The code below makes the frame visible, and is not necessary to enable dragging.
--debugFrame:SetPoint("CENTER"); debugFrame:SetWidth(32); debugFrame:SetHeight(32);
--local debugTexture = debugFrame:CreateTexture("ARTWORK");
--debugTexture:SetAllPoints();
--debugTexture:SetTexture(1.0, 0.5, 0); --tex:SetAlpha(0.5);
--debugFrame.text = debugFrame:CreateFontString(nil,"ARTWORK") 
--debugFrame.text:SetFont("Fonts\\ARIALN.ttf", 11, "OUTLINE")
--debugFrame.text:SetPoint("BOTTOM",0,0)
--debugFrame.text:SetText("debug")
--debugFrame:SetMovable(true)
--debugFrame:EnableMouse(true)
--debugFrame:SetScript("OnMouseDown", function(self, button)
--  if button == "LeftButton" and not self.isMoving then
--   self:StartMoving();
--   self.isMoving = true;
--  end
--end)
--debugFrame:SetScript("OnMouseUp", function(self, button)
--  if button == "LeftButton" and self.isMoving then
--   self:StopMovingOrSizing();
--   self.isMoving = false;
--  end
--end)
--debugFrame:SetScript("OnHide", function(self)
--  if ( self.isMoving ) then
--   self:StopMovingOrSizing();
--   self.isMoving = false;
--  end
--end)
--






















local TCONRO = nil
local s_count = 0;
local btnTMWmain = nil
--if element.actionId ~= nil then _CBLD.ShowOther(s_count, element.actionId) end; s_count = s_count + 1 if s_count == 4 then s_count = 0 end
-- /script v, b, d, t = GetBuildInfo()
--/script print(string.format("version = %s, build = %s, date = '%s', tocversion = %s.", v, b, d, t))               
-----------------------------------------------------------------------------------------
function EventFrame:OnEvent(event, ...) 
	-- print("Welcome to Meoww Legion!")
	self[event](self, ...) 
end
EventFrame:SetScript("OnEvent", EventFrame.OnEvent)

function EventFrame:PLAYER_LOGIN()
	local step = 0; 
	local tWidth = GetScreenWidth() * UIParent:GetEffectiveScale() / 40
	local tHeight = 1;	
	for x = 0, 40 do		
		CrazyFrame[x] = CreateFrame("Frame",AddOnName,WorldFrame)
			CrazyFrame[x].t = CrazyFrame[x]:CreateTexture()
		CrazyFrame[x]:ClearAllPoints()
		CrazyFrame[x]:SetScale(1)
		CrazyFrame[x]:SetFrameStrata("TOOLTIP")
		CrazyFrame[x]:SetWidth(tWidth)
		CrazyFrame[x]:SetHeight(tHeight)
		CrazyFrame[x]:SetPoint("TOPLEFT",step,0)
		CrazyFrame[x].t:SetAllPoints(CrazyFrame[x])
		CrazyFrame[x].t:SetColorTexture(0,0,0)
		CrazyFrame[x]:Show()			
		step = step + tWidth;					
	end 	
		if ConROC then
			TCONRO = ConROC
		elseif ConRO then
			TCONRO = ConRO
		end	
		_CBLD.CheckBuild()
end
EventFrame:RegisterEvent("PLAYER_LOGIN")

local updateIcon = CreateFrame("Frame")
function updateIcon:onUpdate(sinceLastUpdate)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate
    if (self.sinceLastUpdate >= 0.05) then
		_CBLD.PushDefaultData2Screen()
		if TCONRO then
			if TCONRO.AbilityBuff ~= nil then
				_CBLD.ShowOther(2, TCONRO.AbilityBuff)
			elseif TCONRO.AbilityBurst ~= nill then
				_CBLD.ShowOther(2, TCONRO.AbilityBurst)
			else
				_CBLD.ShowOther(2, nil)
			end		
		elseif TMW then
			_CBLD.ShowTmw()
		elseif WeakAuras then	
			_CBLD.WeekSpellFromTexture()
			
		end	
        self.sinceLastUpdate = 0
    end
end

updateIcon:SetScript(
        "OnUpdate",
        function(self, sinceLastUpdate)
            updateIcon:onUpdate(sinceLastUpdate)
        end
)

function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
local actionBars = {
    [1] = "ActionButton",
    [2] = "MultiBarRightButton",
    [3] = "MultiBarLeftButton",
    [4] = "MultiBarBottomRightButton",
    [5] = "MultiBarBottomLeftButton"
}


function _CBLD.CheckBuild()
	local v, b, d, t = GetBuildInfo()
	if v then
		local sv = tostring(v)
		local s = string.sub(sv, 1, 1)
		if s then
			local sn = tonumber(s)			
			if sn then
				if sn == 2 then
					btnTMWmain = "TellMeWhen_Group3_Icon1"
				elseif sn == 1 then
				
				elseif sn == 9 then
					btnTMWmain = "TellMeWhen_Group16_Icon1"
				end
			end
		end
	end
end

function _CBLD.GetFrame(slot)
        local name
        if _G["Bartender4"] then
            name = "BT4Button" .. slot
        else
            if slot <= 24 or slot > 72 then
                name = "ActionButton" .. (((slot - 1) % 12) + 1)
            else
                local slotIndex = slot - 1
                local actionBar = (slotIndex - (slotIndex % 12)) / 12
                name = actionBars[actionBar] .. ((slotIndex % 12) + 1)
            end
        end
        return _G[name]
    end
function _CBLD.ParseMacro(macroId)
	local macrobody = {}
	macrobody = GetMacroBody(macroId)
	local spellId
	local spellType
	if macrobody then
		local sep = "/"
		local t={}
		for str in string.gmatch(macrobody, "([^"..sep.."]+)") do
			table.insert(t, str)				
		end
		local mcb = ""
		local mcbtype = ""
		for i = 1, #t do
			local s = string.sub(t[i], 1, 4)
			if s == "cast" then
				mcb = string.trim(string.sub(t[i], 5, string.len(t[i])))
				mcbtype = "spell"
				break	
			end
			s = string.sub(t[i], 1, 3)
			
			if s == "use" then
				mcb = string.trim(string.sub(t[i], 4, string.len(t[i])))
				mcbtype = "item"
				break	
			end					
		end
		if mcb ~= "" then
			local sep = "]"
			local t={}
			for str in string.gmatch(macrobody, "([^"..sep.."]+)") do
				table.insert(t, str)				
			end	
			local size = #t
			local spellName = ""
			if size >= 2 then
				local n = t[size]
				spellName = string.trim(n)
			else
				spellName = string.trim(mcb)
				
			end
			if spellName then
				if mcbtype == "spell" then
					local out_spell_name, rank, icon, castTime, minRange, maxRange, spellid = GetSpellInfo(spellName)
					return spellid, mcbtype
				end
				if mcbtype == "item" then
					local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(spellName) 
					return itemID, mcbtype
				end
			end
		
		end
	end
	return nil
end

function _CBLD.ParseLink(hyperlink)
    local color, linkType, linkData, text = match(hyperlink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
    return color, linkType, linkData, text
end

function _CBLD.AddBind(actionType, buttonName, keyBind, spellId, slot)
	
	local bt = _CBLD.GetFrame(slot)
	local text = 0
	if bt then
		local at = bt.icon:GetTexture()
		if at then
			text = tonumber(at)
		end
	end
	
	if actionType == "spell" then
		local id = tonumber(spellId)
		if id then
			if not BindingTable.id[id] then
				BindingTable.id[id] = id
				BindingTable.bind[id] = keyBind
				BindingTable.spellType[id] = actionType
				BindingTable.numberSlot[id] = slot
				local b = tostring(keyBind)
				BindingTable.stringFieldBind[b] = id
				
				BindingTable.buttonTextureTo[id] = text
				BindingTable.buttonTextureFrom[text] = id
				BindingTable.buttonTextureBind[text] = keyBind
				BindingTable.buttonTextureType[text] = actionType
				--print(BindingTable.spellType[id] .. " : " .. BindingTable.id[id] .. " : " .. BindingTable.bind[id])
			end
        end
	elseif actionType == "item" then
		local id = tonumber(spellId)
		if id then
			if not BindingTable.id[id] then
				BindingTable.id[id] = id
				BindingTable.bind[id] = keyBind
				BindingTable.spellType[id] = actionType
				BindingTable.numberSlot[id] = slot
				local b = tostring(keyBind)
				BindingTable.stringFieldBind[b] = id
				
				BindingTable.buttonTextureTo[id] = text
				BindingTable.buttonTextureFrom[text] = id
				BindingTable.buttonTextureBind[text] = keyBind
				BindingTable.buttonTextureType[text] = actionType
				
				--print(BindingTable.spellType[id] .. " : " .. BindingTable.id[id] .. " : " .. BindingTable.bind[id])
			end
        end
	elseif actionType == "macro" then
		local id = tonumber(spellId)
		if id then		
			local spell, mcbtype = _CBLD.ParseMacro(id)			
			if spell then
				local tid = tonumber(spell)
				if tid then
					if not BindingTable.id[tid] then
						BindingTable.id[tid] = tid
						BindingTable.bind[tid] = keyBind
						BindingTable.spellType[tid] = mcbtype
						BindingTable.numberSlot[tid] = slot
						local b = tostring(keyBind)
						BindingTable.stringFieldBind[b] = tid
						
						BindingTable.buttonTextureTo[tid] = text
						BindingTable.buttonTextureFrom[text] = tid
						BindingTable.buttonTextureBind[text] = keyBind
						BindingTable.buttonTextureType[text] = mcbtype
						
						
						--print(BindingTable.spellType[tid] .. " : " .. BindingTable.id[tid] .. " : " .. BindingTable.bind[tid])
					end
				end
			end	
        end
	end
end

function _CBLD.BindSnap()
	local API_GetActionInfo = GetActionInfo
	local API_GetBindingKey = GetBindingKey
	local API_UnitClass = UnitClass
	
	wipe(BindingTable.id)
	wipe(BindingTable.bind)
	wipe(BindingTable.spellType)
	wipe(BindingTable.numberSlot)
	wipe(BindingTable.stringFieldBind)
	local bonusBar = GetBonusBarOffset()
	local slot = 0;
	for slot = 1, 120 do
	
			--[[
			ACTIONBUTTON1..12			=> primary (1..12, 13..24), bonus (73..120)
			MULTIACTIONBAR1BUTTON1..12	=> bottom left (61..72)
			MULTIACTIONBAR2BUTTON1..12	=> bottom right (49..60)
			MULTIACTIONBAR3BUTTON1..12	=> top right (25..36)
			MULTIACTIONBAR4BUTTON1..12	=> top left (37..48)
		--]]
		local name
		if _G["Bartender4"] then
            name = "CLICK BT4Button " .. slot .. ":LeftButton"
        else
			if slot <= 24 or slot > 72 then
				name = "ACTIONBUTTON" .. (((slot - 1)%12) + 1)
			elseif slot <= 36 then
				name = "MULTIACTIONBAR3BUTTON" .. (slot - 24)
			elseif slot <= 48 then
				name = "MULTIACTIONBAR4BUTTON" .. (slot - 36)
			elseif slot <= 60 then
				name = "MULTIACTIONBAR2BUTTON" .. (slot - 48)
			else
				name = "MULTIACTIONBAR1BUTTON" .. (slot - 60)
			end
		end
		local key = name and API_GetBindingKey(name)
		-- Shorten the keybinding names.
		if key and strlen(key) > 4 then
			key = strupper(key)
			-- Strip whitespace.
			key = gsub(key, "%s+", "")
			-- Convert modifiers to a single character.
			key = gsub(key, "ALT", "A")
			key = gsub(key, "CTRL", "C")
			key = gsub(key, "SHIFT", "S")
			local tk = string.sub(key, 2, 3)
			if tk == "--" then
				key = string.sub(key, 1, 1) .. "-" 
			else
				key = gsub(key, "-", "")
			end
			-- Shorten numberpad keybinding names.
			key = gsub(key, "NUMPAD", "N")
			key = gsub(key, "PLUS", "+")
			key = gsub(key, "MINUS", "-")
			key = gsub(key, "MULTIPLY", "*")
			key = gsub(key, "DIVIDE", "/")
		end
	--    1    ActionBar page 1 Cat Form: 			slots 73 	84
	--    2    ActionBar page 1 Prowl: 				slots 85 	96
	--    3    ActionBar page 1 Bear Form: 			slots 97 	108
	--    4    ActionBar page 1 Moonkin Form: 		slots 109	120
		local actionType, id, subType = API_GetActionInfo(slot)
		if actionType and name and key then

			
			if bonusBar == 0 and slot < 73 then
				_CBLD.AddBind(actionType, name, key, id, slot)
			elseif bonusBar == 1 and slot > 12 then
				if slot < 85 then
					_CBLD.AddBind(actionType, name, key, id, slot)
				end
			elseif bonusBar == 2 and slot > 12 then
				if slot < 73 or (slot > 84 and slot < 97) then
					_CBLD.AddBind(actionType, name, key, id, slot)
				end
			elseif bonusBar == 3 and slot > 12 then
				if slot < 73 or (slot > 84 and slot < 109) then
					_CBLD.AddBind(actionType, name, key, id, slot)
				end
			elseif bonusBar == 4 and slot > 12 then
				if slot < 73 or slot > 108 then
					_CBLD.AddBind(actionType, name, key, id, slot)
				end
			end
			
		end

	end
	
end

local hiding = CreateFrame("Frame", "stealthbagz");
hiding:RegisterEvent("PLAYER_ENTERING_WORLD")
hiding:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
hiding:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
hiding:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
hiding:RegisterEvent("CHARACTER_POINTS_CHANGED")
hiding:RegisterEvent("ACTIONBAR_UPDATE_STATE")
hiding:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
hiding:RegisterEvent("SPELLS_CHANGED")
hiding:RegisterEvent("UPDATE_BINDINGS")
local function hideBG(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		_CBLD.BindSnap()
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		_CBLD.BindSnap()	
	elseif event == "ACTIONBAR_PAGE_CHANGED" then	
		_CBLD.BindSnap()	
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		--C_Timer.After(2.5, BindSnap)
		_CBLD.BindSnap()
	elseif event == "CHARACTER_POINTS_CHANGED" then
		--C_Timer.After(2.5, BindSnap)
		_CBLD.BindSnap()
	elseif event == "ACTIONBAR_UPDATE_STATE" then
		_CBLD.BindSnap()
	elseif event == "UPDATE_BONUS_ACTIONBAR" then
		_CBLD.BindSnap()
	elseif event == "SPELLS_CHANGED" then
		_CBLD.BindSnap()
	elseif event == "UPDATE_BINDINGS" then
		_CBLD.BindSnap()	
	end	
end
hiding:SetScript("OnEvent", hideBG);


local fcast = CreateFrame("Frame")
fcast:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
fcast:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
fcast:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
fcast:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
fcast:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
		CrazyFrame[10].t:SetColorTexture(0.000 ,0.0,0.0)
		--CrazyFrame[20].t:SetColorTexture(0.0,0.0,0.0)
    elseif event == "UNIT_SPELLCAST_START" then
		CrazyFrame[10].t:SetColorTexture(0.000 ,0.0,0.0)
		--CrazyFrame[20].t:SetColorTexture(0.004 ,0.0,0.0)
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		--CrazyFrame[20].t:SetColorTexture(0.0,0.0,0.0)		 	
	elseif event == "UNIT_SPELLCAST_FAILED" then
		--CrazyFrame[20].t:SetColorTexture(0.0,0.0,0.0)		
	else
		--
    end
end)

function _CBLD.BindSplit(bindString)

	--print(bindString)
	local button = 0.000
	local modificator =0.000
	local button = ""
	local tempString = bindString
	if(tempString == nil) then
		local t={}
		t[1] = 0.000
		t[2] = 0.000
		t[3] = 0.000		
		return t
	end
	if string.len(tempString) == 0 then
		local t={}
		t[1] = 0.000
		t[2] = 0.000
		t[3] = 0.000		
		return t
	end
	tempString = string.upper(tempString)
	--print(bindString)
	if string.len(tempString) == 1 then
		modificator = 0.0
		button = tempString
	else
		local first = string.sub(tempString, 1, 1)
		local secnd = string.sub(tempString, 2, string.len(tempString))
		--print(secnd)
		if first == "C" then
			modificator  = 0.008
			button = secnd
		elseif first == "A" then
			modificator  = 0.004
			button = secnd
		elseif first == "S" then
			modificator  = 0.012
			button = secnd
		else
			modificator = 0.0
			button = tempString
		end
		--print(first)
	--print(secnd)
	end
	
	
	local hexString = _CBLD.Str2Hex(button)
	local oneChunk = string.sub(hexString, 1, 1)
	local twoChunk = string.sub(hexString, 2, 2)
	
	local colorOne = _CBLD.Char2Color(oneChunk)
	local colorTwo = _CBLD.Char2Color(twoChunk)
	
	local tb={}
	tb[1] = modificator
	tb[2] = colorOne
	tb[3] = colorTwo
	
	--print("   cone - " .. tostring(t[1]) .. "   ctwo - " .. tostring(t[2]) .. "   cthree - " .. tostring(t[3]))
	return tb

end 

function  _CBLD.Char2Color(oneChar)
	-- 0 зарезервирован
	
	local str = tostring(oneChar)
	local outStr = 0.000
	if str == "0" then
		outStr = 0.004
	elseif str == "1" then	
		outStr = 0.008
	elseif str == "2" then	
		outStr = 0.012
	elseif str == "3" then	
		outStr = 0.016
	elseif str == "4" then	
		outStr = 0.020
	elseif str == "5" then	
		outStr = 0.024
	elseif str == "6" then	
		outStr = 0.027
	elseif str == "7" then	
		outStr = 0.031
	elseif str == "8" then	
		outStr = 0.035
	elseif str == "9" then	
		outStr = 0.039
	elseif str == "A" then		
		outStr = 0.043
	elseif str == "B" then	
		outStr = 0.047
	elseif str == "C" then	
		outStr = 0.051
	elseif str == "D" then	
		outStr = 0.055
	elseif str == "E" then	
		outStr = 0.059
	elseif str == "F" then	
		outStr = 0.063
	end	
	return outStr
end

function  _CBLD.Str2Hex(hString)
	local tString = hString;
	local outStr = ""
	if tString == "\\" then
		outStr = "DC"
	elseif tString == "[" then	
		outStr = "DB"	
	elseif tString == "]" then	
		outStr = "DD"	
	elseif tString == ";" then	
		outStr = "BA"	
	elseif tString == "'" then	
		outStr = "DE"
	elseif tString == "," then	
		outStr = "BC"
	elseif tString == "." then	
		outStr = "BE"	
	elseif tString == "/" then	
		outStr = "BF"
	elseif tString == "`" then	
		outStr = "C0"	
	elseif tString == "-" then	
		outStr = "BD"
	elseif tString == "=" then	
		outStr = "BB"
	elseif tString == "F1" then	
		outStr = "70"
	elseif tString == "F2" then	
		outStr = "71"
	elseif tString == "F3" then	
		outStr = "72"
	elseif tString == "F4" then	
		outStr = "73"
	elseif tString == "F5" then	
		outStr = "74"
	elseif tString == "F6" then	
		outStr = "75"
	elseif tString == "F7" then	
		outStr = "76"
	elseif tString == "F8" then	
		outStr = "77"
	elseif tString == "F9" then	
		outStr = "78"
	elseif tString == "F10" then	
		outStr = "79"
	elseif tString == "F11" then	
		outStr = "7A"
	elseif tString == "F12" then	
		outStr = "7B"
	elseif tString == "1" then	
		outStr = "31"
	elseif tString == "2" then	
		outStr = "32"
	elseif tString == "3" then	
		outStr = "33"
	elseif tString == "4" then	
		outStr = "34"
	elseif tString == "5" then	
		outStr = "35"
	elseif tString == "6" then	
		outStr = "36"
	elseif tString == "7" then	
		outStr = "37"
	elseif tString == "8" then	
		outStr = "38"
	elseif tString == "9" then	
		outStr = "39"
	elseif tString == "0" then	
		outStr = "30"
	elseif tString == "Q" then	
		outStr = "51"
	elseif tString == "W" then	
		outStr = "57"
	elseif tString == "E" then	
		outStr = "45"
	elseif tString == "R" then	
		outStr = "52"
	elseif tString == "T" then	
		outStr = "54"
	elseif tString == "Y" then	
		outStr = "59"
	elseif tString == "U" then	
		outStr = "55"
	elseif tString == "I" then	
		outStr = "49"
	elseif tString == "O" then	
		outStr = "4F"
	elseif tString == "P" then	
		outStr = "50"
	elseif tString == "A" then	
		outStr = "41"
	elseif tString == "S" then	
		outStr = "53"
	elseif tString == "D" then	
		outStr = "44"
	elseif tString == "F" then	
		outStr = "46"
	elseif tString == "G" then	
		outStr = "47"
	elseif tString == "H" then	
		outStr = "48"
	elseif tString == "J" then	
		outStr = "4A"
	elseif tString == "K" then	
		outStr = "4B"
	elseif tString == "L" then	
		outStr = "4C"
	elseif tString == "Z" then	
		outStr = "5A"
	elseif tString == "X" then	
		outStr = "58"
	elseif tString == "C" then	
		outStr = "43"
	elseif tString == "V" then	
		outStr = "56"
	elseif tString == "B" then	
		outStr = "42"
	elseif tString == "N" then	
		outStr = "4E"
	elseif tString == "M" then	
		outStr = "4D"
	end
	
	return outStr

end

function _CBLD.PushCurrentItemFromId(index, itemid, keybind)

	local t={}
	t = _CBLD.BindSplit(keybind)
	if t == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	if t[2] == 0.0 then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	if itemid == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	if _CBLD.ItemCd(itemid) == false then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	if UnitIsDeadOrGhost("player") then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
	end	
	CrazyFrame[index].t:SetColorTexture(t[1] ,t[2], t[3])
	--print(index .. " : " .. itemid .. " : " .. keybind)
end

function _CBLD.PushCurrentSpellFromId(index, itemid, keybind)

	local t={}
	t = _CBLD.BindSplit(keybind)

	if t == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	if t[2] == 0.0 then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	if itemid == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end	
	if _CBLD.SpellCd(itemid) == false then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	
	if UnitIsDeadOrGhost("player") then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	
	
	local cost = 0
	local costTable = GetSpellPowerCost(skill)
	if(costTable ~= nil)then
		for key, costInfo in pairs(costTable) do
			cost = costInfo.cost
			break
		end
	end
	local upower = UnitPower("player")
	if upower < cost then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	CrazyFrame[index].t:SetColorTexture(t[1] ,t[2], t[3])
	--print(index .. " : " .. itemid .. " : " .. keybind)
end

function _CBLD.ShowWeekAuras(index, keybind)
		
	local KeyBind = nil
	local SpellId = nil
	local SpellType = nil
	
	if keybind == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	
	if keybind and strlen(keybind) > 4 then
		keybind = strupper(keybind)
		-- Strip whitespace.
		keybind = gsub(keybind, "%s+", "")
		-- Convert modifiers to a single character.
		keybind = gsub(keybind, "ALT", "A")
		keybind = gsub(keybind, "CTRL", "C")
		keybind = gsub(keybind, "SHIFT", "S")
		local tk = string.sub(keybind, 2, 3)
		if tk == "--" then
			keybind = string.sub(keybind, 1, 1) .. "-" 
		else
			keybind = gsub(keybind, "-", "")
		end
		-- Shorten numberpad keybinding names.
		keybind = gsub(keybind, "NUMPAD", "N")
		keybind = gsub(keybind, "PLUS", "+")
		keybind = gsub(keybind, "MINUS", "-")
		keybind = gsub(keybind, "MULTIPLY", "*")
		keybind = gsub(keybind, "DIVIDE", "/")
	end

	local k = tostring(keybind)
	if k then
		local _id = BindingTable.stringFieldBind[k]
		if _id then 
			SpellId = tonumber(_id)
			KeyBind = k				
		else
			CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
			return
		end
	else
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end

	if SpellId == nil or KeyBind == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	SpellType = BindingTable.spellType[SpellId]
	if SpellType == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	if SpellType == "spell" then
		_CBLD.PushCurrentSpellFromId(index, SpellId, KeyBind)
		return
	end
	if SpellType == "item" then
		_CBLD.PushCurrentItemFromId(index, SpellId, KeyBind)
		return
	end
	CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
end

function _CBLD.ShowOther(index, id)
	if id == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	local SpellId = tonumber(id)
	if SpellId == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	local KeyBind = nil	
	local SpellType = nil
	
	local k = BindingTable.bind[SpellId]
	if k == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	KeyBind = tostring(k)
	if KeyBind == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	
	local s = BindingTable.spellType[SpellId]
	if s == nil then
		CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	SpellType = tostring(s)
	if SpellType == "spell" then
		_CBLD.PushCurrentSpellFromId(index, SpellId, KeyBind)
		return
	end
	if SpellType == "item" then
		_CBLD.PushCurrentItemFromId(index, SpellId, KeyBind)
		return
	end
	CrazyFrame[index].t:SetColorTexture(0.0 ,0.0,0.0)
	
end

function _CBLD.TmwGetMainTexture()
	if TMW == nil then return end
	local own = TMW.GUIDToOwner
	if own == nil then return end
	for k, v in pairs(own) do
      if v then
         local t = {}
         t = v
         if t then
            if t.Name == "Main Meta" then -- tbc
				local i = t[1]
				if i then
					local ia = i.animation_overlay
					if ia then
						local txt = ia:GetTexture()
						if txt then
							local texture = tonumber(txt)
							return texture
						end
					else
						local ib = i.lmbButtonData.Icon
						if ib then
							local txt = ib:GetTexture()
							if txt then
								local texture = tonumber(txt)
								return texture
							end
						end
					end
				end
			elseif t.Name == "Center: Main Rotation (Meta)" then -- shadowlands
               local i = t[1]
				if i then
					local ia = i.animation_overlay
					if ia then
						local txt = ia:GetTexture()
						if txt then
							local texture = tonumber(txt)
							return texture
						end
					else
						local ib = i.lmbButtonData.Icon
						if ib then
							local txt = ib:GetTexture()
							if txt then
								local texture = tonumber(txt)
								return texture
							end
						end
					end
				end
            end
         end
      end
   end
   return nil
end

function _CBLD.ShowTmw()
	local texture = _CBLD.TmwGetMainTexture()
	if texture == nil then
		CrazyFrame[0].t:SetColorTexture(0.0 ,0.0,0.0)
		return
	end
	--debugTexture:SetTexture(texture);
	local id = BindingTable.buttonTextureFrom[texture]
	if id then
		local tid = tonumber(id)
		_CBLD.ShowOther(0, tid)	
	else
		CrazyFrame[0].t:SetColorTexture(0.0 ,0.0,0.0)
	end	
	
end

function _CBLD.WeekSpell()
    if WeakAuras.GetRegion("StarTrek") == nil then
        return nil
    end
    region = WeakAuras.GetData("StarTrek")
    for index, regionName in pairs(region.controlledChildren) do
        local regionData = WeakAuras.GetRegion(regionName)
        if regionData.toShow == true then
			if regionData.customTextFunc ~= nil then
				local a = regionData.customTextFunc()
				return a
			end
        end
   end
   return nil
end

function _CBLD.WeekSpellFromTexture()
    if WeakAuras.GetRegion("StarTrek") == nil then
        return nil
    end
    region = WeakAuras.GetData("StarTrek")
    for index, regionName in pairs(region.controlledChildren) do
        local regionData = WeakAuras.GetRegion(regionName)
        if regionData.toShow == true then
			local texture = regionData.icon:GetTexture()
			if texture then
				local txt = tonumber(texture)
				if txt then
					local id = BindingTable.buttonTextureFrom[txt]
					if id then
						local tid = tonumber(id)
						--debugTexture:SetTexture(texture);
						_CBLD.ShowOther(0, tid)	
						return;
					end
				end
			end
        end
   end
   CrazyFrame[0].t:SetColorTexture(0.0 ,0.0,0.0)
end

function _CBLD.SpellCd(skill)
	local start, duration, enabled, modrrate = GetSpellCooldown(skill)
	local cdLeft = start + duration - GetTime()
	if cdLeft < 0.1 then
		return true
	end	
	return false
end

function _CBLD.ItemCd(skill)
	local start, duration, enabled = GetItemCooldown(skill)
	local cdLeft = start + duration - GetTime()
	if cdLeft < 0.1 then
		return true
	end	
	return false
end

function _CBLD.IsPlayerChn()
	local Channeling = select(1, UnitChannelInfo("player"))
	if Channeling ~= nil then
		return true
	else
		return false
	end		
end

function _CBLD.IsPlayerCst()
	local Casting = select(1, UnitCastingInfo("player"))
	if Casting ~= nil then
		return true
	else
		return false
	end	
end

function _CBLD.PushDefaultData2Screen()


	local exists = UnitExists("target")
	if (exists == false) then
		CrazyFrame[12].t:SetColorTexture(0.004 ,0.0,0.0)
	else
		CrazyFrame[12].t:SetColorTexture(0.000 ,0.0,0.0)
	end
	-- если ткрыт чат бар
	if  ACTIVE_CHAT_EDIT_BOX then
		CrazyFrame[13].t:SetColorTexture(0.004 ,0.0,0.0)
	else
		CrazyFrame[13].t:SetColorTexture(0.0 ,0.0,0.0)
	end

	-- если верхом
	if  IsMounted() then
		CrazyFrame[14].t:SetColorTexture(0.004 ,0.0,0.0)
	else
		CrazyFrame[14].t:SetColorTexture(0.0 ,0.0,0.0)
	end
	
	-- если цель мертва
	if  UnitIsDead("target") then
		CrazyFrame[15].t:SetColorTexture(0.004 ,0.0,0.0)
	else
		CrazyFrame[15].t:SetColorTexture(0.0 ,0.0,0.0)
	end
	
	-- если дружественная - состояние вне боя
	if  UnitIsFriend("player", "target") then
		CrazyFrame[16].t:SetColorTexture(0.004 ,0.0,0.0)
	else
		CrazyFrame[16].t:SetColorTexture(0.0 ,0.0,0.0)
	end
	
	-- если не в бою
	if  InCombatLockdown() == false then
		CrazyFrame[18].t:SetColorTexture(0.004 ,0.0,0.0)
	else
		CrazyFrame[18].t:SetColorTexture(0.0 ,0.0,0.0)
	end
	
	-- цель не атакует
	if  UnitCanAttack("player","target") == true then
		CrazyFrame[19].t:SetColorTexture(0.0 ,0.0,0.0)
	else
		CrazyFrame[19].t:SetColorTexture(0.004 ,0.0,0.0)
	end
	
	if _CBLD.IsPlayerCst() == true then
		CrazyFrame[20].t:SetColorTexture(0.004 ,0.0,0.0)	
		--print("cast")
	else
		CrazyFrame[20].t:SetColorTexture(0.0,0.0,0.0)
		--print("no cast")
	end
	
	if _CBLD.IsPlayerChn() == true then
		CrazyFrame[21].t:SetColorTexture(0.004 ,0.0,0.0)	
		--print("chn")
	else
		CrazyFrame[21].t:SetColorTexture(0.0,0.0,0.0)
		--print("no cn")
	end
	
	-- если долго кастуем до подсветим полосу черным
	-----------------------------if _CBLD.IsPlayerCasting() == true then 
	-----------------------------	CrazyFrame[20].t:SetColorTexture(0.004 ,0.0,0.0)	
	-----------------------------else
	-----------------------------	CrazyFrame[20].t:SetColorTexture(0.0,0.0,0.0)
	-----------------------------end
	
	-- если туннелим
	------------------------if _CBLD.IsPlayerChanneling() == true then 
	------------------------	CrazyFrame[21].t:SetColorTexture(0.004 ,0.0,0.0)	
	------------------------else
	------------------------	CrazyFrame[21].t:SetColorTexture(0.0,0.0,0.0)
	------------------------end	
	-- пока не работает	
	--local usable, nomana = IsUsableSpell(actionId);
	--if (not usable) then
	--	CrazyFrame[10].t:SetColorTexture(0.004 ,0.0,0.0)	
	--else
	--	CrazyFrame[10].t:SetColorTexture(0.0,0.0,0.0)
	--end
	--if (nomana) then
	--	CrazyFrame[11].t:SetColorTexture(0.004 ,0.0,0.0)	
	--else
		CrazyFrame[11].t:SetColorTexture(0.0,0.0,0.0)
	--end	

	

end


function reset_ui_error()
	CrazyFrame[10].t:SetColorTexture(0.0,0.0,0.0)
end
function OnUIErrorMessage(self, event, messageType, message)
  local errorName, soundKitID, voiceID = GetGameMessageInfo(messageType)
  --if blacklist[errorName] then return end 
  --print(errorName)
  if errorName then
	if errorName == "ERR_SPELL_OUT_OF_RANGE" or errorName == "ERR_BADATTACKFACING" or errorName == "ERR_SPELL_FAILED_S" then
		CrazyFrame[10].t:SetColorTexture(0.004 ,0.0,0.0)
		C_Timer.After(2, reset_ui_error)
	end
  end
  --if(NMD_ROOT.ui_errors[errorName] ~= nil) then
--	C_Timer.After(1, reset_ui_error)
--  end
  UIErrorsFrame:AddMessage(message, 1, .1, .1)
  --print(NMD_ROOT.ui_errors[errorName])
end
UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
local UIErrorsEventHandler = CreateFrame("Frame")
UIErrorsEventHandler:SetScript("OnEvent", OnUIErrorMessage)
UIErrorsEventHandler:RegisterEvent("UI_ERROR_MESSAGE")



local function info_message(msg, editbox)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	--print(args)
	if cmd == "bind" then
		_CBLD.BindSnap()
	elseif cmd == "sdfsdf"then

	elseif cmd == "bags"then

	elseif cmd == "openallmail"then
	
	elseif cmd == "depo"then

	elseif cmd == "flying"then

	elseif cmd == "puttobank"then

	elseif cmd == "summount"then

	elseif msg == "next_auc"then

	elseif cmd == "trgt"then

	end
end
--1238964532348905534567671111


if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
    combination_food = { 113509, 80618, 80610, 65499, 43523, 43518, 65517, 65516, 65515, 65500 }
    multiinsert(mana_potions, { 152495, 127835, 109222, 76098, 57192, 33448, 40067, 31677, 22732, 28101 })
    multiinsert(healing_potions, { 169451, 152494, 127834, 152615, 109223, 57191, 39671, 22829, 28100 })
    multiinsert(bandages, { 158382, 158381, 133942, 133940, 111603, 72986, 72985, 53051, 53050, 53049, 34722, 34721, 21991, 21990 })
    multiinsert(healthstones, { 
            "Legion Healthstone",
            "Fel Healthstone",
            "Demonic Healthstone",
            "Master Healthstone",
    })
elseif (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC) then
    combination_food = { 34062 }
    multiinsert(conjured_food, { 22019 })
    multiinsert(conjured_water, { 22018, 30703, })
    multiinsert(mana_potions, { 31677, 33093, 23823, 22832, 32948, 33935, 28101 })
    multiinsert(healing_potions, { 33092, 23822, 22829, 32947, 28100, 33934 })
    multiinsert(bandages, { 21991, 21990, 23684 })
    multiinsert(purchased_water, { 33042, 29395, 27860, 32453, 38430, 28399, 29454, 32455, 24007, 24006, 23161 })
    multiinsert(healthstones, { 
            "Master Healthstone",
    })
end

local defaults = {
    profile = {
        enable = true,
        poll = 0.15,
        ignore_mana = false,
        ignore_range = false,
        effect = "Ping",
        color = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
        magnification = 1.4,
        setpoint = 'CENTER',
        xoffs = 0,
        yoffs = 0,
        loglevel = 2,
        detailed_profiling = false,
        disable_autoswitch = false,
        live_config_update = 2,
        spell_history = 60,
        combat_history = 10,
        damage_history = 30,
        minimap = {
            hide = false,
        }
    },
    char = {
        rotations = {},
        itemsets = {},
        bindings = {},
        announces = {},
    },
    global = {
        itemsets = {
            ["e8d1525c-0412-40c1-95a4-00da22bc169e"] = {
                name = "Combination Food",
                items = combination_food,
            },
            ["e626834f-60b1-413f-9c87-8ddeeb4374aa"] = {
                name = "Conjured Food",
                items = conjured_food,
            },
            ["3b10f7d6-abb2-430c-b153-7189eca75838"] = {
                name = "Conjured Water",
                items = conjured_water,
            },
	    ["6079c534-5f69-430e-b1bd-b487a31dcdd3"] = {
		name = "Mana Potions",
		items = mana_potions,
	    },
	    ["9294d112-681b-43bc-ac62-5d6bec5c1f7d"] = {
		name = "Healing Potions",
		items = healing_potions,
	    },
	    ["e66d5cfe-a0f0-4276-aa00-40464eab30df"] = {
		name = "Bandages",
		items = bandages,
	    },
	    ["b1aca4a4-acdd-4885-b63b-b62cca7afdfe"] = {
		name = "Purchased Water",
		items = purchased_water,
	    },
	    ["fed2659d-cb7b-43e1-8f53-6dda0391b8c6"] = {
		name = "Healthstones",
		items = healthstones,
	    }
        },
        effects = {
            {
                type = "texture",
                name = "Ping",
                texture = "Interface\\Cooldown\\ping4",
            },
            {
                type = "texture",
                name = "Star",
                texture = "Interface\\Cooldown\\star4",
            },
            {
                type = "texture",
                name = "Starburst",
                texture = "Interface\\Cooldown\\starburst",
            },
            {
                type = "blizzard",
                name = "Glow",
            },
            {
                type = "pixel",
                name = "Pixel",
            },
            {
                type = "autocast",
                name = "Auto Cast",
            }
        },
    }
}

local events = {
    -- Conditions that indicate a major combat event that should trigger an immediate
    -- evaluation of the rotation conditions (or will disable your rotation entirely).
    'PLAYER_TARGET_CHANGED',
    'PLAYER_REGEN_DISABLED',
    'PLAYER_REGEN_ENABLED',
    'UNIT_PET',
    'PLAYER_CONTROL_GAINED',
    'PLAYER_CONTROL_LOST',
    "UPDATE_STEALTH",

    -- Conditions that affect whether the rotation should be switched.
    'ZONE_CHANGED',
    'ZONE_CHANGED_INDOORS',
    'GROUP_ROSTER_UPDATE',
    'CHARACTER_POINTS_CHANGED',
    "PLAYER_FLAGS_CHANGED",
    "UPDATE_SHAPESHIFT_FORM",

    -- Conditions that affect affect the contents of highlighted buttons.
    'ACTIONBAR_SLOT_CHANGED',
    'PET_BAR_UPDATE',
    'PLAYER_ENTERING_WORLD',
    'ACTIONBAR_HIDEGRID',
    'PET_BAR_HIDEGRID',
    'ACTIONBAR_PAGE_CHANGED',
    'LEARNED_SPELL_IN_TAB',
    'UPDATE_MACROS',

    -- Special Purpose
    'NAME_PLATE_UNIT_ADDED',
    'NAME_PLATE_UNIT_REMOVED',

    'BAG_UPDATE',
    'UNIT_COMBAT',

    "UNIT_SPELLCAST_SENT",
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",

    "COMBAT_LOG_EVENT_UNFILTERED",
}

local mainline_events = {
    'PLAYER_FOCUS_CHANGED',
    'VEHICLE_UPDATE',
    'UNIT_ENTERED_VEHICLE',
    'PLAYER_TALENT_UPDATE',
    'ACTIVE_TALENT_GROUP_CHANGED',
    'PLAYER_SPECIALIZATION_CHANGED',
}

local tbc_events = {
    'PLAYER_FOCUS_CHANGED',
}

local classic_events = {

}

function addon:HandleCommand(str)
    local cmd, npos = AceConsole:GetArgs(str, 1, 1)

    if not cmd or cmd == "help" then
        addon:print(L["/rm help                - This text"])
        addon:print(L["/rm config              - Open the config dialog"])
        addon:print(L["/rm disable             - Disable battle rotation"])
        addon:print(L["/rm enable              - Enable battle rotation"])
        addon:print(L["/rm toggle              - Toggle between enabled and disabled"])
        addon:print(L["/rm current             - Print out the name of the current rotation"])
        addon:print(L["/rm set [auto|profile]  - Switch to a specific rotation, or use automatic switching again."])
        addon:print(L["                          This is reset upon switching specializations."])

    elseif cmd == "config" then
        InterfaceOptionsFrame_OpenToCategory(addon.Rotation)
        InterfaceOptionsFrame_OpenToCategory(addon.Rotation)

    elseif cmd == "disable" then
        addon:disable()

    elseif cmd == "enable" then
        addon:enable()

    elseif cmd == "toggle" then
        if addon.playerUnitFrame then
            addon:disable()
        else
            addon:enable()
        end

    elseif cmd == "current" then
        if self.currentRotation == nil then
            addon:print(L["No rotation is currently active."])
        else
            addon:print(L["The current rotation is " .. color.WHITE .. "%s" .. color.INFO], addon:GetRotationName(self.currentRotation))
        end

    elseif cmd == "set" then
        local name = string.sub(str, npos)

        if name == "auto" then
            self.manualRotation = false
            self:SwitchRotation()
        elseif name == self.currentRotation then
            self.manualRotation = true
            addon:info(L["Active rotation manually switched to " .. color.WHITE .. "%s" .. color.INFO], name)
        elseif name == DEFAULT then
            self:RemoveAllCurrentGlows()
            self.manualRotation = true
            self.currentRotation = DEFAULT
            self.skipAnnounce = true
            self.avail_announced = {}
            self.announced = {}
            self:EnableRotationTimer()
            DataBroker.text = self:GetRotationName(DEFAULT)
            AceEvent:SendMessage("ROTATIONMASTER_ROTATION", self.currentRotation, self:GetRotationName(self.currentRotation))
            addon:info(L["Active rotation manually switched to " .. color.WHITE .. "%s" .. color.INFO], name)
        else
            if self.db.char.rotations[self.currentSpec] ~= nil then
                for id, rot in pairs(self.db.char.rotations[self.currentSpec]) do
                    if rot.name == name then
                        self:RemoveAllCurrentGlows()
                        self.manualRotation = true
                        self.currentRotation = id
                        self.skipAnnounce = true
                        self.avail_announced = {}
                        self.announced = {}
                        self:EnableRotationTimer()
                        DataBroker.text = self:GetRotationName(id)
                        AceEvent:SendMessage("ROTATIONMASTER_ROTATION", self.currentRotation, self:GetRotationName(self.currentRotation))
                        addon:info(L["Active rotation manually switched to " .. color.WHITE .. "%s" .. color.INFO], name)
                        if (not self:rotationValidConditions(rot, self.currentSpec)) then
                            addon:warn(L["Active rotation is incomplete and may not work correctly!"])
                        end
                        return
                    end
                end
            end
            addon:warn(L["Could not find rotation named " .. color.WHITE .. "%s" .. color.WARN .. " for your current specialization."], name)
        end
    else
        addon:warn(L["Invalid option " .. color.WHITE .. "%s" .. color.WARN], cmd)
    end
end

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RotationMasterDB", defaults, true)

    self:upgrade()

    AceConsole:RegisterChatCommand("rm", function(str)
        addon:HandleCommand(str)
    end)
    AceConsole:RegisterChatCommand("rotationmaster", function(str)
        addon:HandleCommand(str)
    end)
    if type(self.db.profile.minimap) == "boolean" then
        self.db.profile.minimap = nil
    end
    DBIcon:Register(addon.name, DataBroker, self.db.profile.minimap)
    DataBroker.text = color.RED .. OFF

    -- These values are cached for the entire time you are in combat.  Their values
    -- are unlikely to change during combat (and if they do, they will have minimal effect)
    self.combatCache = {}

    -- These values are cached until the cache is reset (spec change, etc).  Their values
    -- will not change without a respec (or sometimes never).
    self.longtermCache = {}

    self.currentSpec = nil
    self.currentForm = nil

    -- This is a list of rotations that are available (ie. they are complete).  So we don't
    -- have to call validate in a time of battle.
    self.autoswitchRotation = {}

    self.currentRotation = nil
    self.manualRotation = false

    self.inCombat = false

    self.rotationTimer = nil
    self.fetchTimer = nil
    self.shapeshiftTimer = nil

    -- This is a cache of spec based spell names -> IDs.  Updated when we switch specs.
    self.specSpells = nil
    self.bagContents = {}

    self.specTalents = {}

    self.unitsInRange = {}
    self.damageHistory = {}
    self.lastMainSwing = nil
    self.lastOffSwing = nil

    self.spellHistory = {}
    self.combatHistory = {}
    self.playerUnitFrame = nil

    self.avail_announced = {}
    self.announced = {}
    self.skipAnnounce = true

    self.currentConditionEval = nil
    self.conditionEvalTimer = nil
    self.lastCacheReport = GetTime()

    self.itemSetButtons = {}
    self.itemSetCallback = nil
    self.bindingItemSet = nil

    self.evaluationProfile = addon:ProfiledCode()

    -- This is here because of order of loading.
    getCached = addon.getCached
    getRetryCached = addon.getRetryCached
end

function addon:GetRotationName(id)
    if id == DEFAULT then
        return DEFAULT
    elseif self.db.char.rotations[self.currentSpec] ~= nil  and
           self.db.char.rotations[self.currentSpec][id] ~= nil then
        return self.db.char.rotations[self.currentSpec][id].name
    else
        return nil
    end
end

local function minimapToggleRotation(_, _, _, checked)
    if checked then
        addon:enable()
    else
        addon:disable()
    end
end

local function minimapChangeRotation(_, arg1, _, _)
    if arg1 == nil then
        addon.manualRotation = false
        addon:SwitchRotation()
    else
        addon.manualRotation = true
        if addon.currentSpec ~= arg1 then
            addon:RemoveAllCurrentGlows()
            addon.currentRotation = arg1
            addon.skipAnnounce = true
            addon.avail_announced = {}
            addon.announced = {}
            addon:EnableRotationTimer()
            DataBroker.text = addon:GetRotationName(arg1)
            AceEvent:SendMessage("ROTATIONMASTER_ROTATION", addon.currentRotation, addon:GetRotationName(addon.currentRotation))
        end
        addon:info(L["Active rotation manually switched to " .. color.WHITE .. "%s" .. color.INFO],
                addon:GetRotationName(arg1))
    end
end

function minimapInitialize()
    local info = UIDropDownMenu_CreateInfo()
    info.text = addon.pretty_name
    info.isTitle = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)
    info = UIDropDownMenu_CreateInfo()
    info.isNotRadio = true
    info.keepShownOnClick = true
    info.text, info.checked = L["Battle rotation enabled"], addon.db.profile.enable
    info.func = minimapToggleRotation
    UIDropDownMenu_AddButton(info)
    info = UIDropDownMenu_CreateInfo()
    info.text = " "
    info.notClickable = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)
    info.isTitle = true
    info.text = L["Current Rotation"]
    UIDropDownMenu_AddButton(info)
    info = UIDropDownMenu_CreateInfo()
    info.func = minimapChangeRotation
    info.text, info.arg1, info.checked = L["Automatic Switching"], nil, (addon.manualRotation == false)
    UIDropDownMenu_AddButton(info)
    info.text, info.arg1, info.checked = DEFAULT, DEFAULT, (addon.manualRotation == true and addon.currentRotation == DEFAULT)
    UIDropDownMenu_AddButton(info)
    if addon.db.char.rotations[addon.currentSpec] ~= nil then
        for id, rot in pairs(addon.db.char.rotations[addon.currentSpec]) do
            if id ~= DEFAULT then
                info.text, info.arg1, info.checked = rot.name, id, (addon.manualRotation == true and addon.currentRotation == id)
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end

function DataBroker.OnClick(_, button)
    local frame = CreateFrame("Frame", "RotationMasterLDBFrame")
    local dropdownFrame = CreateFrame("Frame", "RotationMasterLDBDropdownFrame", frame, "UIDropDownMenuTemplate")

    if button == "RightButton" then
        UIDropDownMenu_Initialize(dropdownFrame, minimapInitialize)
        ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
    elseif button == "LeftButton" then
        InterfaceOptionsFrame_OpenToCategory(addon.Rotation)
        InterfaceOptionsFrame_OpenToCategory(addon.Rotation)
    end
end

function DataBroker.OnTooltipShow(GameTooltip)
    GameTooltip:SetText(addon.pretty_name .. " " .. GetAddOnMetadata(addon_name, "Version"), 0, 1, 1)
    GameTooltip:AddLine(" ")
    if addon.currentRotation ~= nil then
        GameTooltip:AddLine(L["Current Rotation"], 0.55, 0.78, 0.33, 1)
        GameTooltip:AddLine(addon:GetRotationName(addon.currentRotation), 1, 1, 1)
    else
        GameTooltip:AddLine(L["Battle rotation disabled"], 1, 0, 0, 1)
    end
end

function addon:toggle()
    if self.currentRotation == nil then
        self:enable()
    else
        self:disable()
    end
end

function addon:enable()
    for _, v in pairs(events) do
        self:RegisterEvent(v)
    end
    if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
        self.currentSpec = GetSpecializationInfo(GetSpecialization())
        if self.specTab then
            self.specTab:SelectTab(self.currentSpec)
        end
        for _, v in pairs(mainline_events) do
            self:RegisterEvent(v)
        end
    elseif (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC) then
        self.currentSpec = 0
        for _, v in pairs(tbc_events) do
            self:RegisterEvent(v)
        end
    elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then
        self.currentSpec = 0
        for _, v in pairs(classic_events) do
            self:RegisterEvent(v)
        end
    end

    self.playerUnitFrame = CreateFrame('Frame')
    self.playerUnitFrame:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')

    self.playerUnitFrame:SetScript('OnEvent', function(_, _, _, _, spellId)
        if IsPlayerSpell(spellId) then
            table.insert(self.spellHistory, 1, {
                spell = spellId,
                time = GetTime()
            })
        end
    end)

    self:UpdateSkills()
    self:EnableRotation()
end

function addon:disable()
    self:DisableRotation()
    if self.playerUnitFrame ~= nil then
        self.playerUnitFrame:UnregisterAllEvents()
    end
    self.playerUnitFrame = nil
    self.spellHistory = {}
    self.combatHistory = {}
    self:UnregisterAllEvents()
end

function addon:OnEnable()
    self:info(L["Starting up version %s"], GetAddOnMetadata(addon_name, "Version"))

    if self.db.profile.live_config_update and not self.conditionEvalTimer then
        self.conditionEvalTimer = self:ScheduleRepeatingTimer('UpdateCurrentCondition', self.db.profile.live_config_update)
    end

    if self.db.profile.enable then
        self:enable()
    end
end

function addon:rotationValidConditions(rot, spec)
    local itemsets = self.db.char.itemsets
    local global_itemsets = self.db.global.itemsets

    -- We found a cooldown OR a rotation step
    local itemfound = false
    if rot.cooldowns ~= nil then
        -- All cooldowns are valid
        for _, v in pairs(rot.cooldowns) do
            if not v.disabled then
                if (v.type == nil or v.action == nil or not self:validateCondition(v.conditions, spec)) then
                    return false
                end
                if v.type == "item" then
                    if type(v.action) == "string" then
                        local itemset
                        if itemsets[v.action] ~= nil then
                            itemset = itemsets[v.action]
                        elseif global_itemsets[v.action] ~= nil then
                            itemset = global_itemsets[v.action]
                        end
                        if not itemset or #itemset.items == 0 then
                            return false
                        end
                    else
                        if #v.action == 0 then
                            return false
                        end
                    end
                end
                itemfound = true
            end
        end
    end
    if rot.rotation ~= nil then
        -- All rotation steps are valid
        for _, v in pairs(rot.rotation) do
            if not v.disabled then
                if (v.type == nil or v.action == nil or not self:validateCondition(v.conditions, spec)) then
                    return false
                end
                if v.type == "item" then
                    if type(v.action) == "string" then
                        local itemset
                        if itemsets[v.action] ~= nil then
                            itemset = itemsets[v.action]
                        elseif global_itemsets[v.action] ~= nil then
                            itemset = global_itemsets[v.action]
                        end
                        if not itemset or #itemset.items == 0 then
                            return false
                        end
                    else
                        if #v.action == 0 then
                            return false
                        end
                    end
                end
                itemfound = true
            end
        end
    end

    return itemfound
end

function addon:UpdateAutoSwitch()
    self.autoswitchRotation = {}

    if self.db.char.rotations[self.currentSpec] ~= nil then
        for id, rot in pairs(self.db.char.rotations[self.currentSpec]) do
            if id ~= DEFAULT then
                -- The switch condition is nontrivial and valid.
                if rot.switch and not rot.disabled and addon:usefulSwitchCondition(rot.switch) and
                        self:validateSwitchCondition(rot.switch, self.currentSpec) and
                        self:rotationValidConditions(rot, self.currentSpec) then
                    addon:debug(L["Rotaion " .. color.WHITE .. "%s" .. color.DEBUG .. " is now available for auto-switching."], rot.name)
                    table.insert(self.autoswitchRotation, id)
                end
            end
        end
    end

    -- We autoswitch to the lowest (alphabetically) matching rotation.
    table.sort(self.autoswitchRotation, function(lhs, rhs)
        return self.db.char.rotations[self.currentSpec][lhs].name <
                self.db.char.rotations[self.currentSpec][rhs].name
    end)

    addon:debug(L["Autoswitch rotation list has been updated."])
end

-- Figure out which of the autoswitch rotations best matches
function addon:SwitchRotation()
    if self.db.profile.disable_autoswitch or self.manualRotation then
        return
    end

    local newRotation
    for _, v in pairs(self.autoswitchRotation) do
        if addon:evaluateSwitchCondition(self.db.char.rotations[self.currentSpec][v].switch) then
            newRotation = v
            break
        end
    end
    if not newRotation and self.db.char.rotations[self.currentSpec] ~= nil and
        self.db.char.rotations[self.currentSpec][DEFAULT] ~= nil and
        self:rotationValidConditions(self.db.char.rotations[self.currentSpec][DEFAULT], self.currentSpec) then
        newRotation = DEFAULT
    end

    if newRotation then
        if self.currentRotation ~= newRotation then
            addon:info(L["Active rotation automatically switched to " .. color.WHITE .. "%s" .. color.INFO], self:GetRotationName(newRotation))
            self:RemoveAllCurrentGlows()
            self.currentRotation = newRotation
            self.skipAnnounce = true
            self.avail_announced = {}
            self.announced = {}
            self:EnableRotationTimer()
            DataBroker.text = self:GetRotationName(newRotation)
            AceEvent:SendMessage("ROTATIONMASTER_ROTATION", self.currentRotation, self:GetRotationName(self.currentRotation))
        end
        return
    end

    -- Could not find a rotation to switch to, even the default one.
    if self.currentRotation ~= nil then
        addon:warn(L["No rotation is active as there is none suitable to automatically switch to."])
        self:DisableRotation()
    end
end

function addon:EnableRotation()
    if self.currentRotation then
        return
    end

    self:Fetch()
    self:UpdateAutoSwitch()
    self:SwitchRotation()
    if self.currentRotation ~= nil then
        DataBroker.text = self:GetRotationName(self.currentRotation)
        addon:info(L["Battle rotation enabled"])
    end
end

function addon:DisableRotation()
    if not self.currentRotation then
        return
    end

    self:DisableRotationTimer()
    self:RemoveAllCurrentGlows()
    self:DestroyAllOverlays()
    self.currentRotation = nil
    DataBroker.text = color.RED .. OFF
    AceEvent:SendMessage("ROTATIONMASTER_ROTATION", nil)
    addon:info(L["Battle rotation disabled"])
end

function addon:EnableRotationTimer()
    if self.currentRotation and not self.rotationTimer then
        self.rotationTimer = self:ScheduleRepeatingTimer('EvaluateNextAction', self.db.profile.poll)
    end
end

function addon:DisableRotationTimer()
    if self.rotationTimer then
        self:CancelTimer(self.rotationTimer)
        self.rotationTimer = nil
    end
end

function addon:ButtonFetch()
    if self.fetchTimer then
        self:CancelTimer(self.fetchTimer)
    end
    self.fetchTimer = self:ScheduleTimer('Fetch', 0.25)
end

local function CreateUnitInfo(cache, unit)
    local info = {
        unit = unit,
        name = getCached(cache, UnitName, unit),
        attackable = getCached(cache, UnitCanAttack, "player", unit),
        enemy = getCached(cache, UnitIsEnemy, "player", unit),
    }
    if info.enemy then
        info.threat = getCached(cache, UnitThreatSituation, "player", unit)
    end
    return info
end

local function UpdateUnitInfo(cache, record)
    if not getCached(cache, UnitExists, record.unit) then
        return
    end

    record.attackable = getCached(cache, UnitCanAttack, "player", record.unit)
    record.enemy = getCached(cache, UnitIsEnemy, "player", record.unit)
    if record.enemy then
        record.threat = getCached(cache, UnitThreatSituation, "player", record.unit)
    else
        record.threat = nil
    end
end

local function announce(cache, cond, text)
    local dest
    if cond.announce == "local" then
        addon:announce(text)
    elseif cond.announce == "partyraid" then
        if getCached(cache, IsInRaid) then
            dest = "RAID"
        elseif getCached(cache, IsInGroup) then
            dest = "PARTY"
        else
            addon:announce(text)
        end
    elseif cond.announce == "party" then
        if getCached(cache, IsInGroup) then
            dest = "PARTY"
        end
    elseif cond.announce == "raidwarn" then
        if getCached(cache, IsInRaid) then
            if getCached(cache, IsRaidLeader) then
                dest = "RAID_WARNING"
            else
                dest = "RAID"
            end
        elseif getCached(cache, IsInGroup) then
            dest = "PARTY"
        else
            addon:announce(text)
        end
    elseif cond.announce == "say" then
        dest = "SAY"
    elseif cond.announce == "yell" then
        dest = "YELL"
    elseif cond.announce == "emote" then
        dest = "EMOTE"
    end
    if dest ~= nil then
        SendChatMessage(text, dest)
    end
end

function addon:EvaluateNextAction()
    if self.currentRotation == nil then
        addon:DisableRotationTimer()
    elseif self.db.char.rotations[self.currentSpec] ~= nil and
            self.db.char.rotations[self.currentSpec][self.currentRotation] ~= nil then
        self.evaluationProfile:start()

        local now = GetTime()
        local cache = {}
        if not self.inCombat then
            self.combatCache = cache
        end

        local newForm = getCached(cache, GetShapeshiftForm)
        if self.currentForm ~= newForm then
            self.skipAnnounce = true
            self.currentForm = newForm
        end

        self.evaluationProfile:child("environment"):start()

        local unitsHandled, unitsGUID = {}, {}
        for unit, _ in pairs(addon.units) do
            unitsGUID[unit] = getCached(cache, UnitGUID, unit)
        end
        for guid, entity in pairs(self.unitsInRange) do
            if isin(addon.units, entity.unit) then
		        if unitsGUID[entity.unit] and unitsGUID[entity.unit] == guid then
                    unitsHandled[entity.unit] = true
                else
                    self.unitsInRange[guid] = nil
                end
            end

            addon:verbose("Updating Unit " .. guid .. " (" .. entity.name .. ")")
            UpdateUnitInfo(cache, entity)
        end
        for unit, guid in pairs(unitsGUID) do
            if not unitsHandled[unit] and not self.unitsInRange[guid] and
                not starts_with(unit, "mouseover") then
                self.unitsInRange[guid] = CreateUnitInfo(cache, unit)
            end
        end

        local threshold_time = now - self.db.profile.spell_history
        while #self.spellHistory ~= 0 do
            if self.spellHistory[#self.spellHistory].time < threshold_time then
                table.remove(self.spellHistory, #self.spellHistory)
            else
                break
            end
        end

        threshold_time = now - self.db.profile.combat_history
        for _,history in pairs(self.combatHistory) do
            while #history ~= 0 do
                if history[#history].time < threshold_time then
                    table.remove(history, #history)
                else
                    break
                end
            end
        end
        self.evaluationProfile:child("environment"):stop()

        threshold_time = now - self.db.profile.damage_history
        for guid, entry in pairs(self.damageHistory) do
            while #entry.heals ~= 0 do
                if entry.heals[#entry.heals].time < threshold_time then
                    table.remove(entry.heals, #entry.heals)
                else
                    break
                end
            end
            while #entry.damage ~= 0 do
                if entry.damage[#entry.damage].time < threshold_time then
                    table.remove(entry.damage, #entry.damage)
                else
                    break
                end
            end
            if #entry.heals == 0 and #entry.damage == 0 then
                self.damageHistory[guid] = nil
            end
        end

        -- The common way to evaluate any rotation or cooldown condition.
        local function eval(cond)
            local spellid, enabled = nil, false
            if cond.action ~= nil and (cond.disabled == nil or cond.disabled == false) then
                local spellids, itemids
                if cond.type ~= "pet" or getCached(self.longtermCache, IsSpellKnown, cond.action, true) then
                    spellids, itemids = addon:GetSpellIds(cond)
                end

                if spellids ~= nil then
                    local idx
                    spellid, idx = addon:FindSpell(spellids)
                    if (spellid and addon:evaluateCondition(cond.conditions)) then
                        local avail, nomana = getCached(cache, IsUsableSpell, spellid)
                        if avail and (self.db.profile.ignore_mana or not nomana) then
                            if self.db.profile.ignore_range then
                                enabled = true
                            else
                                local inrange
                                if cond.type == "spell" then
                                    local sbid = getCached(addon.longtermCache, FindSpellBookSlotBySpellID, spellid, false)
                                    inrange = getCached(cache, IsSpellInRange, sbid, BOOKTYPE_SPELL, "target")
                                elseif cond.type == "pet" then
                                    local sbid = getCached(addon.longtermCache, FindSpellBookSlotBySpellID, spellid, true)
                                    inrange = getCached(cache, IsSpellInRange, sbid, BOOKTYPE_PET, "target")
                                elseif cond.type == "item" then
                                    inrange = getCached(cache, IsItemInRange, itemids[idx], "target")
                                end
                                enabled = (inrange ~= nil and inrange or true)
if spellid then local SpellId = tonumber(spellid) if SpellId ~= nil then _CBLD.ShowOther(0, SpellId) end end
                            end
                        end
                    end
                end
            end
            return spellid, enabled
        end

        self.evaluationProfile:child("rotation"):start()
        local rot = self.db.char.rotations[self.currentSpec][self.currentRotation]
        if rot.rotation ~= nil then
            local enabled
            for id, cond in pairs(rot.rotation) do
                local spellid
                spellid, enabled = eval(cond)
                if spellid and enabled then
                    addon:verbose("Rotation step %d satisfied it's condition.", id)
                    if not addon:IsGlowing(spellid) then
                        addon:GlowNextSpell(spellid)
                        if WeakAuras then
                            WeakAuras.ScanEvents("ROTATIONMASTER_SPELL_UPDATE", cond.type, spellid)
                        end
                        AceEvent:SendMessage("ROTATIONMASTER_SPELL_UPDATE", self.currentRotation, id, cond.id, cond.type, spellid)
                    end
                    break
                else
                    addon:verbose("Rotation step %d did not satisfy it's condition.", id)
                end
            end
            if not enabled then
                addon:GlowClear()
                if WeakAuras then
                    WeakAuras.ScanEvents("ROTATIONMASTER_SPELL_UPDATE", nil, nil)
                end
                AceEvent:SendMessage("ROTATIONMASTER_SPELL_UPDATE", self.currentRotation, nil)
            end
        end
        self.evaluationProfile:child("rotation"):stop()
        self.evaluationProfile:child("cooldowns"):start()
        if rot.cooldowns ~= nil then
            local enabled_cooldowns = {}
            local disabled_cooldowns = {}
            for id, cond in pairs(rot.cooldowns) do
                local spellid, enabled = eval(cond)
                if spellid then
                    if enabled then
                        addon:verbose("Cooldown %d [%s] is enabled", id, cond.id)
                        if addon.avail_announced[cond.id] ~= spellid then
                            if not addon.skipAnnounce then
                                local link = getCached(addon.longtermCache, GetSpellLink, spellid)
                                announce(cache, cond, string.format(L["%s is now available!"], link))
                            end
                            addon.avail_announced[cond.id] = spellid;
                            AceEvent:SendMessage("ROTATIONMASTER_COOLDOWN_UPDATE", self.currentRotation, id, cond.id, cond.type, spellid)
                        end
                        if not enabled_cooldowns[spellid] then
                            enabled_cooldowns[spellid] = cond
                            disabled_cooldowns[spellid] = nil
                        end
                    else
                        if addon.avail_announced[cond.id] then
                            addon.avail_announced[cond.id] = nil;
                            AceEvent:SendMessage("ROTATIONMASTER_COOLDOWN_UPDATE", self.currentRotation, id, cond.id, nil)
                        end
                        addon:verbose("Cooldown %d [%s] is disabled", id, cond.id)
                        if not enabled_cooldowns[spellid] then
                            disabled_cooldowns[spellid] = cond
                        end
                    end
                else
                    if addon.avail_announced[cond.id] then
                        addon.avail_announced[cond.id] = nil;
                        AceEvent:SendMessage("ROTATIONMASTER_COOLDOWN_UPDATE", self.currentRotation, id, cond.id, nil)
                    end
                end
            end
            for spellid, cond in pairs(disabled_cooldowns) do
                addon:GlowCooldown(spellid, false, cond)
            end
            for spellid, cond in pairs(enabled_cooldowns) do
                addon:GlowCooldown(spellid, true, cond)
            end
        end
        self.evaluationProfile:child("cooldowns"):stop()

        -- We only skip the FIRST cycle of enabling/disabling cooldowns.
        addon.skipAnnounce = false
        addon.announced = {}

        self.evaluationProfile:stop()
    end

    if GetTime() - self.lastCacheReport > 15 then
        addon:ReportCacheStats()
        addon:debug("%s", self.evaluationProfile:report(self.db.profile.detailed_profiling))
        self.evaluationProfile:reset()
        self.lastCacheReport = GetTime()
    end
end

function addon:UpdateCurrentCondition()
    -- Update the live config config .. just to be nice :)
    if self.currentConditionEval ~= nil then
        self.currentConditionEval()
        addon:debug(L["Notified configuration to update it's status."])
    end
end

function addon:GetSpellIds(rot)
    if rot.action then
        if rot.type == "spell" or rot.type == "pet" then
            if (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE) then
                if rot.ranked then
                    return { rot.action }
                else
                    return SpellData:GetAllSpellIds(rot.action) or {}
                end
            else
                return { rot.action }
            end
        elseif rot.type == "item" then
            local spellids = {}
            local itemids = {}
            if type(rot.action) == "string" then
                local itemset
                if self.db.char.itemsets[rot.action] ~= nil then
                    itemset = self.db.char.itemsets[rot.action]
                elseif self.db.global.itemsets[rot.action] ~= nil then
                    itemset = self.db.global.itemsets[rot.action]
                end

                if itemset ~= nil then
                    for _, item in ipairs(itemset.items) do
                        local spellid = select(2, getRetryCached(self.longtermCache, GetItemSpell, item));
                        if spellid then
                            table.insert(spellids, spellid)
                            if isint(item) then
                                table.insert(itemids, item)
                            else
                                local itemid = getRetryCached(self.longtermCache, GetItemInfoInstant, item)
                                table.insert(itemids, itemid)
                            end
                        end
                    end
                end
            else
                for _, item in ipairs(rot.action) do
                    local spellid = select(2, getRetryCached(self.longtermCache, GetItemSpell, item));
                    if spellid then
                        table.insert(spellids, spellid)
                        if isint(item) then
                            table.insert(itemids, item)
                        else
                            local itemid = getRetryCached(self.longtermCache, GetItemInfoInstant, item)
                            table.insert(itemids, itemid)
                        end
                    end
                end
            end
            return spellids, itemids
        end
    end
    return {}
end

function addon:RemoveCooldownGlowIfCurrent(spec, rotation, rot)
    if spec == self.currentSpec and rotation == self.currentRotation then
        for _, spellid in pairs(addon:GetSpellIds(rot)) do
            addon:GlowCooldown(spellid, false)
        end
    end
end

function addon:RemoveAllCurrentGlows()
    addon:debug(L["Removing all glows."])
    if self.currentSpec ~= nil and self.currentRotation ~= nil and
        self.db.char.rotations[self.currentSpec][self.currentRotation] ~= nil and
        self.db.char.rotations[self.currentSpec][self.currentRotation].cooldowns ~= nil then
        for _, rot in pairs(self.db.char.rotations[self.currentSpec][self.currentRotation].cooldowns) do
            for _, spellid in pairs(addon:GetSpellIds(rot)) do
                addon:GlowCooldown(spellid, false)
            end
        end
        addon:GlowClear()
    end
end

function addon:UpdateSkills()
    addon:verbose("Skill update triggered")
    if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
        local spec = GetSpecializationInfo(GetSpecialization())
        if spec == nil then
            return
        end
        self.currentSpec = spec
        if self.specTab then
            self.specTab:SelectTab(spec)
        end
    end

    self:UpdateAutoSwitch()
    self:SwitchRotation()
    self:ButtonFetch()

    self.longtermCache = {}

    SpellData:UpdateFromSpellBook()
    if self.specSpells == nil then
        self.specSpells = {}
    end

    self.specSpells[self.currentSpec] = {}
    for i=1, GetNumSpellTabs() do
        local _, _, offset, numSpells, _, offspecId = GetSpellTabInfo(i)
        if offspecId == 0 then
            offspecId = self.currentSpec
        elseif (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
            self.specSpells[offspecId] = {}
        end
        for j = offset, offset + numSpells - 1 do
            local name, rank, spellId = GetSpellBookItemName(j, BOOKTYPE_SPELL)
            if (i == 1 and rank ~= nil and rank ~= "") then
                for _, prof in pairs(self.profession_levels) do
                    if rank == prof then
                        spellId = nil
                        break
                    end
                end
            end
            if spellId and not IsPassiveSpell(j, BOOKTYPE_SPELL) then
                self.specSpells[offspecId][name] = spellId
            end
        end
    end

    if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
        if self.specTalents[self.currentSpec] == nil then
            self.specTalents[self.currentSpec] = {}

            for i = 1, 21 do
                local _, name, icon = GetTalentInfo(floor((i - 1) / 3) + 1, ((i - 1) % 3) + 1, 1)
                self.specTalents[self.currentSpec][i] = {
                    name = name,
                    icon = icon
                }
            end
        end
    end
end

function addon:GetSpecSpellID(spec, name)
    if self.specSpells == nil or self.specSpells[spec] == nil then
        return nil
    end

    return self.specSpells[spec][name]
end

function addon:GetSpecTalentName(spec, idx)
    if idx == nil or idx < 1 or idx > 21 then
        return nil
    end

    if self.specTalents[spec] == nil or self.specTalents[spec][idx] == nil or self.specTalents[spec][idx].name == nil then
        return string.format(L["[Tier: %d, Column: %d]"], floor((idx - 1) / 3) + 1, ((idx - 1) % 3) + 1)
    end

    return self.specTalents[spec][idx].name
end

function addon:GetSpecTalentIcon(spec, idx)
    if idx == nil or idx < 1 or idx > 21 then
        return nil
    end

    if self.specTalents[spec] == nil or self.specTalents[spec][idx] == nil or self.specTalents[spec][idx].icon == nil then
        return "Interface\\Icons\\INV_Misc_QuestionMark"
    end

    return self.specTalents[spec][idx].icon
end

function addon:UpdateBoundButton(id)
    local bindings = self.db.char.bindings

    local slot = bindings[id]
    if slot then
        local type, actionType = GetActionInfo(slot);
        if type == "item" then
            local itemid = addon:FindFirstItemOfItemSet({}, id, true)
            if itemid and itemid ~= actionType then
                addon:debug("Updated slot %s to new item %d", slot, itemid)
                PickupItem(itemid)
                PlaceAction(slot)
                ClearCursor()
            end
        else
            bindings[id] = nil
        end
    end
end

-- The only action for ALL of these is to check to see if the rotation should be switched.
addon.PLAYER_FOCUS_CHANGED = addon.SwitchRotation
addon.PARTY_MEMBERS_CHANGED = addon.SwitchRotation
addon.PLAYER_FLAGS_CHANGED = addon.SwitchRotation
addon.UPDATE_SHAPESHIFT_FORM = function()
    -- We need the delay because multiple shapeshift events come in at once
    -- and there is no way to know which will be the final one.
    if addon.shapeshiftTimer == nil then
        addon.shapeshiftTimer = addon:ScheduleTimer(function ()
            addon.shapeshiftTimer = nil
            addon:SwitchRotation()
        end, 0.25)
        addon:ButtonFetch()
    end
end
addon.UPDATE_STEALTH = addon.SwitchRotation

addon.ACTIONBAR_SLOT_CHANGED = function(self, _, slot)
    local bindings = self.db.char.bindings
    addon:ButtonFetch()

    local pickupItemSet
    for id, bslot in pairs(bindings) do
        if bslot == slot then
            local type, action = GetCursorInfo()
            -- Sometimes we get this when we didn't actually pick up anything.  Odd.
            if type == "item" and addon:FindItemInItemSet(id, action) ~= nil then
                pickupItemSet = id
                bindings[id] = nil
                if addon.itemSetCallback then
                    addon.itemSetCallback(id)
                end
            end
        end
    end

    if addon.bindingItemSet then
        bindings[addon.bindingItemSet] = slot
        if addon.itemSetCallback then
            addon.itemSetCallback(addon.bindingItemSet)
        end
        addon.bindingItemSet = nil
    end

    if pickupItemSet ~= nil then
        addon.bindingItemSet = pickupItemSet
    end
end

addon.PET_BAR_HIDEGRID = addon.ButtonFetch
addon.ACTIONBAR_HIDEGRID = addon.ButtonFetch
addon.PET_BAR_UPDATE = addon.ButtonFetch
addon.ACTIONBAR_PAGE_CHANGED = addon.ButtonFetch
addon.UPDATE_MACROS = addon.ButtonFetch
addon.VEHICLE_UPDATE = addon.ButtonFetch

function addon:PLAYER_TARGET_CHANGED()
    addon:verbose("Player targeted something else.")
    if not self.inCombat then
        self:SwitchRotation()
    end

    self.lastMainSwing = nil
    self.lastOffSwing = nil

    self:EvaluateNextAction()
end

addon.PLAYER_FOCUS_CHANGED = function()
    addon:PLAYER_TARGET_CHANGED()
end

function addon:UNIT_PET(unit)
    if unit == "player" then
        SpellData:UpdateFromSpellBook()

        addon:verbose("Player changed pet.")
        if not self.inCombat then
            self:SwitchRotation()
        end

        self:EvaluateNextAction()
    end
end

function addon:PLAYER_CONTROL_GAINED()
    addon:verbose("Player regained control.")
    if not self.inCombat then
        self:SwitchRotation()
    end

    self:EnableRotationTimer()
    self:EvaluateNextAction()
end

function addon:UpdateBagContents(cache)
    self.bagContents = {}
    for i=0,4 do
        for j=1, GetContainerNumSlots(i) do
            local _, qty, _, _, _, _, _, _, _, itemId = getCached(cache, GetContainerItemInfo, i, j);
            if itemId then
                if self.bagContents[itemId] == nil then
                    self.bagContents[itemId] = {
                        count = qty,
                        spell = getRetryCached(addon.longtermCache, GetItemSpell, itemId),
                        slots = { j }
                    }
                else
                    self.bagContents[itemId].count = self.bagContents[itemId].count + qty
                    table.insert(self.bagContents[itemId].slots, j)
                end
            end
        end
    end
end

function addon:PLAYER_CONTROL_LOST()
    addon:verbose("Player lost control.")
    self:DisableRotationTimer()
    self:RemoveAllCurrentGlows()
end

addon.PLAYER_TALENT_UPDATE = addon.UpdateSkills
addon.ACTIVE_TALENT_GROUP_CHANGED = addon.UpdateSkills
addon.CHARACTER_POINTS_CHANGED = addon.UpdateSkills
addon.PLAYER_SPECIALIZATION_CHANGED = addon.UpdateSkills
addon.LEARNED_SPELL_IN_TAB = addon.UpdateSkills

function addon:ZONE_CHANGED()
    addon:verbose("Player switched zones.")
    if not self.inCombat then
        self:SwitchRotation()
    end
end

addon.ZONE_CHANGED_INDOORS = addon.ZONE_CHANGED
addon.GROUP_ROSTER_UPDATE = addon.ZONE_CHANGED

function addon:PLAYER_ENTERING_WORLD()
    local itemsets = self.db.char.itemsets
    local global_itemsets = self.db.global.itemsets
    local bindings = self.db.char.bindings

    addon:verbose("Player entered world.")
    self:UpdateButtonGlow()
    self:UpdateSkills()
    self:UpdateBagContents()

    for id, _ in pairs(bindings) do
        self:UpdateBoundButton(id)
    end

    for id, _ in pairs(itemsets) do
        self:UpdateItemSetButtons(id)
    end
    for id, _ in pairs(global_itemsets) do
        self:UpdateItemSetButtons(id)
    end
end

function addon:PLAYER_REGEN_DISABLED()
    addon:verbose("Player is in combat.")
    self.inCombat = true
    self.lastMainSwing = nil
    self.lastOffSwing = nil
    self.combatCache = {}
end

function addon:PLAYER_REGEN_ENABLED()
    addon:verbose("Player is out of combat.")
    self.inCombat = false
    self.lastMainSwing = nil
    self.lastOffSwing = nil
    self.combatCache = {}

    addon:SwitchRotation()
end

function addon:UNIT_ENTERED_VEHICLE(_, unit)
    if unit == "player" then
        addon:verbose("Player on a vehicle.")
        addon:PLAYER_CONTROL_LOST()
    end
end

function addon:UNIT_EXITED_VEHICLE(_, unit)
    if unit == "player" then
        addon:verbose("Player off a vehicle.")
        addon:PLAYER_CONTROL_GAINED()
    end
end

function addon:NAME_PLATE_UNIT_ADDED(_, unit)
    local guid = UnitGUID(unit)
    if self.unitsInRange[guid] then
        self.unitsInRange[guid].unit = unit
    else
        self.unitsInRange[guid] = CreateUnitInfo({}, unit)
    end
end

function addon:NAME_PLATE_UNIT_REMOVED(_, unit)
    local guid = UnitGUID(unit)
    if self.unitsInRange[guid] then
        local handled = false
        for u, _ in pairs(addon.units) do
            if UnitIsUnit(unit, u) then
                self.unitsInRange[guid].unit = u
                handled = true
                break
            end
        end
        if not handled then
            self.unitsInRange[guid] = nil
        end
    end
end

function addon:BAG_UPDATE()
    local bindings = self.db.char.bindings

    for id, _ in pairs(bindings) do
        self:UpdateBoundButton(id)
    end

    self:UpdateBagContents()
end

function addon:UNIT_COMBAT(_, unit, action, severity, value, type)
    if self.combatHistory[unit] == nil then
        self.combatHistory[unit] = {}
    end

    table.insert(self.combatHistory[unit], 1, {
        time = GetTime(),
        action = action,
        severity = severity,
        value = value,
        type = type,
    })
end

local currentSpells = {}
local lastCastTarget = {} -- work around UNIT_SPELLCAST_SENT not always triggering
local currentChannel

local function spellcast(_, event, unit, castguid, spellid)
    if unit == 'player' then
        for _, value in ipairs(addon.db.char.announces) do
            if value.value and (not value.disabled) and (event == "UNIT_SPELLCAST_" .. value.event or
                    event == "UNIT_SPELLCAST_CHANNEL_" .. value.event) then
                local skip = false
                if addon.announced[value.id] then
                    for _, val in ipairs(addon.announced[value.id]) do
                        if val == castguid then
                            skip = true
                        end
                    end
                end

                if not skip then
                    local ent = addon.deepcopy(value)
                    if ent.type == "spell" then
                        ent.action = ent.spell
                    elseif ent.type == "item" then
                        ent.action = ent.item
                    end

                    local spellids, itemids = addon:GetSpellIds(ent)
                    for idx, sid in ipairs(spellids) do
                        if spellid == sid then
                            local text = ent.value
                            if ent.type == "spell" then
                                local link = getCached(addon.longtermCache, GetSpellLink, sid)
                                text = text:gsub("{{spell}}", link)
                            elseif ent.type == "item" then
                                local link = select(2, getRetryCached(addon.longtermCache, GetItemInfo, itemids[idx]))
                                text = text:gsub("{{item}}", link)
                            end
                            text = text:gsub("{{event}}", addon.events[ent.event])
                            if currentSpells[castguid] or lastCastTarget[spellid] then
                                text = text:gsub("{{target}}", currentSpells[castguid] or lastCastTarget[spellid])
                            end
                            announce({}, ent, text)
                            if addon.announced[value.id] == nil then
                                addon.announced[value.id] = { castguid }
                            else
                                table.insert(addon.announced[value.id], castguid)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end

addon.UNIT_SPELLCAST_START = spellcast
addon.UNIT_SPELLCAST_STOP = function(_, event, unit, castguid, spellid)
    spellcast(_, event, unit, castguid, spellid)
    if unit == 'player' then
        currentSpells[castguid] = nil
        addon.lastMainSwing = nil
        addon.lastOffSwing = nil
    end
end
addon.UNIT_SPELLCAST_SUCCEEDED = function(_, event, unit, castguid, spellid)
    spellcast(_, event, unit, castguid, spellid)
    if unit == 'player' then
        if currentChannel then
            currentChannel = castguid
        end
    end
end
addon.UNIT_SPELLCAST_INTERRUPTED = spellcast
addon.UNIT_SPELLCAST_FAILED = spellcast
addon.UNIT_SPELLCAST_DELAYED = spellcast
addon.UNIT_SPELLCAST_CHANNEL_START = function(_, event, unit, castguid, spellid)
    spellcast(_, event, unit, castguid, spellid)
    if unit == 'player' then
        currentChannel = true
    end
end
addon.UNIT_SPELLCAST_CHANNEL_STOP = function(_, event, unit, castguid, spellid)
    spellcast(_, event, unit, castguid, spellid)
    if unit == 'player' then
        if currentChannel ~= nil then
            currentSpells[currentChannel] = nil
        end
        currentChannel = nil
        addon.lastMainSwing = nil
        addon.lastOffSwing = nil
    end
end

addon.UNIT_SPELLCAST_SENT = function(_, _, unit, target, castguid, spellid)
    if (unit == 'player') then
        currentSpells[castguid] = target
        lastCastTarget[spellid] = target
    end
end

local function handle_combat_log(_, event, _, sourceGUID, _, _, _, destGUID, _, _, _, ...)
    local spellid, spellname, envType
    local offs = 1
    if event:sub(1, 5) == "SPELL" or event:sub(1, 5) == "RANGE" then
        spellid, spellname = ...
        offs = 4
    elseif event:sub(1, 5) == "ENVIRONMENTAL" then
        envType = ...
        offs = 2
    elseif event == "SWING_MISSED" and sourceGUID == playerGUID then
        local offhand = select(2, ...)
        if offhand then
            addon.lastOffSwing = GetTime()
        else
            addon.lastMainSwing = GetTime()
        end
    end

    if event:sub(-5) == "_HEAL" then
        local amount = select(offs, ...)
        if not addon.damageHistory[destGUID] then
            addon.damageHistory[destGUID] = {
                damage = {},
                heals = {},
            }
        end
        table.insert(addon.damageHistory[destGUID].heals, 1, {
            time = GetTime(),
            value = tonumber(amount),
        })
    elseif event:sub(-7) == "_DAMAGE" then
        if event:sub(1, 5) == "SWING" and sourceGUID == playerGUID then
            local offhand = select(10, ...)
            if offhand then
                addon.lastOffSwing = GetTime()
            else
                addon.lastMainSwing = GetTime()
            end
        end

        local amount = select(offs, ...)
        if not addon.damageHistory[destGUID] then
            addon.damageHistory[destGUID] = {
                damage = {},
                heals = {},
            }
        end
        table.insert(addon.damageHistory[destGUID].damage, 1, {
            time = GetTime(),
            value = tonumber(amount),
        })
    end
end
addon.COMBAT_LOG_EVENT_UNFILTERED = function() handle_combat_log(CombatLogGetCurrentEventInfo()) end
