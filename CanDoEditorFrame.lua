
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

        editor.currentPanel:Show();
        editor.createPanel:Hide();

        if editor.currentButton then
            editor.currentButton:UnlockHighlight();
        end
        editor.currentButton = self;
        editor.deleteButton:Enable();

        editor.displayToggleTab:Show();
        editor.itemsToggleTab:Show();

        CanDoEditorUpdateDisplayPanel(editor, self.data);
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

    local c = display.backgroundColor;
    form.backgroundColorInput.picker.texture:SetColorTexture(c.r, c.g, c.b, c.a);

    form.activeButtonAlphaSlider:SetValue(display.activeButtonAlpha);
    form.inactiveButtonAlphaSlider:SetValue(display.inactiveButtonAlpha);

    local positioningForm = editor.displayOptionsPanel.positioningForm;
    local positioning = display.positioning;
    -- local positioningDropdown = positioningForm.positioningDropdown;

    -- Hiding for now, decide if relative positioning is enough. Ideally would be drag and drop anyway
    -- local labels = {
    --     relative = "Relative",
    --     absolute = "Absolute"
    -- };

    -- local function OnDropdownItemClicked(self, arg1, arg2, checked)
    --     UIDropDownMenu_SetText(positioningDropdown, labels[arg1]);
    --     editor.currentButton.data.display.positioning.type = arg1;
    --     editor.redrawFrames();
    --     CloseDropDownMenus();
    -- end

    -- local function InitDropdownMenu(frame, level, menuList)
    --     local info = UIDropDownMenu_CreateInfo();
    --     info.func = OnDropdownItemClicked;
    --     info.text, info.arg1, info.checked = "Relative", "relative", positioning.type == "relative";
    --     UIDropDownMenu_AddButton(info)
    --     info.text, info.arg1, info.checked = "Absolute", "absolute", positioning.type == "absolute";
    --     UIDropDownMenu_AddButton(info)
    -- end

    -- UIDropDownMenu_SetWidth(positioningDropdown, 75);
    -- UIDropDownMenu_SetText(positioningDropdown, labels[positioning.type]);
    -- UIDropDownMenu_Initialize(positioningDropdown, InitDropdownMenu);

    positioningForm.offsetXSlider:SetValue(positioning.offsetX);
    positioningForm.offsetXSlider.valueLabel:SetText(CanDo_TwoDecimals(positioning.offsetX));
    positioningForm.offsetYSlider:SetValue(positioning.offsetY);
    positioningForm.offsetYSlider.valueLabel:SetText(CanDo_TwoDecimals(positioning.offsetY));

    local anchorLabels = {
        CENTER = "CENTER",
        TOP = "TOP",
        BOTTOM = "BOTTOM",
        LEFT = "LEFT",
        RIGHT = "RIGHT",
        TOPLEFT = "TOPLEFT",
        TOPRIGHT = "TOPRIGHT",
        BOTTOMLEFT = "BOTTOMLEFT",
        BOTTOMRIGHT = "BOTTOMRIGHT",
    };

    local function initAnchorDropdown(dropdown, data, dataProp, labels)
        local function OnAnchorDropdownItemClicked(self, arg1, arg2, checked)
            UIDropDownMenu_SetText(dropdown, arg1);
            data[dataProp] = arg1;
            editor.redrawFrames();
            CloseDropDownMenus();
        end

        local function InitAnchorDropdownMenu(frame, level, menuList)
            local info = UIDropDownMenu_CreateInfo();
            info.func = OnAnchorDropdownItemClicked;

            for k, v in pairs(labels) do
                info.text, info.arg1, info.checked = v, k, data[dataProp] == v;
                UIDropDownMenu_AddButton(info)
            end
        end

        UIDropDownMenu_SetWidth(dropdown, 75);
        UIDropDownMenu_SetText(dropdown, data[dataProp]);
        UIDropDownMenu_Initialize(dropdown, InitAnchorDropdownMenu);
    end

    initAnchorDropdown(positioningForm.anchorDropdown, positioning, 'anchor', anchorLabels);
    initAnchorDropdown(positioningForm.relativeAnchorDropDown, positioning, 'relativeAnchor', anchorLabels);
end

function CanDoEditor_SetupDisplayPanel(editor)
    -- Display form
    local displayForm = editor.displayOptionsPanel.displayForm;

    displayForm.buttonSizeInput:OnEnterPressed(function (input)
        input:ClearFocus();
        local value = tonumber(input:GetText(), 10);
        if value == nil then
            input:SetText(editor.currentButton.data.display.buttonSize);
            return;
        end
        
        editor.currentButton.data.display.buttonSize = value;
        editor.redrawFrames();
    end);

    displayForm.backgroundColorInput.picker:SetScript("OnMouseUp", function ()
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
            displayForm.backgroundColorInput.picker.texture:SetColorTexture(r,g,b, OpacitySliderFrame:GetValue());
        end
        ColorPickerFrame.opacityFunc = function ()
            -- invert so '+' display lines up with more opaque
            local newAlpha = 1.0 - OpacitySliderFrame:GetValue();
            editor.currentButton.data.display.backgroundColor.a = newAlpha;
            local r, g, b = ColorPickerFrame:GetColorRGB();
            displayForm.backgroundColorInput.picker.texture:SetColorTexture(r, g, b, newAlpha);
            editor.redrawFrames();
        end 
        ColorPickerFrame.cancelFunc = function ()
            editor.currentButton.data.display.backgroundColor = color;
            displayForm.backgroundColorInput.picker.texture:SetColorTexture(color.r, color.g, color.b, color.a);
            editor.redrawFrames();
        end

        ColorPickerFrame:Show();
    end)

    displayForm.activeButtonAlphaSlider:SetScript("OnValueChanged", function ()
        local newValue = displayForm.activeButtonAlphaSlider:GetValue();
        editor.currentButton.data.display.activeButtonAlpha = newValue;
        editor.redrawFrames();
    end)

    displayForm.inactiveButtonAlphaSlider:SetScript("OnValueChanged", function ()
        local newValue = displayForm.inactiveButtonAlphaSlider:GetValue();
        editor.currentButton.data.display.inactiveButtonAlpha = newValue;
        editor.redrawFrames();
    end)

    -- Positioning form
    local positioningForm = editor.displayOptionsPanel.positioningForm;

    positioningForm.offsetXSlider:SetScript("OnValueChanged", function ()
        local newValue = positioningForm.offsetXSlider:GetValue();
        editor.currentButton.data.display.positioning.offsetX = newValue;
        positioningForm.offsetXSlider.valueLabel:SetText(CanDo_TwoDecimals(newValue));
        editor.redrawFrames();
    end)

    positioningForm.offsetYSlider:SetScript("OnValueChanged", function ()
        local newValue = positioningForm.offsetYSlider:GetValue();
        editor.currentButton.data.display.positioning.offsetY = newValue;
        positioningForm.offsetYSlider.valueLabel:SetText(CanDo_TwoDecimals(newValue));
        editor.redrawFrames();
    end)
end

function CanDo_TwoDecimals(v)
    return string.format("%.2f", v);
end