ModComparerWindow = ISPanelJoypad:derive("ModComparerWindow")


function ModComparerWindow:initialise()
    ISRichTextPanel.initialise(self)
end

function ModComparerWindow:createChildren()
    local btnH = math.max(25, self.fontHgt + 3 * 2)


    --region close button
    self.closeButton = ISButton:new(self.margin, self.margin, 24, 24, "", self, self.close)
    self.closeButton:initialise()
    self.closeButton.borderColor.a = 0.0
    self.closeButton.backgroundColor.a = 0
    self.closeButton.backgroundColorMouseOver.a = 1
    self.closeButton:setImage(self.closeButtonTexture)
    self:addChild(self.closeButton);
    --endregion

    --region condense button
    self.buttonCondense = ISButton:new(self.closeButton:getRight() + 2, self.margin, 24, 24, "", self,
        self.onOptionMouseDown)
    self.buttonCondense.internal = "CONDENSE"
    self.buttonCondense.borderColor.a = 0.0
    self.buttonCondense.isOn = false
    self.buttonCondense:setImage(self.condenseOffTexture)
    self.buttonCondense:setTooltip(getText("UI_ButtonCondensedViewOffTooltip"))
    self.buttonCondense:initialise()

    --endregion

    --region title
    self.title = ISLabel:new(self.buttonCondense:getRight() + 2, self.margin, self.fontTitleHgt, getText('IGUI_MCTitle'),
        1,
        1, 1,
        1, self.fontTitle,
        true)
    self.title:initialise()
    --endregion

    --region text panel
    local tY = math.max(self.title.height, self.buttonCondense.height) + 4 * self.margin
    local tH = self.height - tY - 2 * self.margin - btnH
    self.table = ISScrollingListBox:new(self.margin, tY,
        self.width - 2 * self.margin, tH
    )
    self.table:initialise()
    self.table:instantiate()
    self.table.itemheight = self.fontHgt + 4 * 2
    self.table.selected = 0
    self.table.font = self.font
    self.table.doDrawItem = self.doDrawItem
    -- self.table.onMouseMove = self.onMouseMoveTable
    self.table.drawBorder = true
    self.table:addColumn(getText('IGUI_ModsInSave'), 0)
    self.table:addColumn(getText('IGUI_EnabledMods'), self.table.width / 2)
    --endregion

    --region buttons
    local btnW = 100
    local btnY = self.height - self.margin - btnH
    --region load save
    local btnX = self.margin
    self.buttonLoadSave = ISButton:new(btnX, btnY, btnW, btnH, getText('IGUI_ButtonLoadSave'), self,
        self.onOptionMouseDown)
    self.buttonLoadSave.internal = "LOADSAVE"
    self.buttonLoadSave:setTooltip(getText("UI_ButtonLoadSaveTooltip", getText("IGUI_ModsInSave")))
    btnX = self.buttonLoadSave:getRight() + self.margin
    --endregion

    --region update enabled
    self.buttonUpdateFromEnabled = ISButton:new(btnX, btnY, btnW, btnH,
        getText('IGUI_ButtonUpdateFromEnabled'), self,
        self.onOptionMouseDown)
    -- self.buttonUpdateSave:setX(self.table.x + self.table.width - self.buttonUpdateSave:getWidth())
    self.buttonUpdateFromEnabled.internal = "UPDATEENAB"
    self.buttonUpdateFromEnabled:setTooltip(getText("UI_ButtonUpdateFromEnabledTooltip", getText("IGUI_ModsInSave"),
        getText("IGUI_EnabledMods")))
    btnX = self.buttonUpdateFromEnabled:getRight() + self.margin
    --endregion

    --region update save
    self.buttonUpdateFromSave = ISButton:new(btnX, btnY, btnW, btnH,
        getText('IGUI_ButtonUpdateFromSave'), self,
        self.onOptionMouseDown)
    self.buttonUpdateFromSave.internal = "UPDATESAVE"
    self.buttonUpdateFromSave:setTooltip(getText("UI_ButtonUpdateFromSaveTooltip", getText("IGUI_EnabledMods"),
        getText("IGUI_ModsInSave")))
    btnX = self.buttonUpdateFromSave:getRight() + self.margin
    --endregion



    --region load enabled

    self.buttonLoadEnabled = ISButton:new(btnX, btnY, btnW, btnH, getText('IGUI_ButtonLoadEnabled'), self,
        self.onOptionMouseDown)
    self.buttonLoadEnabled.internal = "LOADANY"
    self.buttonLoadEnabled:setTooltip(getText("UI_ButtonLoadEnabledTooltip", getText("IGUI_EnabledMods")))
    btnX = self.buttonLoadEnabled:getRight() + self.margin

    --endregion
    --endregion

    self:setWidth(btnX)
    self:setX(getCore():getScreenWidth() / 2 - self.width / 2)
    self:setY(getCore():getScreenHeight() / 2 - self.height / 2)
    self.table:setWidth(self.width - 2 * self.margin)
    self.table.columns[2].size = self.table.width / 2
    self.title:setX(self.width / 2 - self.title.width / 2)
    self:addChild(self.title)
    self:addChild(self.table)
    self:addChild(self.buttonCondense)
    self:addChild(self.buttonLoadSave)
    self:addChild(self.buttonUpdateFromEnabled)
    self:addChild(self.buttonUpdateFromSave)
    self:addChild(self.buttonLoadEnabled)

    self._mods = copyTable(self.mods)
