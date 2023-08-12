ModComparerWindow = ISPanel:derive("ModComparerWindow")


function ModComparerWindow:initialise()
    ISRichTextPanel.initialise(self)
end

function ModComparerWindow:createChildren()
    local btnH = math.max(25, self.fontHgt + 3 * 2)


    --region close button
    self.closeButton = ISButton:new(self.margin, 7, 24, 24, "", self, self.close)
    self.closeButton:initialise()
    self.closeButton.borderColor.a = 0.0
    self.closeButton.backgroundColor.a = 0
    self.closeButton.backgroundColorMouseOver.a = 1
    self.closeButton:setImage(self.closeButtonTexture)
    self:addChild(self.closeButton);
    --endregion

    --region title
    self.title = ISLabel:new(self.closeButton:getRight() + 2, self.margin, self.fontHgt, getText('IGUI_MCTitle'), 1, 1, 1,
        1, self.font,
        true)
    self.title:initialise()
    --endregion

    --region text panel
    local tY = self.title.height + 4 * self.margin
    local tH = self.height - tY - 2 * self.margin - btnH
    self.table = ISScrollingListBox:new(self.margin, tY,
        self.width - 2 * self.margin, tH + 10
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
    --ISButton:new(x, y, width, height, title, clicktarget, onclick, onmousedown, allowMouseUpProcessing)
    local btnX = self.margin
    self.buttonLoadSave = ISButton:new(btnX, btnY, btnW, btnH, getText('IGUI_ButtonLoadSave'), self,
        self.onOptionMouseDown)
    self.buttonLoadSave.internal = "LOADSAVE"
    btnX = self.buttonLoadSave:getRight() + self.margin
    --endregion

    --region update save
    self.buttonUpdateSave = ISButton:new(btnX, btnY, btnW, btnH, getText('IGUI_ButtonUpdateSave'), self,
        self.onOptionMouseDown)
    self.buttonUpdateSave.internal = "UPDATE"
    btnX = self.buttonUpdateSave:getRight() + self.margin
    --endregion

    --region load anyway

    self.buttonLoadAnyway = ISButton:new(btnX, btnY, btnW, btnH, getText('IGUI_ButtonLoadAnyway'), self,
        self.onOptionMouseDown)
    self.buttonLoadAnyway.internal = "LOADANY"
    btnX = self.buttonLoadAnyway:getRight() + self.margin

    --endregion
    --endregion

    self:addChild(self.title)
    self:addChild(self.table)
    self:addChild(self.buttonLoadSave)
    self:addChild(self.buttonUpdateSave)
    self:addChild(self.buttonLoadAnyway)
    -- df:df()
end

function ModComparerWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    -- MC_main.toggleUI(self)
    if MC_btn.btn then
        MC_btn.toggleBtn() -- FIXME remove in prod
    end
end

function ModComparerWindow:populate()
    self.table:clear()
    local wMax1 = self.table.columns[2].size - self.table.x
    local wMax2 = self.table.width - self.table.columns[2].size
    for i, row in ipairs(self.mods) do
        local avMod = row.sav and row.sav or row.cur
        row.info = MC_main.getModInfo(avMod)

        local w1 = getTextManager():MeasureStringX(self.font, row.sav)
        local w2 = getTextManager():MeasureStringX(self.font, row.cur)
        local item = self.table:addItem(i, row)
        if w1 > wMax1 then
            item.tooltip = row.sav
        elseif w2 > wMax2 then
            item.tooltip = row.cur
        end
    end
end

function ModComparerWindow:reload()
    self.mods = MC_main.calculate()
    self:populate()
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
        savT = item.item.info.name
    elseif item.item.out == "+" then
        sc.r = 0.286
        sc.g = 0.086
        sc.b = 0.084
        self:drawRect(sc.x, sc.y, sc.w, sc.h, sc.a, sc.r, sc.g, sc.b)
        curT = item.item.info.name
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

function ModComparerWindow:onOptionMouseDown(button, x, y)
    if button.internal == "LOADSAVE" then
        df:df()
    end
    if button.internal == "UPDATE" then
        self:reload()
    end
    if button.internal == "LOADANY" then

    end
end

function ModComparerWindow:onMouseMove(dx, dy)
    self.mouseOver = true

    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        -- self:bringToTop()
    end
end

function ModComparerWindow:onMouseMoveOutside(dx, dy)
    self.mouseOver = false

    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        -- self:bringToTop()
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

function ModComparerWindow:new(x, y, width, height, mods)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.mods = mods
    o.margin = 10
    o.backgroundColor.a = 1
    o.borderColor.r = 1
    o.borderColor.a = 1
    o.font = UIFont.Small
    o.fontHgt = getTextManager():getFontHeight(o.font)
    o.closeButtonTexture = getTexture("media/ui/Dialog_Titlebar_CloseIcon.png")

    o:instantiate()
    o:setAlwaysOnTop(true)
    o.javaObject:setIgnoreLossControl(true)
    return o
end

-- MainScreen.continueLatestSaveAux

-- function ModComparerWindow:cellAt(x, y)
--     local y0 = 0
--     local col
--     local res = {}
--     for i, v in ipairs(self.items) do
--         if not v.height then v.height = self.itemheight end -- compatibililty
--         if y >= y0 and y < y0 + v.height then
--             res.row = i
--             if self.columns then
--                 for j = 1, #self.columns do
--                     if j == 1 and x > 0 and x < self.columns[j + 1].size then
--                         col = 1
--                     elseif j == #self.columns and x > self.columns[j].size and x < self.width then
--                         col = #self.columns
--                     elseif x > self.columns[j].size and x < self.columns[j + 1].size then
--                         col = j
--                     end
--                     if col then res.col = col end
--                 end
--             end
--             return res
--         end
--         y0 = y0 + v.height
--     end
--     return -1
-- end

-- function ModComparerWindow:onMouseMoveTable(dx, dy)
--     ISScrollingListBox.onMouseMove(self, dx, dy)
--     self.mouseovercell = self.parent.cellAt(self, self:getMouseX(), self:getMouseY())
--     if self.mouseovercell.col then
--         -- print(self.mouseovercell.row .. "|" .. self.mouseovercell.col)
--     end
-- end
