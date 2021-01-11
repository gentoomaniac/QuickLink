local L = LibStub("AceLocale-3.0"):NewLocale("QuickLink", "enUS", true, debug)
if L then
    L["ADDONNAME"] = "QuickLink"
    L["REGIONERROR"] = "Couldn't find region!"
    L["REALMERROR"] = "Couldn't find server!"
    L["LANGUAGE"] = "en"
    
    L['YES'] = "yes"
    L['NO'] = "no"
    
    L['OPTION_LABEL_NAME'] = "Name"
    L['OPTION_LABEL_URL'] = "Url"
    L['OPTION_LABEL_ENABLED'] = "enabled"
    L['OPTION_LABEL_NEW'] = "+++ new link +++"
    L['OPTION_HELP_NAME'] = "The name of the link"
    L['OPTION_HELP_URL'] = "Url pattern to create the actual link"
    L['OPTION_HELP_ENABLED'] = "enables/disables the link in the menu"
    L['OPTION_HELP_ADD'] = "Adds the new link to the configuration"
    L['OPTION_HELP_DELETE'] = "delete this link"
    L['OPTION_BUTTON_ADD'] = "add link"
    L['OPTION_BUTTON_DELETE'] = "delete"
    L['OPTION_DEFAULT_NAME'] = "Site Name"
    L['OPTION_DEFAULT_URL'] = ""
    L['OPTION_DESCRIPTION'] = [[You can use the following placeholders in the url:
{REGION_LANGUAGE} - The language with a regional postfix, only relevant for en-us, en-gb
{LANGUAGE}        - The language of the page, derived from your localization
{NAME}            - The character name
{REALM}           - The realm name the character is on
{REGION}          - The region the character is in (EU / US / ...)
]]
    
    L['POPUP_DELETECONFIRMATION_QUESTION'] = function(name)
        return "Do you really want to delete the link to\n\"" .. name .. "\"?"
    end
end
