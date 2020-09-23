

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
    MakeRefs(self);
    self.refs.inactive:Disable();
    if self:GetAttribute("onclick") and _G[self:GetAttribute("onclick")] then
        self.callback = _G[self:GetAttribute("onclick")];
    end

    self.refs.active:SetText(self:GetAttribute("text"));
    self.refs.inactive:SetText(self:GetAttribute("text"));

    -- local textWidth = self.refs.active:GetTextWidth();
    -- self.refs.active:SetWidth(textWidth);
    -- self.refs.inactive:SetWidth(textWidth);

    self.refs["active"]:SetScript("OnClick", function ()
        CanDo_Print("click");
        self.refs.inactive:Show();
        self.refs.active:Hide();

        if self.callback then
            self.callback()
        end
    end)

    function self:Activate() 
        self.refs.inactive:Hide();
        self.refs.active:Show();
    end    
    
    function self:Deactivate() 
        self.refs.inactive:Show();
        self.refs.active:Hide();
    end
end

function MakeRefs(frame)
    frame.refs = {};
    for k, v in pairs({frame:GetChildren()}) do
        frame.refs[v:GetAttribute("ref")] = v;
        MakeRefs(v);
    end
end