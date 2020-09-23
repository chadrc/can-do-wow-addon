
function CanDoEditor_Init(editor)
    CanDo_Print(editor.displayToggleTab:Deactivate())

    editor.itemsToggleTab:SetOnActivate(function ()
        CanDoEditorOnItemsTabClicked(editor);
    end);
    editor.displayToggleTab:SetOnActivate(function ()
        CanDoEditorOnDisplayTabClicked(editor);
    end);

    function editor:Open(data)
        if table.getn(data) > 0 then 
            local prevButton = CreateFrame("Button", editor.framesList:GetName() .. "FrameButton" .. 1, editor.framesList, "CanDoEditorFrameListItemButton");
            
            prevButton:SetText(data[1].name);
            
            for i=2,table.getn(data) do
                local button = CreateFrame("Button", editor.framesList:GetName() .. "FrameButton" .. i, editor.framesList, "CanDoEditorFrameListItemButton");
                button:ClearAllPoints(); 
                button:SetPoint("TOP", prevButton, "BOTTOM", 0, -5);
                button:SetText(data[i].name);
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
