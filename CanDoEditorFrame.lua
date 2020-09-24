
function CanDoEditor_Init(editor)
    editor.currentPanel = editor.displayOptionsPanel;
    editor.createPanel.title:SetFont(editor.createPanel.title:GetFont(), 18);
    CanDo_Print(editor.displayToggleTab:Deactivate())
    tinsert(UISpecialFrames, editor:GetName());

    editor.itemsToggleTab:SetOnActivate(function ()
        CanDoEditorOnItemsTabClicked(editor);
    end);
    editor.displayToggleTab:SetOnActivate(function ()
        CanDoEditorOnDisplayTabClicked(editor);
    end);

    local onButtonClick = function (self)
        CanDo_Print("button");
        self:GetHighlightTexture():SetVertexColor(1.0, 1.0, 0);
        self:LockHighlight();
        CanDoEditorUpdateDisplayPanel(editor, self.data);

        editor.currentPanel:Show();
        editor.createPanel:Hide();

        if editor.currentButton then
            editor.currentButton:UnlockHighlight();
        end
        editor.currentButton = self;
    end
    
    local createButton = function (i)
        local button = CreateFrame(
            "Button", 
            editor.framesList:GetName() .. "FrameButton" .. i, 
            editor.framesList, 
            "CanDoEditorFrameListItemButton"
        );
        button:SetText("");
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        button:SetScript("OnClick", onButtonClick)
        button:Hide();
        button:Disable();

        return button;
    end

    -- create as many buttons as we can fit, change text and state according to how many frames we have
    local prevButton = createButton(1);

    local _, _, _, _, yOffset = prevButton:GetPoint(1);
    local padding = 5;
    local count = (editor.framesList:GetHeight() - math.abs(yOffset)) / (prevButton:GetHeight() + padding);

    for i=2,count do
        local button = createButton(i);
        button:ClearAllPoints(); 
        button:SetPoint("TOP", prevButton, "BOTTOM", 0, -padding);
        prevButton = button;
    end

    function editor:UpdateList(data)
        local frameCount = table.getn(data);
        local buttons = {editor.framesList:GetChildren()};
        local limit = math.min(frameCount, table.getn(buttons) - 1);
        for i=1,frameCount do
            local button = buttons[i];
            local frame = data[i];
            if frame then
                button:SetText(frame.name);
                button:Show();
                button:Enable();
                button:SetScript("OnClick", onButtonClick)
                button.data = frame;
            else
                button:SetText("");
                button:Hide();
                button:Disable();
            end
        end

        local lastButton = buttons[limit + 1];
        lastButton:SetText("Create");
        lastButton:Show();
        lastButton:Enable();

        lastButton:SetScript("OnClick", function (self)
            CanDo_Print("Create");
            self:GetHighlightTexture():SetVertexColor(1.0, 1.0, 0);
            self:LockHighlight();

            editor.currentPanel:Hide();
            editor.createPanel:Show();

            if editor.currentButton then
                editor.currentButton:UnlockHighlight();
            end
            editor.currentButton = self;
        end)
    end

    function editor:Open(data)
        editor:UpdateList(data);

        editor:Show();
    end

    editor.createPanel.createButton:SetScript("OnClick", function ()
        local newFrameName = editor.createPanel.nameInput:GetText():gsub("%s+", "");
        if string.len(newFrameName) > 0 then
            CanDo_Print("Creating: ", newFrameName);
            local data = CanDoMainFrame_AddNewFrame(newFrameName);
            editor:UpdateList(data);
            CanDoEditorUpdateDisplayPanel(editor, data[table.getn(data)]);
            editor.createPanel:Hide();
            editor.currentPanel:Show();
        end
    end)
end

function CanDoEditorOnDisplayTabClicked(editor)
    editor.currentPanel = editor.displayOptionsPanel;

    editor.itemsOptionsPanel:Hide();
    editor.itemsToggleTab:Activate();

    editor.displayOptionsPanel:Show();
end

function CanDoEditorOnItemsTabClicked(editor)
    editor.currentPanel = editor.itemsOptionsPanel;

    editor.itemsOptionsPanel:Show();

    editor.displayOptionsPanel:Hide();
    editor.displayToggleTab:Activate();
end

function CanDoEditorUpdateDisplayPanel(editor, data)
    local display = editor.displayOptionsPanel;

    display.title:SetText(data.name);
end

function CanDoCreateFrameInput_OnTextChanged(self)
    local text = self:GetText():gsub("%s+", "");
    if string.len(text) > 0 then
        self:GetParent().createButton:Enable();
    else
        self:GetParent().createButton:Disable();
    end
end