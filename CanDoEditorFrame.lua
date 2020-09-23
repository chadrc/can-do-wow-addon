local EditorFrame

function CanDoEditorFrame_OnLoad(self, event, ...)
    CanDo_Print("Editor Frame Load");
    CanDo_Print(self.displayToggleTab:Deactivate())
    EditorFrame = self;

    local prevButton = CreateFrame("Button", self.framesList:GetName() .. "FrameButton" .. 0, self.framesList, "CanDoEditorFrameListItemButton");
    prevButton:SetText("Frame 0");
    for i=1,10 do
        local button = CreateFrame("Button", self.framesList:GetName() .. "FrameButton" .. i, self.framesList, "CanDoEditorFrameListItemButton");
        button:ClearAllPoints(); 
        button:SetPoint("TOP", prevButton, "BOTTOM", 0, -5);
        button:SetText("Frame " .. i);
        prevButton = button;
    end
end

function CanDoEditorTabFrame_OnClick(self, button, ...)
    print("Tab click: ", button);

    print("text: ", self:GetAttribute("text"));
    print("onclick: ", self:GetAttribute("onclick"));
    _G[self:GetAttribute("onclick")]()
end

function CanDoEditorOnDisplayTabClicked(self)
    EditorFrame.itemsOptionsPanel:Hide();
    EditorFrame.itemsToggleTab:Activate();

    EditorFrame.displayOptionsPanel:Show();
end

function CanDoEditorOnItemsTabClicked(self)
    EditorFrame.itemsOptionsPanel:Show();

    EditorFrame.displayOptionsPanel:Hide();
    EditorFrame.displayToggleTab:Activate();
end
