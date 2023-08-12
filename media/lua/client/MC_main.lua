require 'OptionScreens/MainScreen'
MC_main = {}

MC_main.getMods = function()
    local defaultMods = ActiveMods.getById("default")
    local currentMods = ActiveMods.getById("currentGame")
    currentMods:copyFrom(defaultMods)
    currentMods = currentMods:getMods()
    local saveMods = getSaveInfo(getWorld():getWorld()).activeMods:getMods()

    return currentMods, saveMods
end

MC_main.arrayListToTable = function(arr)
    local tab = {}
    for i = 0, arr:size() - 1 do
        table.insert(tab, arr:get(i))
    end
    return tab
end

MC_main.getModInfo = function(modId)
    local res = { id = modId }
    if not modId or modId == "" then return res end
    local info = getModInfoByID(modId)
    res = {
        workshopId = info:getWorkshopID(),
        name = info:getName(),
        dir = info:getDir(),
        desc = info:getDescription(),
        -- req = info:getRequire(),
        -- isAv = info:isAvailable(),
        -- url = info:getUrl(),
        -- vMin = info:getVersionMin(),
        -- vMax = info:getVersionMax(),
        -- packs = info:getPacks(),
        -- tileDefs = info:getTileDefs(),
    }
    return res
end

MC_main.empty = function(tab)
    for _, _ in pairs(tab) do return false; end
    return true
end

MC_main.tableSize = function(table1)
    if not table1 then return 0 end
    local count = 0
    for _, _ in pairs(table1) do
        count = count + 1
    end
    return count
end

MC_main.areTablesDifferent = function(table1, table2)
    local size1 = MC_main.tableSize(table1)
    local size2 = MC_main.tableSize(table2)
    if size1 ~= size2 then return true end
    if size1 == 0 then return false end
    for k1, v1 in pairs(table1) do
        if table2[k1] ~= v1 then
            return true
        end
    end
    return false
end

local function pop(tab)
    return table.remove(tab, #tab)
end

local function indexOf(tab, val)
    for i = 1, #tab do
        if tab[i] == val then
            return i
        end
    end
    return 0
end

local function afterIndex(tab, ix)
    local result = {}
    for i = 1, #tab do
        local item = tab[i]
        if indexOf(tab, item) > ix then
            table.insert(result, item)
        end
    end
    return result
end

local function reverse(tab)
    for i = 1, math.floor(#tab / 2), 1 do
        tab[i], tab[#tab - i + 1] = tab[#tab - i + 1], tab[i]
    end
    return tab
end

MC_main.calculate = function()
    local currentMods, saveMods = MC_main.getMods()
    currentMods = MC_main.arrayListToTable(currentMods)
    saveMods = MC_main.arrayListToTable(saveMods)
    -- saveMods = { "a", "b", "c", "d", "e" }
    -- currentMods = { "a", "b", "c", "e", "d" }
    local result = {}
    if not MC_main.areTablesDifferent(saveMods, currentMods) then
        return result
    end

    currentMods = reverse(currentMods)
    saveMods = reverse(saveMods)

    local sav = pop(saveMods)
    local cur = pop(currentMods)
    while sav and cur do
        if sav == cur then
            table.insert(result, { sav = sav, cur = cur, out = "." })
            sav = table.remove(saveMods, #saveMods)
            cur = table.remove(currentMods, #currentMods)
        else
            local savIx = indexOf(saveMods, sav)
            local curIx = indexOf(currentMods, cur)
            local savInCur
            local curInSav
            for _, item in pairs(afterIndex(currentMods, curIx)) do
                if item == sav then
                    savInCur = item
                    break
                end
            end
            for _, item in pairs(afterIndex(saveMods, savIx)) do
                if item == cur then
                    curInSav = item
                    break
                end
            end
            if savInCur and curInSav then
                local savGap = indexOf(currentMods, savInCur) - indexOf(currentMods, cur)
                local curGap = indexOf(saveMods, curInSav) - indexOf(saveMods, sav)
                if savGap > curGap then
                    table.insert(result, { sav = "", cur = cur, out = "-" })
                    cur = pop(currentMods)
                else
                    table.insert(result, { sav = sav, cur = "", out = "+" })
                    sav = pop(saveMods)
                end
            elseif not savInCur then
                table.insert(result, { sav = sav, cur = "", out = "+" })
                sav = pop(saveMods)
            elseif not curInSav then
                table.insert(result, { sav = "", cur = cur, out = "-" })
                cur = pop(currentMods)
            else
                error("error in logic 2")
                break
            end
        end
    end
    while sav do
        table.insert(result, { sav = sav, cur = "", out = "+" })
        sav = pop(saveMods)
    end
    while cur do
        table.insert(result, { sav = "", cur = cur, out = "-" })
        cur = pop(currentMods)
    end

    return result
end

MC_main.toggleUI = function(ui)
    ui = ui or MC_main.window
    if ui then
        if ui:getIsVisible() then
            ui:setVisible(false)
            ui:removeFromUIManager()
            ui._visible = false
        else
            ui:setVisible(true)
            ui:addToUIManager()
            ui._visible = true
        end
    end
end

MC_main.createUI = function()
    if MC_main.window then
        MC_main.window:setVisible(false)
        MC_main.window:removeFromUIManager()
        MC_main.window = nil
    end
    MC_main.mods = MC_main.calculate()
    if MC_main.empty(MC_main.mods) then
        MC_main.mods = nil
        return
    end

    local win = {
        x = getCore():getScreenWidth() / 2,
        y = getCore():getScreenHeight() / 2,
        w = 400,
        h = 600
    }
    MC_main.window = ModComparerWindow:new(win.x - win.w / 2, win.y - win.h / 2, win.w, win.h, MC_main.mods)
    MC_main.window:initialise()
    MC_main.window:populate()
    MC_main.window:setVisible(true)
    MC_main.window:addToUIManager()
end

MainScreen._continue = MainScreen.continueLatestSaveAux
function MainScreen.continueLatestSaveAux(fromResetLua)
    MC_main.createUI()
    if not MC_main.mods then
        MainScreen._continue(fromResetLua)
    end
end
