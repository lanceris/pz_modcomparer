require "ISUI/ISLayoutManager"
require "UI/MC_window"
require "MC_main"

MC_main.MC_btn = {}
local MC_btn = MC_main.MC_btn
local texOn = getTexture("media/textures/on.png")
local texOff = getTexture("media/textures/off.png")

MC_btn.active = false
MC_btn.toggleBtn = function(_, withUI)
    if MC_btn.active then
        MC_btn.active = false
        MC_btn.btn:setImage(texOff)
    else
        MC_btn.active = true
        MC_btn.btn:setImage(texOn)
        if not MC_main.window then
            MC_main.createUI()
        end
    end
    if withUI then
        MC_main.toggleUI(MC_main.window)
    end
end


local function MC_CreateButton()
    MC_btn.btn = ISButton:new(
        getCore():getScreenWidth() - 200, getCore():getScreenHeight() - 50, 25, 25, "")
    MC_btn.btn:setOnClick(MC_btn.toggleBtn, true)
    MC_btn.btn:initialise()
    MC_btn.btn:setImage(texOff)
    MC_btn.btn:setTooltip("Press me!")
    MC_btn.btn:setVisible(true)
    MC_btn.btn:setEnable(true)
    MC_btn.btn:addToUIManager()
end

-- Events.OnGameStart.Add(MC_CreateButton)

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
