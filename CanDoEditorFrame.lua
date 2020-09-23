
function CanDoEditor_Init(editor)
    CanDo_Print(editor.displayToggleTab:Deactivate())
    tinsert(UISpecialFrames, editor:GetName());

    editor.itemsToggleTab:SetOnActivate(function ()
        CanDoEditorOnItemsTabClicked(editor);
    end);
    editor.displayToggleTab:SetOnActivate(function ()
        CanDoEditorOnDisplayTabClicked(editor);
    end);

    function editor:Open(data)
        if table.getn(data) > 0 then 

            local function CreateButton(d) 
                local button = CreateFrame(
                    "Button", 
                    editor.framesList:GetName() .. "FrameButton" .. d.name, editor.framesList, 
                    "CanDoEditorFrameListItemButton"
                );
                button:SetText(d.name);
                button.data = d;
	            button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
                button:SetScript("OnClick", function ()
                    button:GetHighlightTexture():SetVertexColor(1.0, 1.0, 0);
                    button:LockHighlight();
                    CanDoEditorUpdateDisplayPanel(editor, button.data);
                end)
                return button;
            end

            local prevButton = CreateButton(data[1]);

            for i=2,table.getn(data) do
                local button = CreateButton(data[i]);
                button:ClearAllPoints(); 
                button:SetPoint("TOP", prevButton, "BOTTOM", 0, -5);
                prevButton = button;
            end
        end

        editor:Show();
    end
end

function CanDoEditorOnDisplayTabClicked(editor)
    editor.itemsOptionsPanel:Hide();
    editor.itemsToggleTab:Activate();

    editor.displayOptionsPanel:Show();
end

function CanDoEditorOnItemsTabClicked(editor)
    editor.itemsOptionsPanel:Show();

    editor.displayOptionsPanel:Hide();
    editor.displayToggleTab:Activate();
end

function CanDoEditorUpdateDisplayPanel(editor, data)
    local display = editor.displayOptionsPanel;

    display.title:SetText(data.name);
end
