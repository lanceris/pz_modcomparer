require "ISUI/ISLayoutManager"
require "UI/MC_window"
require "MC_main"
MC_btn = {}
local texOn = getTexture("media/textures/on.png")
local texOff = getTexture("media/textures/off.png")

MC_btn.active = false
MC_btn.toggleBtn = function(_, withUI)
    if MC_btn.active then
        MC_btn.active = false
        MC_btn.btn:setImage(texOff)
        -- window:setVisible(false)
        -- window:removeFromUIManager()
        -- window = nil
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
