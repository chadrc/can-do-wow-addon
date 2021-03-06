local CanDo_CreateInitialCharacterData = CanDo_CreateInitialCharacterData;
local CanDo_Print = CanDo_Print;

local ActiveData = {
    editorFrame = nil,
    frames = {}
}

SLASH_CANDO1 = "/cando";

local framePool = {};
local framesUsed = 0;
local buttonPool = {};
local buttonsUsed = 0;

local function NextFrameInPool()
    framesUsed = framesUsed + 1;
    return framePool[framesUsed];
end

local function NextButtonInPool()
    buttonsUsed = buttonsUsed + 1;
    local b = buttonPool[buttonsUsed];
    b:Show();
    return b;
end

function CanDo_SlashHandler() 
    ActiveData.editorFrame:Open(CanDoCharacterData.frames);
end

function CanDoMainFrame_OnLoad(self, event, ...)
    CanDo_Print("CanDo loaded");
    self:RegisterEvent("ADDON_LOADED");
    -- self:RegisterEvent("PLAYER_LOGIN");
    -- self:RegisterEvent("PLAYER_LOGOUT");
    -- self:RegisterEvent("VARIABLES_LOADED");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");

    ActiveData.editorFrame = CanDoEditorFrame;
    ActiveData.editorFrame.redrawFrames = CanDoMainFrame_RedrawFrames;
    CanDoEditor_Init(ActiveData.editorFrame);

    SlashCmdList["CANDO"] = CanDo_SlashHandler;

    -- Create resource pools
    for i=1,20 do
        local f = CreateFrame("Frame", "CanDoResourceFrame_" .. i, UIParent);
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",          
            tile = true
        })
        table.insert(framePool, f);
    end

    for i=1,100 do
        local b = CreateFrame("Button", "CanDoActionButtonFrame_" .. i, UIParent);
        b.texture = b:CreateTexture();
        local t = b:CreateFontString("CanDoActionButtonChargeText_" .. i, "ARTWORK", "GameFontNormal");
        t:SetParent(b);
        t:SetPoint("CENTER", b, "CENTER", 0, 0);
        b.chargeText = t;
        table.insert(buttonPool, b);
    end
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
        -- CanDoCharacterData = CanDo_CreateInitialCharacterData();
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
                    item.frame:SetAlpha(frame.frameData.display.activeButtonAlpha);
                else 
                    item.frame:SetAlpha(frame.frameData.display.inactiveButtonAlpha);
                end
            end
        end
    end
end

function CanDoMainFrame_RedrawFrames()
    CanDoMainFrame_CreateFrames(CanDoCharacterData);
end

function CanDoMainFrame_CreateFrames(data)
    framesUsed = 0;
    buttonsUsed = 0;
    for k, v in pairs(data.frames) do
        ActiveData.frames[k] = {
            frameData = v,
        }
        CanDoMainFrame_CreateGridFrame(v, ActiveData.frames[k]);
    end

    for i=framesUsed + 1, table.getn(framePool) do
        framePool[i]:Hide();
    end

    CanDo_Print("items: ", table.getn(data.frames[1].items))
    CanDo_Print("buttons used: ", buttonsUsed);
    for i=buttonsUsed + 1, table.getn(buttonPool) do
        buttonPool[i]:Hide();
    end
end

function CanDoMainFrame_CreateGridFrame(frame, activeFrame)
    local itemCount = table.getn(frame.items);

    local buttonSize = frame.display.buttonSize;

    local parentFrame = NextFrameInPool();
    parentFrame:ClearAllPoints();
    local backClr = frame.display.backgroundColor;
    parentFrame:SetBackdropColor(backClr.r, backClr.g, backClr.b, backClr.a);

    if frame.display.arrangement.type == "grid" then
        local rowCount = frame.display.arrangement.rows;
        local colCount = frame.display.arrangement.columns;
        local padding = frame.display.arrangement.padding;
    
        if colCount == 0 then
            -- should have rowCount
            colCount = math.ceil(itemCount / rowCount);
        elseif rowCount == 0 then
            -- should have colCount
            rowCount = math.ceil(itemCount / colCount);
        end

        activeFrame.totalWidth = buttonSize * colCount + padding * (colCount + 1);
        activeFrame.totalHeight = buttonSize * rowCount + padding * (rowCount + 1);

        activeFrame.colCount = colCount;
        activeFrame.rowCount = rowCount;
    elseif frame.display.arrangement.type == "circle" then
        activeFrame.angleStep = 360 / itemCount;
        activeFrame.radius = frame.display.arrangement.diameter / 2 - buttonSize / 2;
        activeFrame.totalWidth = frame.display.arrangement.diameter;
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
        actionButton.frame:ClearAllPoints();
        activeFrame.items[table.getn(activeFrame.items) + 1] = actionButton;

        local i = k - 1;
        if frame.display.arrangement.type == "grid" then
            local row = math.floor(i / activeFrame.colCount);
            local col = i % activeFrame.colCount;
        
            local offsetX = col * (buttonSize + frame.display.arrangement.padding) + frame.display.arrangement.padding;
            local offsetY = row * (buttonSize + frame.display.arrangement.padding) + frame.display.arrangement.padding;
    
            actionButton.frame:SetPoint("TOPLEFT", activeFrame.parentFrame, "TOPLEFT", offsetX, -offsetY);
        elseif frame.display.arrangement.type == "circle" then
            local angle = i * activeFrame.angleStep;

            local y = math.sin(math.rad(angle)) * activeFrame.radius;
            local x = math.cos(math.rad(angle)) * activeFrame.radius;
            
            actionButton.frame:SetPoint("CENTER", activeFrame.parentFrame, "CENTER", x, y);
        end
    end
end

function CanDoMainFrame_CreateCanDoItem(itemData, frame, activeFrame)
    -- will need to modify to support different sources
    local slot = itemData.source.slot;

    local buttonSize = frame.display.buttonSize;

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

    local smallFrame = NextButtonInPool();
    smallFrame:SetParent(activeFrame.parentFrame);
    smallFrame:SetSize(buttonSize, buttonSize);

    if texture then
        smallFrame.texture:SetPoint("CENTER");
        smallFrame.texture:SetTexture(texture);
        smallFrame.texture:SetAlpha(1);
        smallFrame.texture:SetSize(buttonSize, buttonSize);
        if not IsUsableAction(slot) then
            smallFrame:SetAlpha(frame.display.inactiveButtonAlpha);
        end
        smallFrame:SetBackdrop(nil);
    else
        smallFrame.texture:SetTexture("");
        smallFrame.texture:Hide();
        smallFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
            tile = true,
        });
        smallFrame:SetBackdropColor(1,1,1,.5);
    end

    local chargeText = smallFrame.chargeText;
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

function CanDoMainFrame_AddNewFrame(name)
    local n = CanDo_CreateEmptyFrame(name);
    table.insert(CanDoCharacterData.frames, n);

    return CanDoCharacterData.frames;
end

function CanDoMainFrame_RemoveFrame(index)
    table.remove(CanDoCharacterData.frames, index);
    return CanDoCharacterData.frames;
end