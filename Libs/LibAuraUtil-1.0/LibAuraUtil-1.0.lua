local MAJOR, MINOR = "LibAuraUtil-1.0", 1 -- Bump minor on changes
local LibAuraUtil, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibAuraUtil then return end 

local function FindBuffRecurse(predicate, unit, filter, buffIndex, predicateArg1, predicateArg2, predicateArg3, ...)
	if ... == nil then
		return nil; -- Not found
	end
	if predicate(predicateArg1, predicateArg2, predicateArg3, ...) then
		return ...;
	end
	buffIndex = buffIndex + 1;
	return FindBuffRecurse(predicate, unit, filter, buffIndex, predicateArg1, predicateArg2, predicateArg3, UnitBuff(unit, buffIndex, filter));
end

local function FindDebuffRecurse(predicate, unit, filter, debuffIndex, predicateArg1, predicateArg2, predicateArg3, ...)
	if ... == nil then
		return nil; -- Not found
	end
	if predicate(predicateArg1, predicateArg2, predicateArg3, ...) then
		return ...;
	end
	debuffIndex = debuffIndex + 1;
	return FindDebuffRecurse(predicate, unit, filter, debuffIndex, predicateArg1, predicateArg2, predicateArg3, UnitDebuff(unit, debuffIndex, filter));
end

do
	local function IDPredicate(auraIDToFind,_,_, _,_,_,_,_,_,_,_,_,spellID)
		return auraIDToFind == spellID
	end
	local function NamePredicate(auraNameToFind,_,_,spellName)
		return auraNameToFind == spellName
	end
	
	local function buildFindAuraBySpellID()
		AuraUtil.FindAuraBySpellID = function(spellID,unit,filter)
			return AuraUtil.FindAura(IDPredicate,unit,filter,spellID)
		end
	end
	
	local function buildFindBuffAndDebuffBySpellID()
		AuraUtil.FindBuffBySpellID = function(spell,unit,filter) return AuraUtil.FindBuff(IDPredicate,unit,filter,spell) end
		AuraUtil.FindDebuffBySpellID = function(spell,unit,filter) return AuraUtil.FindDebuff(IDPredicate,unit,filter,spell) end
	end
	
	local function buildFindBuffAndDebuffByName()
		AuraUtil.FindBuffByName = function(spell,unit,filter) return AuraUtil.FindBuff(NamePredicate,unit,filter,spell)  end
		AuraUtil.FindDebuffByName = function(spell,unit,filter) return AuraUtil.FindDebuff(NamePredicate,unit,filter,spell) end
	end
	
	local function buildAuraUtil()
		AuraUtil.FindBuff = function(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3) 
			local buffIndex = 1;
			return FindBuffRecurse(predicate, unit, filter, buffIndex, predicateArg1, predicateArg2, predicateArg3, UnitBuff(unit, buffIndex, filter));
		end
		AuraUtil.FindDebuff = function(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3) 
			local debuffIndex = 1;
			return FindDebuffRecurse(predicate, unit, filter, debuffIndex, predicateArg1, predicateArg2, predicateArg3, UnitDebuff(unit, debuffIndex, filter));
		end
		buildFindBuffAndDebuffByName()
		buildFindBuffAndDebuffBySpellID()
	end
	buildAuraUtil()
end

function LibAuraUtil.FindAuraBySpell(spell,unit,filter)
	if AuraUtil then
		if tonumber(spell) then
			return AuraUtil.FindAuraBySpellID(spell,unit,filter)
		else
			return AuraUtil.FindAuraByName(spell,unit,filter)
		end
	else
		return UnitAura(unit,tonumber(spell) and GetSpellInfo(spell) or spell ,nil,filter)
	end
end
function LibAuraUtil.FindDebuffBySpell(spell,unit,filter)
		if AuraUtil then
		if tonumber(spell) then
			return AuraUtil.FindDebuffBySpellID(spell,unit,filter)
		else
			return AuraUtil.FindDebuffByName(spell,unit,filter)
		end
	else
		return UnitDebuff(unit,tonumber(spell) and GetSpellInfo(spell) or spell ,nil,filter)
	end
end
function LibAuraUtil.FindBuffBySpell(spell,unit,filter)
		if AuraUtil then
		if tonumber(spell) then
			return AuraUtil.FindBuffBySpellID(spell,unit,filter)
		else
			return AuraUtil.FindBuffByName(spell,unit,filter)
		end
	else
		return UnitBuff(unit,tonumber(spell) and GetSpellInfo(spell) or spell ,nil,filter)
	end
end
LibAuraUtil.UnitBuff = LibAuraUtil.FindBuffBySpell
LibAuraUtil.UnitDebuff = LibAuraUtil.FindDebuffBySpell
LibAuraUtil.UnitAura = LibAuraUtil.FindAuraBySpell