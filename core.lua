QuickLink = LibStub("AceAddon-3.0"):NewAddon("QuickLink", "AceConsole-3.0", "AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("QuickLink", true)
local LRI = LibStub:GetLibrary("LibRealmInfo");

-- Globals
-- so we know when our configuration is loaded
QuickLink_variablesLoaded = false;
-- details used by myAddOns
QuickLink_details = {
    name = "QuickLink",
    frame = "QuickLinkFrame",
    optionsframe = "QuickLinkFrame"
};
-- default config settings
local QuickLink_defaultPages = {
    { name = "Armory", url = "http://{REGION}.battle.net/wow/{LANGUAGE}/character/{REALM}/{NAME}/advanced" },
    { name = "Ask Mr. Robot", url = "http://www.askmrrobot.com/wow/player/{REGION}/{REALM}/{NAME}" },
    { name = "Guildox", url = "http://guildox.com/toon/{REGION}/{REALM}/{NAME}" },
    { name = "WOW Progress", url = "http://www.wowprogress.com/character/{REGION}/{REALM}/{NAME}" },
}

local function urlEscape(url)
    return string.gsub(url, "([^A-Za-z0-9_:/?&=.-])",
        function(ch)
            return string.format("%%%02x", string.byte(ch))
        end)
end

local function getUrl(urltemplate, name, server)
    local region = nil
    local url = nil
    
    if not name or name == "" then return end
    if not server or server == "" then server = GetRealmName() end
    
    local _,realm,_,_,_,_,region = LRI:GetRealmInfo(server)
    
    if not region or region == "" then
        QuickLink:Print(L['REGIONERROR'])
        return;
    end
    if not realm or realm == "" then
        QuickLink:Print(L['REALMERROR'])
        return;
    end

    realm = realm:gsub("'","");
    realm = realm:gsub(" ","-");
    
    url,_ = string.gsub(urltemplate, "{REGION}", region)
    url,_ = string.gsub(url, "{LANGUAGE}", L["LANGUAGE"])
    url,_ = string.gsub(url, "{REALM}", realm)
    url,_ = string.gsub(url, "{NAME}", name)
    if url then
        url = urlEscape(url);
    end

    return url;
end

function QuickLink:ShowUrlFrame(pagename, pagetemplate, name, server)

    if not server then
        n = gsub(name, "%-[^|]+", "")
        s = gsub(name, "[^|]+%-", "")
        name, server = n, s
    end

    local url = getUrl(pagetemplate, name, server);
    if url then
        linkEditBox:SetText(url)
        linkEditBox:HighlightText()
        headlineString:SetText(pagename.." link for "..name)
        QuickLinkFrame:Show()
    end
end

------------------------------------------------------------------------

function QuickLink:OnInitialize()
    if not QuickLinkPages then
        QuickLinkPages = QuickLink_defaultPages
        QuickLink:Print("Loaded default pages")
    end
    QuickLink:Print("Loaded pages")
    QuickLink_variablesLoaded = true;
    QuickLink:EnableModule("QuickLink_UNIT_POPUP")
    QuickLink:EnableModule("QuickLink_LFG")
    QuickLink:EnableModule("QuickLink_BNET")
    QuickLink_ConfigChange()
end

function QuickLink_ConfigChange()
    QuickLink_UNIT_POPUP = QuickLink:GetModule("QuickLink_UNIT_POPUP")
    if QuickLink_UNIT_POPUP and QuickLink_UNIT_POPUP:IsEnabled() then
        QuickLink_UNIT_POPUP:updateContextMenu()
    end
end

function hideDialog()
    linkEditBox:SetText("")
    linkEditBox:ClearFocus()
    QuickLinkFrame:Hide()
end

------------------------------------------------------------------------
-- Frame Event handling
------------------------------------------------------------------------
function okButton1_OnClick()
    hideDialog()
end

function linkEditBox_OnEscapePressed()
    hideDialog()
end

---