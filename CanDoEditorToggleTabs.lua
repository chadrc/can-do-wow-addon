
function CanDoEditorToggleTab_OnLoad(self)
    self.active:Disable();

    self.active:SetText(self:GetAttribute("text"));
    self.inactive:SetText(self:GetAttribute("text"));

    function self:SetOnActivate(f)
        self.callback = f
    end

    self.inactive:SetScript("OnClick", function ()
        if self.callback then
            self:Deactivate();
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