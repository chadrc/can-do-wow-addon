local CanDo_CreateInitialCharacterData = CanDo_CreateInitialCharacterData;
local CanDo_Print = CanDo_Print;

local ActiveData = {
    frames = {}
}

function CanDoMainFrame_OnLoad(self, event, ...)
    CanDo_Print("CanDo loaded");
    self:RegisterEvent("ADDON_LOADED");
    self:RegisterEvent("PLAYER_LOGOUT");
end

function CanDoMainFrame_OnEvent(self, event, ...)
    CanDo_Print("event - ", event);
    if event == "ADDON_LOADED" and ... == "CanDo" then
        if CanDoCharacterData == nil then
            CanDo_Print("Created initial CanDo bar.");
            CanDoCharacterData = CanDo_CreateInitialCharacterData();
        else
            CanDo_Print("Character data loaded.");
        end

        -- Overwrite for testing
        CanDoCharacterData = CanDo_CreateInitialCharacterData();

        -- Create bars
        CanDoMainFrame_CreateFrames(CanDoCharacterData);
    end
end

function CanDoMainFrame_CreateFrames(data)
    for k, v in pairs(data.frames) do
        if v.display.arrangement.type == "grid" then
            ActiveData.frames[k] = {}
            CanDoMainFrame_CreateGridFrame(v, ActiveData.frames[k]);
        end
    end
end

function CanDoMainFrame_CreateGridFrame(frame, activeFrame)
    local itemCount = table.getn(frame.items);
    local rowCount = frame.display.arrangement.rows;
    local colCount = frame.display.arrangement.columns;
    local padding = frame.display.arrangement.padding;
    local buttonSize = frame.display.arrangement.buttonSize;
    local totalWidth = buttonSize * colCount + padding * (colCount + 1);
    local totalHeight = buttonSize * rowCount + padding * (rowCount + 1);

    local parentFrame = CreateFrame("Frame", "CanDoFrame_" .. frame.name, UIParent);
    parentFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",          
        tile = true
    });
    parentFrame:SetBackdropColor(0,0,0,.5);
    parentFrame:SetSize(totalWidth, totalHeight);
    if frame.display.positioning.type == "relative" then
        parentFrame:SetPoint(
            frame.display.positioning.anchor, 
            "UIParent", 
            frame.display.positioning.relativeAnchor, 
            frame.display.positioning.offsetX,
            frame.display.positioning.offsetY
        );
    end
    
    activeFrame.parentFrame = parentFrame;
    activeFrame.items = {};

    for k, v in pairs(frame.items) do
        CanDoMainFrame_CreateCanDoItem(k, v, frame, activeFrame);
    end
end

function CanDoMainFrame_CreateCanDoItem(itemNum, itemData, frame, activeFrame)
    -- will need to modify to support different sources
    local slot = itemData.source.slot;

    local padding = frame.display.arrangement.padding;
    local buttonSize = frame.display.arrangement.buttonSize;
    local rowCount = frame.display.arrangement.rows;
    local colCount = frame.display.arrangement.columns;

    local type, gid = GetActionInfo(slot);
    local name, rank, icon, castTime, minRange, maxRange = "";
    local usable = false;
    local texture = GetActionTexture(slot);
    
    if type == "spell" then
        name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(gid);
        usable = IsUsableSpell(gid);
        -- print("Texture: " .. texture);
    elseif type ~= nil then
        -- print("Slot " .. s .. " has type " .. type)
    else
        -- print("Slot " .. s .. " is empty")
    end

    local i = itemNum - 1;
    local row = math.floor(i / colCount);
    local col = i % colCount;

    local offsetX = col * (buttonSize + padding) + padding;
    local offsetY = row * (buttonSize + padding) + padding;

    local smallFrame = CreateFrame("Button", nil, activeFrame.parentFrame);

    if texture then
        smallFrame.texture = smallFrame:CreateTexture();
        smallFrame:SetSize(buttonSize, buttonSize);
        smallFrame.texture:SetPoint("CENTER");
        smallFrame.texture:SetTexture(texture);
        smallFrame.texture:SetSize(buttonSize, buttonSize);
        smallFrame.texture:SetAlpha(1);
        if not IsUsableAction(slot) then
            smallFrame.texture:SetAlpha(.25);
        end

        if not IsPlayerSpell(gid) then
            smallFrame.texture:SetDesaturated(true);
            smallFrame:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                tile = true,
                insets = {
                    top = 2,
                    bottom = 2,
                    left = 2,
                    right = 2,
                }
            });
            smallFrame:SetBackdropColor(1,0,0,1);
        end
    else
        smallFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
            tile = true,
        });
        smallFrame:SetBackdropColor(0,0,0,.5);
    end

    local chargeText = smallFrame:CreateFontString("eCoordinatesFontString", "ARTWORK", "GameFontNormal");
    chargeText:SetParent(smallFrame);
    chargeText:SetPoint("CENTER", smallFrame, "CENTER", 0, 0);
    chargeText:SetFont(chargeText:GetFont(), buttonSize / 2, "OUTLINE");
    chargeText:SetTextColor(0, 0.9, 0, 1.0);
    chargeText:SetText("0");
    local currentCharges, maxCharges = GetActionCharges(slot);

    if maxCharges > 1 then
        chargeText:SetText(currentCharges);
        chargeText:Show();
    else
        chargeText:Hide();
    end

    smallFrame:SetPoint("TOPLEFT", activeFrame.parentFrame, "TOPLEFT", offsetX, -offsetY);
    
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
        chargeText = chargeText,
        maxCharges = maxCharges,
    };

    activeFrame.items[table.getn(activeFrame.items) + 1] = actionButton;
end