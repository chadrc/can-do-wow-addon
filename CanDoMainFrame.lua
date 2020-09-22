local CanDo_CreateInitialCharacterData = CanDo_CreateInitialCharacterData;
local CanDo_Print = CanDo_Print;

local ActiveData = {
    frames = {}
}

function CanDoMainFrame_OnLoad(self, event, ...)
    CanDo_Print("CanDo loaded");
    self:RegisterEvent("ADDON_LOADED");
    -- self:RegisterEvent("PLAYER_LOGIN");
    -- self:RegisterEvent("PLAYER_LOGOUT");
    -- self:RegisterEvent("VARIABLES_LOADED");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
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

        self:SetScript("OnUpdate", CanDoMainFrame_OnUpdate);
        self:Show();

        -- Overwrite for testing
        CanDoCharacterData = CanDo_CreateInitialCharacterData();
    elseif event == "VARIABLES_LOADED" then
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Create bars
        CanDoMainFrame_CreateFrames(CanDoCharacterData);
    end
end

function CanDoMainFrame_OnUpdate(self, elapsed)
    for _, frame in pairs(ActiveData.frames) do
        for _, item in pairs(frame.items) do
            if item.frame.texture then
                local usable = IsUsableAction(item.slot);

                local start, duration, enable, modRate = GetActionCooldown(item.slot);
                local onCooldown = duration >= 1.4;
                
                if item.maxCharges > 1 then
                    local currentCharges = GetActionCharges(item.slot);
                    item.chargeText:SetText(currentCharges);
                end
    
                if usable and not onCooldown then
                    item.frame:SetAlpha(1);
                else 
                    item.frame:SetAlpha(.25);
                end
            end
        end
    end
end

function CanDoMainFrame_CreateFrames(data)
    for k, v in pairs(data.frames) do
        ActiveData.frames[k] = {}
        CanDoMainFrame_CreateGridFrame(v, ActiveData.frames[k]);
    end
end

function CanDoMainFrame_CreateGridFrame(frame, activeFrame)
    local itemCount = table.getn(frame.items);

    local buttonSize = frame.display.arrangement.buttonSize;

    local parentFrame = CreateFrame("Frame", "CanDoFrame_" .. frame.name, UIParent);
    parentFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",          
        tile = true
    });
    parentFrame:SetBackdropColor(0,0,0,.5);

    if frame.display.arrangement.type == "grid" then
        local rowCount = frame.display.arrangement.rows;
        local colCount = frame.display.arrangement.columns;
        local padding = frame.display.arrangement.padding;
        activeFrame.totalWidth = buttonSize * colCount + padding * (colCount + 1);
        activeFrame.totalHeight = buttonSize * rowCount + padding * (rowCount + 1);
    
        if colCount == 0 then
            -- should have rowCount
            colCount = math.ceil(itemCount / rowCount);
        elseif rowCount == 0 then
            -- should have colCount
            rowCount = math.ceil(itemCount / colCount);
        end

        activeFrame.colCount = colCount;
        activeFrame.rowCount = rowCount;
    elseif frame.display.arrangement.type == "circle" then
        activeFrame.angleStep = 360 / itemCount;
        if frame.display.arrangement.sizing == "absolute" then
            activeFrame.radius = frame.display.arrangement.diameter / 2 - buttonSize / 2;
            activeFrame.totalWidth = frame.display.arrangement.diameter;
        elseif frame.display.arrangement.sizing == "relative" then
            if frame.display.arrangement.relativeTo == "height" then
                local absDiameter = parentFrame:GetParent():GetHeight() * frame.display.arrangement.diameter;
                activeFrame.radius = absDiameter / 2 - buttonSize / 2;
                activeFrame.totalWidth = absDiameter;
            elseif frame.display.arrangement.relativeTo == "width" then
                local absDiameter = parentFrame:GetParent():GetWidth() * frame.display.arrangement.diameter;
                activeFrame.radius = absDiameter / 2 - buttonSize / 2;
                activeFrame.totalWidth = absDiameter;
            end
        end

        activeFrame.totalHeight = activeFrame.totalWidth;
    end

    parentFrame:SetSize(activeFrame.totalWidth, activeFrame.totalHeight);
    if frame.display.positioning.type == "absolute" then
        parentFrame:SetPoint(
            frame.display.positioning.anchor, 
            parentFrame:GetParent(),
            frame.display.positioning.relativeAnchor, 
            frame.display.positioning.offsetX,
            frame.display.positioning.offsetY
        );
    elseif frame.display.positioning.type == "relative" then
        local x = parentFrame:GetParent():GetWidth() * frame.display.positioning.offsetX;
        local y = parentFrame:GetParent():GetHeight() * frame.display.positioning.offsetY;
        parentFrame:SetPoint(
            frame.display.positioning.anchor,
            parentFrame:GetParent(),
            frame.display.positioning.relativeAnchor,
            x,
            y
        );
    end
    
    activeFrame.parentFrame = parentFrame;
    activeFrame.items = {};

    for k, v in pairs(frame.items) do
        local actionButton = CanDoMainFrame_CreateCanDoItem(v, frame, activeFrame);
        activeFrame.items[table.getn(activeFrame.items) + 1] = actionButton;

        if frame.display.arrangement.type == "grid" then
            local i = k - 1;
            local row = math.floor(i / activeFrame.colCount);
            local col = i % activeFrame.colCount;
        
            local offsetX = col * (buttonSize + frame.display.arrangement.padding) + frame.display.arrangement.padding;
            local offsetY = row * (buttonSize + frame.display.arrangement.padding) + frame.display.arrangement.padding;
    
            actionButton.frame:SetPoint("TOPLEFT", activeFrame.parentFrame, "TOPLEFT", offsetX, -offsetY);
        elseif frame.display.arrangement.type == "circle" then
            local radius = frame.display.arrangement.diameter / 2;
            -- cos = x / h
            -- sin = y / h
            local angle = (k - 1) * activeFrame.angleStep;

            local y = math.sin(math.rad(angle)) * activeFrame.radius;
            local x = math.cos(math.rad(angle)) * activeFrame.radius;
            
            actionButton.frame:SetPoint("CENTER", activeFrame.parentFrame, "CENTER", x, y);
        end
    end
end

function CanDoMainFrame_CreateCanDoItem(itemData, frame, activeFrame)
    -- will need to modify to support different sources
    local slot = itemData.source.slot;

    local buttonSize = frame.display.arrangement.buttonSize;

    local type, gid = GetActionInfo(slot);
    local name, rank, icon, castTime, minRange, maxRange = "";
    local texture = GetActionTexture(slot);
    
    if type == "spell" then
        name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(gid);
        -- print("Tex ture: " .. texture);
    elseif type ~= nil then
        -- print("Slot " .. s .. " has type " .. type)
    else
        -- print("Slot " .. s .. " is empty")
    end

    local smallFrame = CreateFrame("Button", "CanDoActionButton_" .. name, activeFrame.parentFrame);
    smallFrame:SetSize(buttonSize, buttonSize);

    if texture then
        smallFrame.texture = smallFrame:CreateTexture();
        smallFrame.texture:SetPoint("CENTER");
        smallFrame.texture:SetTexture(texture);
        smallFrame.texture:SetSize(buttonSize, buttonSize);
        smallFrame.texture:SetAlpha(1);
        if not IsUsableAction(slot) then
            smallFrame:SetAlpha(.25);
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

    local chargeText = smallFrame:CreateFontString("CanDoActionButtonText_" .. name, "ARTWORK", "GameFontNormal");
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

    return {
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
end