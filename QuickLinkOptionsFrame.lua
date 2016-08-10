function QuickLinkOptionsFrame_OnLoad(panel)
    -- Set the name for the Category for the Panel
    --
    panel.name = "QuickLink" -- .. GetAddOnMetadata("QuickLink", "Version");

    -- When the player clicks okay, run this function.
    --
    panel.okay = function (self) QuickLinkOptionsFrame_Close(); end;

    -- When the player clicks cancel, run this function.
    --
    panel.cancel = function (self)  QuickLinkOptionsFrame_CancelOrLoad();  end;

    -- Add the panel to the Interface Options
    --
    InterfaceOptions_AddCategory(panel);
end

function QuickLinkOptionsFrame_Close()

end

function QuickLinkOptionsFrame_CancelOrLoad()

end