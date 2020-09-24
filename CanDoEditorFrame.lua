
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

    function editor:DrawFramesList(data)
        local prevButton;
        if table.getn(data) > 0 then 
            local function CreateButton(d) 
                local button = CreateFrame(
                    "Button", 
                    editor.framesList:GetName() .. "FrameButton" .. d.name, 
                    editor.framesList, 
                    "CanDoEditorFrameListItemButton"
                );
                button:SetText(d.name);
                button.data = d;
	            button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
                button:SetScript("OnClick", function ()
                    button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 0);
                    button:LockHighlight();
                    CanDoEditorUpdateDisplayPanel(editor, button.data);

                    editor.currentPanel:Show();
                    editor.createPanel:Hide();

                    if editor.currentButton then
                        editor.currentButton:UnlockHighlight();
                    end
                    editor.currentButton = button;
                end)
                return button;
            end

            prevButton = CreateButton(data[1]);

            for i=2,table.getn(data) do
                local button = CreateButton(data[i]);
                button:ClearAllPoints(); 
                button:SetPoint("TOP", prevButton, "BOTTOM", 0, -5);
                prevButton = button;
            end
        end

        local button = CreateFrame(
            "Button", 
            editor.framesList:GetName() .. "FrameButtonCreate",
            editor.framesList, 
            "CanDoEditorFrameListItemButton"
        );
        button:SetText("Create");

        button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        button:SetScript("OnClick", function ()
            CanDo_Print("Create");
            button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 0);
            button:LockHighlight();

            editor.currentPanel:Hide();
            editor.createPanel:Show();

            if editor.currentButton then
                editor.currentButton:UnlockHighlight();
            end
            editor.currentButton = button;
        end)

        if prevButton then
            button:ClearAllPoints(); 
            button:SetPoint("TOP", prevButton, "BOTTOM", 0, -5);
        end
    end

    function editor:Open(data)
        editor:DrawFramesList(data);

        editor:Show();
    end

    editor.createPanel.createButton:SetScript("OnClick", function ()
        local newFrameName = editor.createPanel.nameInput:GetText():gsub("%s+", "");
        if string.len(newFrameName) > 0 then
            CanDo_Print("Creating: ", newFrameName);
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