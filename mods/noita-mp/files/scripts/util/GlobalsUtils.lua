-- OOP class definition is found here: Closure approach
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach
-- Naming convention is found here:
-- http://lua-users.org/wiki/LuaStyleGuide#:~:text=Lua%20internal%20variable%20naming%20%2D%20The,but%20not%20necessarily%2C%20e.g.%20_G%20.

--if not EntityUtils then
--    EntityUtils = dofile_once("mods/noita-mp/files/scripts/util/EntityUtils.lua")
--end
--local util = dofile_once("mods/noita-mp/files/scripts/util/util.lua")

-----------------
-- GlobalsUtils:
-----------------
--- class for GlobalsSetValue and GlobalsGetValue
GlobalsUtils                    = {}

--#region Global public variables

--- key for nuid
GlobalsUtils.nuidKeyFormat      = "nuid = %s"
GlobalsUtils.nuidKeySubstring   = "nuid = "
GlobalsUtils.nuidValueFormat    = "entityId = %s"
GlobalsUtils.nuidValueSubstring = "entityId = "
GlobalsUtils.deadNuidsKey       = "deadNuids"

--#endregion

--#region Access to global private variables

--- Parses key and value string to nuid and entityId.
--- @param xmlKey string GlobalsUtils.nuidKeyFormat = "nuid = %s"
--- @param xmlValue string GlobalsUtils.nuidValueFormat = "entityId = %s"
--- @return number nuid
--- @return number entityId
function GlobalsUtils.parseXmlValueToNuidAndEntityId(xmlKey, xmlValue)
    if type(xmlKey) ~= "string" then
        logger:error("xmlKey(%s) is not type of string!", xmlKey)
    end
    if type(xmlValue) ~= "string" then
        logger:error("xmlKeyValue(%s) is not type of string!", xmlValue)
    end

    local nuid      = nil
    local foundNuid = string.find(xmlKey, GlobalsUtils.nuidKeySubstring, 1, true)
    if foundNuid ~= nil then
        nuid = tonumber(string.sub(xmlKey, GlobalsUtils.nuidKeySubstring:len()))
    else
        logger:info(logger.channels.globals, "Unable to get nuid number of key string (%s).", xmlKey)
        return nil, nil
    end

    local entityId = nil
    if xmlValue and xmlValue ~= "" then
        -- can be empty or nil, when there is no entityId stored in Noitas Globals
        local foundEntityId = string.find(xmlValue, GlobalsUtils.nuidValueSubstring, 1, true)
        if foundEntityId ~= nil then
            entityId = tonumber(string.sub(xmlValue, GlobalsUtils.nuidValueSubstring:len()))
        else
            logger:error("Unable to get entityId number of value string (%s).", xmlValue)
        end
    end

    if entityId == nil or entityId == "" then
        if _G.whoAmI then
            -- _G.whoAmI can be nil, when executed in Noita Components,
            -- because those does not have access to globals
            if _G.whoAmI() == _G.Client.iAm and _G.Client.isConnected() then
                _G.Client.sendLostNuid(nuid)
            end
        end
    end

    return nuid, entityId
end

function GlobalsUtils.setNuid(nuid, entityId, componentIdForOwnerName, componentIdForOwnerGuid, componentIdForNuid)
    --if not EntityUtils.isEntityAlive(entityId) then
    --    return
    --end
    GlobalsSetValue(GlobalsUtils.nuidKeyFormat:format(nuid),
                    GlobalsUtils.nuidValueFormat:format(entityId)) -- also change stuff in nuid_updater.lua
end

function GlobalsUtils.setDeadNuid(nuid)
    local oldDeadNuids = GlobalsGetValue(GlobalsUtils.deadNuidsKey, "")
    GlobalsSetValue(GlobalsUtils.deadNuidsKey,
                    ("%s,%s"):format(oldDeadNuids, nuid)) -- also change stuff in nuid_updater.lua
end

function GlobalsUtils.getDeadNuids()
    local globalsValue = GlobalsGetValue(GlobalsUtils.deadNuidsKey, "")
    return string.split(globalsValue, ",")
end

function GlobalsUtils.removeDeadNuid(nuid)
    local globalsValue    = GlobalsGetValue(GlobalsUtils.deadNuidsKey, "")
    local deadNuids       = string.split(globalsValue, ",")
    local contains, index = table.contains(deadNuids, nuid)
    if contains then
        table.remove(deadNuids, index)
        GlobalsSetValue(GlobalsUtils.deadNuidsKey, table.concat(deadNuids, ","))
    end
end

-- function GlobalsUtils.getNuid(entityId)
-- end

--- Builds a key string by nuid and returns nuid and entityId found by the globals.
--- @param nuid number
--- @return number nuid
--- @return number entityId
function GlobalsUtils.getNuidEntityPair(nuid)
    local key   = GlobalsUtils.nuidKeyFormat:format(nuid)
    local value = GlobalsGetValue(key)
    return GlobalsUtils.parseXmlValueToNuidAndEntityId(key, value)
end

--#endregion

-- Because of stack overflow errors when loading lua files,
-- I decided to put Utils 'classes' into globals
_G.GlobalsUtils = GlobalsUtils

-- But still return for Noita Components,
-- which does not have access to _G,
-- because of own context/vm
return GlobalsUtils
