QuickLink = LibStub("AceAddon-3.0"):NewAddon("QuickLink", "AceConsole-3.0", "AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("QuickLink", true)
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

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
    { name = "Armory", url = "http://{REGION}.battle.net/wow/{LANGUAGE}/character/{REALM}/{NAME}/advanced", enabled = true },
    { name = "Ask Mr. Robot", url = "http://www.askmrrobot.com/wow/player/{REGION}/{REALM}/{NAME}", enabled = true },
    { name = "Guildox", url = "http://guildox.com/toon/{REGION}/{REALM}/{NAME}", enabled = true },
    { name = "WOW Progress", url = "http://www.wowprogress.com/character/{REGION}/{REALM}/{NAME}", enabled = true },
}

StaticPopupDialogs["QUICKLINK_DELETE"] = {
    text = "delete?" ,
    button1 = "Yes",
    button2 = "No",
    OnAccept = function() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
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

local function GenConfig()
    local options = {
        name = "QuickLink", handler = QuickLink, type = "group",
        args = {
        	desc = {
				order = 1,
				type = "description",
				name = "Some description here!",
			},
        }
    }

    for i, page in pairs(QuickLinkPages) do
        local page_options = {
            type = "group",
            name = page.name,
            order = 10+i,
            args = {
                page_name = {
                    order = 1,
                    type = "input",
                    name = "Name",
                    desc = "Name of the page",
                    set = function(info, val)
                        QuickLinkPages[i].name = val
                        ConfigChange()
                    end,
                    get = function() return QuickLinkPages[i].name end,
                },
                page_url = {
                    order = 2,
                    type = "input",
                    name = "URL",
                    desc = "URL pattern for the page entry",
                    set = function(info, val)
                        QuickLinkPages[i].url = val
                        ConfigChange()
                    end,
                    get = function() return QuickLinkPages[i].url end,
                    width = "full",
                    multiline = 2
                },
                isEnabled = {
                    order = 10,
                    type = "toggle",
                    name = "enabled",
                    desc = "Enables the given link",
                    set = function(info, val)
                        QuickLinkPages[i].enabled = val
                        ConfigChange()
                    end,
                    get = function() return QuickLinkPages[i].enabled end
                },
                delete = {
                    type = "execute",
                    name = "delete",
                    desc = "delete the link entirely",
                    func = function()
                        StaticPopupDialogs["QUICKLINK_DELETE"].text = "Do you really want to delete the link to " .. QuickLinkPages[i].name .. "?"
                        StaticPopupDialogs["QUICKLINK_DELETE"].OnAccept = function()
                            QuickLinkPages[i] = nil
                            ConfigChange()
                        end
                        StaticPopup_Show ("QUICKLINK_DELETE")
                    end,
                    order = 20,
                },
            }
        }
        options.args["page_"..i] = page_options
    end
    
    -- add entry for a new site
    local new_entry = {name = "New Page", url = "", enabled = false}
    options.args["page_new"] = {
            type = "group",
            name = "+++ new link",
            args = {
                page_name = {
                    order = 1,
                    type = "input",
                    name = "Name",
                    desc = "Name of the page",
                    set = function(info, val)
                        new_entry.name = val
                    end,
                    get = function() return new_entry.name end,
                },
                page_url = {
                    order = 2,
                    type = "input",
                    name = "URL",
                    desc = "URL pattern for the page entry",
                    set = function(info, val)
                        new_entry.url = val
                    end,
                    get = function() return new_entry.url end,
                    width = "full",
                    multiline = 2
                },
                isEnabled = {
                    order = 10,
                    type = "toggle",
                    name = "enabled",
                    desc = "Enables the given link",
                    set = function(info, val)
                        new_entry.enabled = val
                    end,
                    get = function() return new_entry.enabled end
                },
                add = {
                    type = "execute",
                    name = "add link",
                    desc = "Add the link to QuickLink",
                    func = function() table.insert(QuickLinkPages, new_entry) end,
                    order = 20
                }
            }
        }
    
    
    return options
end


local function UpdateOptionsFrame()
    LibStub("AceConfigRegistry-3.0"):NotifyChange("QuickLink")
end
------------------------------------------------------------------------
function ConfigChange()
    QuickLink_UNIT_POPUP = QuickLink:GetModule("QuickLink_UNIT_POPUP")
    if QuickLink_UNIT_POPUP and QuickLink_UNIT_POPUP:IsEnabled() then
        QuickLink_UNIT_POPUP:updateContextMenu()
    end
    UpdateOptionsFrame()
end

function QuickLink:OnInitialize()
    if not QuickLinkPages then
        QuickLinkPages = QuickLink_defaultPages
        QuickLink:Print("Loaded default pages")
    end
    
    AceConfig:RegisterOptionsTable("QuickLink", GenConfig())
    QuickLink.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("QuickLink", "QuickLink")
    
    QuickLink_variablesLoaded = true;
    QuickLink:EnableModule("QuickLink_UNIT_POPUP")
    QuickLink:EnableModule("QuickLink_LFG")
    QuickLink:EnableModule("QuickLink_BNET")
    ConfigChange()
    
    SLASH_QUICKLINK1 = "/quicklink"
    SlashCmdList["QUICKLINK"] = function(msg)
        InterfaceOptionsFrame_OpenToCategory("QuickLink")
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