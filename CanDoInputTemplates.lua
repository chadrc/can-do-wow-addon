CanDo_TextInputMixin = {};

function CanDo_TextInputMixin:OnTextChanged(f)
    self.input:SetScript("OnTextChanged", f);
end

function CanDo_TextInputMixin:GetText()
    return self.input:GetText();
end

function CanDo_TextInputMixin:SetText(t)
    return self.input:SetText(t);
end
