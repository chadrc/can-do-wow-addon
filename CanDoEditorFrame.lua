
function CanDoEditor_Init(editor)
    CanDo_Print(editor.displayToggleTab:Deactivate())

    editor.itemsToggleTab:SetOnActivate(function ()
        CanDoEditorOnItemsTabClicked(editor);
    end);
    editor.displayToggleTab:SetOnActivate(function ()
        CanDoEditorOnDisplayTabClicked(editor);
    end);
end

function CanDoEditor_Open(editor)
    local prevButton = CreateFrame("Button", editor.framesList:GetName() .. "FrameButton" .. 0, editor.framesList, "CanDoEditorFrameListItemButton");
    prevButton:SetText("Frame 0");
    for i=1,10 do
        local button = CreateFrame("Button", editor.framesList:GetName() .. "FrameButton" .. i, editor.framesList, "CanDoEditorFrameListItemButton");
        button:ClearAllPoints(); 
        button:SetPoint("TOP", prevButton, "BOTTOM", 0, -5);
        button:SetText("Frame " .. i);
        prevButton = button;
    end

    editor:Show();
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
