
function CanDoEditor_Init(editor)
    tinsert(UISpecialFrames, editor:GetName());
    editor.currentPanel = editor.displayOptionsPanel;
    editor.createPanel.title:SetFont(editor.createPanel.title:GetFont(), 18);
    editor.displayToggleTab:Deactivate()
    editor.deleteButton:Disable();
    editor.displayToggleTab:Hide();
    editor.itemsToggleTab:Hide();

    editor.createPanel.nameInput:OnTextChanged(function (self)
        local text = self:GetText():gsub("%s+", "");
        if string.len(text) > 0 then
            editor.createPanel.createButton:Enable();
        else
            editor.createPanel.createButton:Disable();
        end
    end)

    editor.deleteButton:SetScript("OnClick", function ()
        CanDo_Print("deleting: ", editor.currentButton.dataIndex);

        local newData = CanDoMainFrame_RemoveFrame(editor.currentButton.dataIndex);
        editor:UpdateList(newData);

        editor.currentButton:UnlockHighlight();
        editor.currentButton = nil;
        editor.deleteButton:Disable();
    end)

    editor.itemsToggleTab:SetOnActivate(function ()
        CanDoEditorOnItemsTabClicked(editor);
    end);

    editor.displayToggleTab:SetOnActivate(function ()
        CanDoEditorOnDisplayTabClicked(editor);
    end);

    local onButtonClick = function (self)
        self:GetHighlightTexture():SetVertexColor(1.0, 1.0, 0);
        self:LockHighlight();
        CanDoEditorUpdateDisplayPanel(editor, self.data);

        editor.currentPanel:Show();
        editor.createPanel:Hide();

        if editor.currentButton then
            editor.currentButton:UnlockHighlight();
        end
        editor.currentButton = self;
        editor.deleteButton:Enable();

        editor.displayToggleTab:Show();
        editor.itemsToggleTab:Show();
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

    editor.buttons = {editor.framesList:GetChildren()};
    function editor:UpdateList(data)
        local frameCount = table.getn(data);
        local buttons = editor.buttons;
        local limit = math.min(frameCount, table.getn(buttons) - 1);
        for i=1,table.getn(buttons) do
            local button = buttons[i];
            local frame = data[i];
            if frame then
                button:SetText(frame.name);
                button:Show();
                button:Enable();
                button:SetScript("OnClick", onButtonClick)
                button.data = frame;
                button.dataIndex = i;
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
            self:GetHighlightTexture():SetVertexColor(1.0, 1.0, 0);
            self:LockHighlight();

            editor.currentPanel:Hide();
            editor.createPanel:Show();

            if editor.currentButton then
                editor.currentButton:UnlockHighlight();
            end
            editor.currentButton = self;

            editor.deleteButton:Disable();
            editor.displayToggleTab:Hide();
            editor.itemsToggleTab:Hide();
        end)
    end

    function editor:Open(data)
        editor:UpdateList(data);

        editor:Show();
    end

    editor.createPanel.createButton:SetScript("OnClick", function ()
        local newFrameName = editor.createPanel.nameInput:GetText():gsub("%s+", "");
        if string.len(newFrameName) > 0 then
            local data = CanDoMainFrame_AddNewFrame(newFrameName);
            editor:UpdateList(data);
            CanDoEditorUpdateDisplayPanel(editor, data[table.getn(data)]);
            editor.createPanel:Hide();
            editor.currentPanel:Show();
            editor.createPanel.nameInput:SetText(""); 
            editor.currentButton = editor.buttons[table.getn(data)]
            editor.deleteButton:Enable();
        end
    end)

    -- display panel
    CanDoEditor_SetupDisplayPanel(editor);
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
    local display = data.display;
    local form = editor.displayOptionsPanel.displayForm;

    form.buttonSizeInput:SetText(display.buttonSize);

    local c = data.display.backgroundColor;
    form.backgroundColorInput.picker.texture:SetColorTexture(c.r, c.g, c.b, c.a);
end

function CanDoEditor_SetupDisplayPanel(editor)
    local form = editor.displayOptionsPanel.displayForm;

    form.buttonSizeInput:OnEnterPressed(function (input)
        input:ClearFocus();
        local value = tonumber(input:GetText(), 10);
        if value == nil then
            input:SetText(editor.currentButton.data.display.buttonSize);
            return;
        end
        
        editor.currentButton.data.display.buttonSize = value;
        editor.redrawFrames();
    end);

    form.backgroundColorInput.picker:SetScript("OnMouseUp", function ()
        -- quick clone so we can reset on cancel
        local color = {};
        CanDo_tcopy(color, editor.currentButton.data.display.backgroundColor);
        ColorPickerFrame:SetColorRGB(color.r, color.g, color.b);
        ColorPickerFrame.hasOpacity = true;
        ColorPickerFrame.opacity = color.a;
        ColorPickerFrame.func = function ()
            local r, g, b = ColorPickerFrame:GetColorRGB();
            editor.currentButton.data.display.backgroundColor.r = r;
            editor.currentButton.data.display.backgroundColor.g = g;
            editor.currentButton.data.display.backgroundColor.b = b;
            editor.redrawFrames();
            form.backgroundColorInput.picker.texture:SetColorTexture(r,g,b, OpacitySliderFrame:GetValue());
        end
        ColorPickerFrame.opacityFunc = function ()
            -- invert so '+' display lines up with more opaque
            local newAlpha = 1.0 - OpacitySliderFrame:GetValue();
            editor.currentButton.data.display.backgroundColor.a = newAlpha;
            local r, g, b = ColorPickerFrame:GetColorRGB();
            form.backgroundColorInput.picker.texture:SetColorTexture(r, g, b, newAlpha);
            editor.redrawFrames();
        end 
        ColorPickerFrame.cancelFunc = function ()
            editor.currentButton.data.display.backgroundColor = color;
            form.backgroundColorInput.picker.texture:SetColorTexture(color.r, color.g, color.b, color.a);
            editor.redrawFrames();
        end

        ColorPickerFrame:Show();
    end)
end