end

function ModComparerWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    -- if MC_main.MC_btn and MC_main.MC_btn.btn then
    --     MC_main.MC_btn.toggleBtn()
    -- end
end

function ModComparerWindow:populate()
    self.table:clear()
    local wMax1 = self.table.columns[2].size - self.table.x
    local wMax2 = self.table.width - self.table.columns[2].size
    for i, row in ipairs(self._mods) do
        local avMod = row.sav ~= "" and row.sav or row.cur
        row.info = MC_main.getModInfo(avMod)

        local w = getTextManager():MeasureStringX(self.font, row.info.name)
        local item = self.table:addItem(i, row)
        if w > wMax1 or w > wMax2 then
            item.tooltip = row.info.name
        end
    end
end

function ModComparerWindow:doDrawItem(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local sc = {
        x = 0, y = y, w = self.width, h = item.height - 1, r = 1, g = 1, b = 1, a = 1
    }
    local savT = item.item.sav
    local curT = item.item.cur
    if item.item.out == "-" then
        sc.r = 0.286
        sc.g = 0.333
        sc.b = 0.192
        self:drawRect(sc.x, sc.y, sc.w, sc.h, sc.a, sc.r, sc.g, sc.b)
        curT = item.item.info.name
    elseif item.item.out == "+" then
        sc.r = 0.286
        sc.g = 0.086
        sc.b = 0.084
        self:drawRect(sc.x, sc.y, sc.w, sc.h, sc.a, sc.r, sc.g, sc.b)
        savT = item.item.info.name
    elseif item.item.out == "." then
        curT = item.item.info.name
        savT = item.item.info.name
    end

    self:drawRectBorder(0, (y), self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height - 10, y + self:getYScroll() + self.itemheight)
    local xoffset = 10
    local a = 0.9
    local itemPadY = self.itemPadY or (item.height - self.fontHgt) / 2

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(savT, xoffset, y + itemPadY, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    self:drawText(curT, clipX2 + xoffset, y + itemPadY, 1, 1, 1, a, self.font)


    y = y + item.height
    return y
end

function ModComparerWindow:applyCondense(state)
    local newMods = {}
    if state then
        newMods = self.diff
    else
        newMods = self.mods
    end
    self._mods = newMods
    self:populate()
end

function ModComparerWindow:toggleCondenseState()
    self.buttonCondense.isOn = not self.buttonCondense.isOn
    if not self.buttonCondense.isOn then
        self.buttonCondense:setImage(self.condenseOffTexture)
        self.buttonCondense:setTooltip(getText("UI_ButtonCondensedViewOffTooltip"))
        self:applyCondense(false)
    else
        self.buttonCondense:setImage(self.condenseOnTexture)
        self.buttonCondense:setTooltip(getText("UI_ButtonCondensedViewOnTooltip"))
        self:applyCondense(true)
    end
end

function ModComparerWindow:onOptionMouseDown(button, x, y)
    local defaultMods = ActiveMods.getById("default")
    local currentMods = ActiveMods.getById("currentGame")
    local saveInfo = getSaveInfo(getWorld():getWorld())
    local saveMods = saveInfo.activeMods

    if button.internal == "CONDENSE" then
        self:toggleCondenseState()
        return
    end
    if button.internal == "LOADSAVE" then
        currentMods:copyFrom(saveMods)
    end
    if button.internal == "UPDATEENAB" then
        defaultMods:copyFrom(saveMods)
        saveModsFile()
        currentMods:copyFrom(saveMods)
        -- Remove mod IDs for missing mods from ActiveMods.mods
        currentMods:checkMissingMods()
        -- Remove unused map directories from ActiveMods.mapOrder
        currentMods:checkMissingMaps()
    end
    if button.internal == "UPDATESAVE" then
        saveMods:copyFrom(currentMods)
        local fullSaveName = saveInfo.gameMode .. "\\" .. saveInfo.saveName
        manipulateSavefile(fullSaveName, "WriteModsDotTxt")
    end
    if button.internal == "LOADANY" then
        -- continue loading as usual
    end
    local requireReset = ActiveMods.requiresResetLua(currentMods)
    MainScreen._continue(not requireReset)
end

function ModComparerWindow:onMouseMove(dx, dy)
    self.mouseOver = true

    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
end

function ModComparerWindow:onMouseMoveOutside(dx, dy)
    self.mouseOver = false

    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
end

function ModComparerWindow:onMouseUp(x, y)
    self.moving = false
end

function ModComparerWindow:onMouseUpOutside(x, y)
    self.moving = false
end

function ModComparerWindow:onMouseDown(x, y)
    self.moving = true
end

function ModComparerWindow:new(x, y, width, height, mods, diff)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.mods = mods
    o.diff = diff
    o.margin = 10
    o.backgroundColor.a = 1
    o.borderColor.a = 1
    o.font = UIFont.NewSmall
    o.fontHgt = getTextManager():getFontHeight(o.font)
    o.fontTitle = UIFont.Medium
    o.fontTitleHgt = getTextManager():getFontHeight(o.font)
    o.closeButtonTexture = getTexture("media/ui/Dialog_Titlebar_CloseIcon.png")
    o.condenseOnTexture = getTexture("media/textures/off.png")
    o.condenseOffTexture = getTexture("media/textures/on.png")

    o:instantiate()
    o:setAlwaysOnTop(true)
    o.javaObject:setIgnoreLossControl(true)
    return o
end
