local EditorFrame

function CanDoEditorFrame_OnLoad(self, event, ...)
    CanDo_Print("Editor Frame Load");
    CanDo_Print(self.displayToggleTab:Deactivate())
    EditorFrame = self;
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

function CanDoEditorToggleTab_OnLoad(self)
    self.active:Disable();
    if self:GetAttribute("onclick") and _G[self:GetAttribute("onclick")] then
        self.callback = _G[self:GetAttribute("onclick")];
    end

    self.active:SetText(self:GetAttribute("text"));
    self.inactive:SetText(self:GetAttribute("text"));

    -- local textWidth = self.refs.active:GetTextWidth();
    -- self.refs.active:SetWidth(textWidth);
    -- self.refs.inactive:SetWidth(textWidth);

    self.inactive:SetScript("OnClick", function ()
        CanDo_Print("click");
        self:Deactivate();

        if self.callback then
            self.callback()
        end
    end)

    function self:Activate() 
        self.inactive:Show();
        self.active:Hide();
    end    
    
    function self:Deactivate() 
        self.inactive:Hide();
        self.active:Show();
    end
end