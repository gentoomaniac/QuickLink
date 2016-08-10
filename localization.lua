local AL3 = LibStub("AceLocale-3.0")
 
local L = AL3:NewLocale("QuickLink", "enUS", true, debug)
if L then
    L["QUICKLINK"] = "QuickLink"
    L["REGIONERROR"] = "Couldn't find region!"
    L["REALMERROR"] = "Couldn't find server!"
    L["LANGUAGE"] = "en"
end