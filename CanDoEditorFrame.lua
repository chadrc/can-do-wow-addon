

function CanDoEditorFrame_OnLoad(self, event, ...)
    CanDo_Print("Editor Frame Load");
    CanDo_Print(self.itemsToggleTab:Deactivate())
end

function CanDoEditorTabFrame_OnClick(self, button, ...)
    print("Tab click: ", button);

    print("text: ", self:GetAttribute("text"));
    print("onclick: ", self:GetAttribute("onclick"));
    _G[self:GetAttribute("onclick")]()
end

function CanDoEditorOnDisplayTabClicked(self)
    print("display tab clicked")
end

function CanDoEditorOnItemsTabClicked(self)
    print("items tab clicked")
end

function CanDoEditorToggleTab_OnLoad(self)
    self.inactive:Disable();
    if self:GetAttribute("onclick") and _G[self:GetAttribute("onclick")] then
        self.callback = _G[self:GetAttribute("onclick")];
    end

    self.active:SetText(self:GetAttribute("text"));
    self.inactive:SetText(self:GetAttribute("text"));

    -- local textWidth = self.refs.active:GetTextWidth();
    -- self.refs.active:SetWidth(textWidth);
    -- self.refs.inactive:SetWidth(textWidth);

    self.active:SetScript("OnClick", function ()
        CanDo_Print("click");
        self.inactive:Show();
        self.active:Hide();

        if self.callback then
            self.callback()
        end
    end)

    function self:Activate() 
        self.inactive:Hide();
        self.active:Show();
    end    
    
    function self:Deactivate() 
        self.inactive:Show();
        self.active:Hide();
    end
end