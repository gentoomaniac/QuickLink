local QuickLink = LibStub("AceAddon-3.0"):GetAddon("QuickLink")
local QuickLink_LFG = QuickLink:NewModule("QuickLink_LFG", "AceConsole-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("QuickLink", true)

------------------------------------------------------------------------
--- LFG context Menu hooking
------------------------------------------------------------------------
function getLFGQuickLinkMenu(resultID)
    local entry = {
        text = L["ADDONNAME"],
        hasArrow = true,
        notCheckable = true,
        menuList = {},
    }
	for i, page in pairs(QuickLinkPages) do
       -- if table:get(QuickLinkPages[i], "enabled", true) then
            table.insert(entry.menuList, {
                text = page.name,
                func = function(_, name) QuickLink:ShowUrlFrame(page.name, page.url, name); end,
                notCheckable = true,
                arg1 = nil,
                disabled = nil,
            });
     --   end
	end
	
	return entry;
end

function updateMenu(menu, qlMenu)
	for i=1, #menu do
		if menu[i].text == L["ADDONNAME"] then
			menu[i] = qlMenu;
			updated = true;
		end
	end
	if not updated then
		table.insert(menu, #menu-1, qlMenu);
	end
	
	return menu
end

function QuickLink_LFG:LFGListUtil_GetSearchEntryMenu(resultID)
	local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, leaderName, numMembers = C_LFGList.GetSearchResultInfo(resultID);
    local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);

	local menu = self.hooks["LFGListUtil_GetSearchEntryMenu"](resultID);
	local updated = false;
	
	local searchMenu = getLFGQuickLinkMenu(resultID);
	for i=1,#searchMenu.menuList do
		searchMenu.menuList[i].arg1 = leaderName;
		searchMenu.menuList[i].disabled = not leaderName;
	end

    return updateMenu(menu, searchMenu);
end
 
function QuickLink_LFG:LFGListUtil_GetApplicantMemberMenu(applicantID, memberIdx)
    local name, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);
    local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicantID);
	
	local menu = self.hooks["LFGListUtil_GetApplicantMemberMenu"](applicantID, memberIdx);
	local updated = false;
	
	local applicantMenu = getLFGQuickLinkMenu(resultID);
	for i=1,#applicantMenu.menuList do
		applicantMenu.menuList[i].arg1 = name;
		applicantMenu.menuList[i].disabled = not name or (status ~= "applied" and status ~= "invited");
	end
	
    return updateMenu(menu, applicantMenu);
end

function QuickLink_LFG:OnEnable()
	QuickLink_LFG:RawHook("LFGListUtil_GetSearchEntryMenu", true);
	QuickLink_LFG:RawHook("LFGListUtil_GetApplicantMemberMenu", true);
end