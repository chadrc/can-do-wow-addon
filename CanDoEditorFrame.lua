
local buttonPool = {};
local buttonsUsed = 0;

local function NextButtonInPool()
    buttonsUsed = buttonsUsed + 1;
    local b = buttonPool[buttonsUsed];
    b:Show();
    return b;
end

local function CreateButton(i, parent)
    local b = CreateFrame("Button", "CanDoActionSelectFrame_" .. i, parent);
    b.texture = b:CreateTexture();
    b.texture:SetPoint("CENTER");
    return b;
end

function CanDoEditor_Init(editor)
    tinsert(UISpecialFrames, editor:GetName());
    editor.currentPanel = editor.displayOptionsPanel;
    editor.createPanel.title:SetFont(editor.createPanel.title:GetFont(), 18);
    editor.displayToggleTab:Deactivate()
    editor.deleteButton:Disable();
    editor.displayToggleTab:Hide();
    editor.itemsToggleTab:Hide();

    for i=1,100 do
        local b = CreateButton(i, editor.itemsOptionsPanel);
        table.insert(buttonPool, b);
    end

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


    positioningForm.offsetXSlider:SetValueStep(1);
    positioningForm.offsetXSlider:SetMinMaxValues(0, UIParent:GetWidth());
    positioningForm.offsetXSlider:SetValue(positioning.offsetX);
    positioningForm.offsetXSlider.valueLabel:SetText(positioning.offsetX);
    
    positioningForm.offsetYSlider:SetValueStep(1);
    positioningForm.offsetYSlider:SetMinMaxValues(0, UIParent:GetHeight());
    positioningForm.offsetYSlider:SetValue(positioning.offsetY);
    positioningForm.offsetYSlider.valueLabel:SetText(positioning.offsetY);

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

    local function initDropdown(dropdown, data, dataProp, labels, onchange)
        local function OnAnchorDropdownItemClicked(self, arg1, arg2, checked)
            if onchange ~= nil then
                onchange(arg1);
            end
            UIDropDownMenu_SetText(dropdown, arg2);
            data[dataProp] = arg1;
            editor.redrawFrames();
            CloseDropDownMenus();
        end

        local function InitAnchorDropdownMenu(frame, level, menuList)
            local info = UIDropDownMenu_CreateInfo();
            info.func = OnAnchorDropdownItemClicked;

            for k, v in pairs(labels) do
                info.text, info.arg1, info.arg2, info.checked = v, k, v, data[dataProp] == k;
                UIDropDownMenu_AddButton(info)
            end
        end

        UIDropDownMenu_SetWidth(dropdown, 75);
        UIDropDownMenu_SetText(dropdown, labels[data[dataProp]]);
        UIDropDownMenu_Initialize(dropdown, InitAnchorDropdownMenu);
    end

    initDropdown(positioningForm.anchorDropdown, positioning, 'anchor', anchorLabels);
    initDropdown(positioningForm.relativeAnchorDropDown, positioning, 'relativeAnchor', anchorLabels);


    local arrangementForm = editor.displayOptionsPanel.arrangementForm;
    local arrangement = display.arrangement;
    local arrangementOptions = {
        grid = "Grid",
        circle = "Circle",
    };

    initDropdown(
        arrangementForm.arrangementDropdown, 
        arrangement, 
        'type', 
        arrangementOptions,
        function (v)
            if v == "grid" then
                arrangementForm.gridOptions:Show();
                arrangementForm.circleOptions:Hide();
            else
                arrangementForm.gridOptions:Hide();
                arrangementForm.circleOptions:Show();
            end
        end
    );

    local value = arrangement.rows;
    local mock = {
        opt = "rows"
    };
    if value == 0 then
        value = arrangement.columns;
        mock.opt = "columns";
    end
    
    arrangementForm.gridOptions.rowColSlider:SetValueStep(1);
    arrangementForm.gridOptions.rowColSlider:SetMinMaxValues(1, table.getn(data.items));
    arrangementForm.gridOptions.rowColSlider:SetValue(value);
    arrangementForm.gridOptions.rowColSlider.valueLabel:SetText(value);
    
    arrangementForm.gridOptions.paddingSlider:SetValueStep(1);
    arrangementForm.gridOptions.paddingSlider:SetMinMaxValues(0, 100);
    arrangementForm.gridOptions.paddingSlider:SetValue(arrangement.padding);
    arrangementForm.gridOptions.paddingSlider.valueLabel:SetText(arrangement.padding);

    initDropdown(arrangementForm.gridOptions.rowColDropdown, mock, "opt", {
        rows = "Rows",
        columns = "Columns"
    }, function (prop)
        if prop == "rows" then
            arrangement.rows = arrangement.columns;
            arrangement.columns = 0;
        else
            arrangement.columns = arrangement.rows;
            arrangement.rows = 0;
        end
    end)

    arrangementForm.circleOptions.diameterSlider:SetValueStep(1);
    arrangementForm.circleOptions.diameterSlider:SetMinMaxValues(0, UIParent:GetHeight());
    arrangementForm.circleOptions.diameterSlider:SetValue(arrangement.diameter);
    arrangementForm.circleOptions.diameterSlider.valueLabel:SetText(arrangement.diameter);

    -- Update Items Panel
    local padding = 5;
    local buttonSize = 30;
    local itemCount = table.getn(data.items);

    -- Generate selected action buttons
    local totalWidth = buttonSize * itemCount + padding * (itemCount + 1);
    local totalHeight = buttonSize + padding * 2;

    local selectedParent = editor.itemsOptionsPanel.selectedActionsPanel;

    local selectedSet = {};

    local function DrawSelectedItems() 
        buttonsUsed = 0;
        for k, v in pairs(data.items) do
            local slot = v.source.slot;
            selectedSet[slot] = true;
            local type, gid = GetActionInfo(slot);
            local name, rank, icon, castTime, minRange, maxRange = "";

            local texture = GetActionTexture(slot);

            local i = k - 1;
            local row = math.floor(i / 12);
            local col = i % 12;

            local offsetX = col * (buttonSize + padding) + padding;
            local offsetY = row * (buttonSize + padding) + padding;

            local smallFrame = NextButtonInPool();
            smallFrame:SetParent(selectedParent);
            smallFrame:SetSize(buttonSize, buttonSize);

            -- 613534
            if texture then
                smallFrame.texture:SetTexture(texture);
                smallFrame.texture:SetSize(buttonSize, buttonSize);
            else
                smallFrame.texture:SetTexture("");
                smallFrame.texture:Hide();
                smallFrame:SetBackdrop({
                    bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                    tile = true,
                });
                smallFrame:SetBackdropColor(1,1,1,.5);
            end

            smallFrame:SetPoint("TOPLEFT", smallFrame:GetParent(), "TOPLEFT", offsetX, -offsetY);
        end

        for i=buttonsUsed + 1, table.getn(buttonPool) do
            buttonPool[i]:Hide();
        end
    end
    
    DrawSelectedItems();

    -- List all actions, highlighting selected ones
    local allActionsPanel = editor.itemsOptionsPanel.allActionsPanel;

    for s=1,72 do
        local slot = s;
        local type, gid = GetActionInfo(slot);
        local name, rank, icon, castTime, minRange, maxRange = "";

        local texture = GetActionTexture(slot);

        local i = s - 1;
        local row = math.floor(i / 12);
        local col = i % 12;

        local offsetX = col * (buttonSize + padding) + padding;
        local offsetY = row * (buttonSize + padding) + padding;

        local smallFrame = CreateButton(s, allActionsPanel);
        smallFrame:SetParent(allActionsPanel);
        smallFrame:SetSize(buttonSize, buttonSize);

        if texture then
            smallFrame.texture:SetTexture(texture);
            smallFrame.texture:SetSize(buttonSize, buttonSize);
        else
            smallFrame.texture:SetTexture("");
            smallFrame.texture:Hide();
            smallFrame:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                tile = true,
            });
            smallFrame:SetBackdropColor(1,1,1,.5);
        end

        local selected = selectedSet[slot] == true;
        if not selected then
            smallFrame:SetAlpha(.5);
        end

        smallFrame:SetPoint("TOPLEFT", smallFrame:GetParent(), "TOPLEFT", offsetX, -offsetY);
        
        local actionButton = {
            id = gid,
            frame = smallFrame,
            name = name,
            slot = slot,
            rank = rank,
            icon = icon,
            castTime = castTime,
            minRange = minRange,
            maxRange = maxRange,
            selected = selected,
        };
        
        smallFrame:EnableMouse();
        smallFrame:RegisterForClicks("LeftButton", "RightButton");
        smallFrame:SetScript("OnMouseUp", function(self, button)
            
            if button == "LeftButton" and not actionButton.selected then
                -- CanDo_Print("select: ", s);
                actionButton.frame:SetAlpha(1.0);
                actionButton.selected = true;
                
                table.insert(data.items, {
                    source = {
                        type = "actionbar",
                        slot = slot,
                    }
                })

                editor.redrawFrames();
                DrawSelectedItems();
            elseif button == "RightButton" and actionButton.selected then
                -- CanDo_Print("deselect: ", s);
                actionButton.frame:SetAlpha(.5);
                actionButton.selected = false;
                local toRemove;
                for k, v in pairs(data.items) do
                    if v.source.slot == actionButton.slot then
                        toRemove = k;
                    end
                end

                table.remove(data.items, toRemove);
                editor.redrawFrames();
                DrawSelectedItems();
            end
        end);
        smallFrame:SetScript("OnEnter", function(self, button)
            -- CanDo_Print("enter " .. s .. " " .. tostring(button));
            if not actionButton.selected then
                actionButton.frame:SetAlpha(.75);
            end
        end);
        smallFrame:SetScript("OnLeave", function(self, button)
            -- CanDo_Print("leave " .. s .. " ", actionButton.selected);
            if actionButton.selected then
                actionButton.frame:SetAlpha(1.0);
            else
                actionButton.frame:SetAlpha(.5);
            end
        end);
    end
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

        local newValue = math.floor(positioningForm.offsetXSlider:GetValue());
        editor.currentButton.data.display.positioning.offsetX = newValue;
        positioningForm.offsetXSlider.valueLabel:SetText(newValue);
        editor.redrawFrames();
    end)

    positioningForm.offsetYSlider:SetScript("OnValueChanged", function ()
        local newValue = math.floor(positioningForm.offsetYSlider:GetValue());
        editor.currentButton.data.display.positioning.offsetY = newValue;
        positioningForm.offsetYSlider.valueLabel:SetText(newValue);
        editor.redrawFrames();
    end)

    -- Arrangement Form
    local arrangementForm = editor.displayOptionsPanel.arrangementForm;

    arrangementForm.gridOptions.rowColSlider:SetScript("OnValueChanged", function ()
        local newValue = math.floor(arrangementForm.gridOptions.rowColSlider:GetValue());
        local arrangement = editor.currentButton.data.display.arrangement;
        if arrangement.rows == 0 then
            arrangement.columns = newValue;
        else
            arrangement.rows = newValue;
        end
        arrangementForm.gridOptions.rowColSlider.valueLabel:SetText(newValue);
        editor.redrawFrames();
    end)

    arrangementForm.gridOptions.paddingSlider:SetScript("OnValueChanged", function ()
        local newValue = math.floor(arrangementForm.gridOptions.paddingSlider:GetValue());
        editor.currentButton.data.display.arrangement.padding = newValue;
        arrangementForm.gridOptions.paddingSlider.valueLabel:SetText(newValue);
        editor.redrawFrames();
    end)

    arrangementForm.circleOptions.diameterSlider:SetScript("OnValueChanged", function ()
        local newValue = math.floor(arrangementForm.circleOptions.diameterSlider:GetValue());
        editor.currentButton.data.display.arrangement.diameter = newValue;
        arrangementForm.circleOptions.diameterSlider.valueLabel:SetText(newValue);
        editor.redrawFrames();
    end)
end
