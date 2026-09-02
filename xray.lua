local geoScanner = peripheral.find("geo_scanner")
local glasses = smartglasses

if not geoScanner then
    print("Error: Geo Scanner not found.")
    return
end

local overlay = glasses.modules['advancedperipherals:overlay']
if not overlay then
    print("Error: Overlay module not equipped on the Smart Glasses.")
    return
end

local oreColors = {
    ["coal"] = 0x2A2A2A,
    ["iron"] = 0xD8AF93,
    ["gold"] = 0xFCEE4B,
    ["copper"] = 0xC15A36,
    ["redstone"] = 0xFF0000,
    ["lapis"] = 0x345EC3,
    ["diamond"] = 0x5DECF5,
    ["emerald"] = 0x17DD62,
    ["debris"] = 0x5D4037,
    ["netherite"] = 0x5D4037
}

local function getOreColor(blockName)
    local lowerName = string.lower(blockName)
    for key, color in pairs(oreColors) do
        if string.find(lowerName, key) then
            return color
        end
    end
    return 0xFFFFFF
end

local scanRadius = 8

local function clearOverlay()
    overlay.clear()
    if not overlay.isAutoUpdating() then
        overlay.update()
    end
    print("Overlay cleared.")
end

local function scanAndRender()
    print("Scanning blocks in radius " .. scanRadius .. "...")
    local blocks, err = geoScanner.scanBlocks(scanRadius)

    if not blocks then
        print("Scan failed: " .. tostring(err))
        return
    end

    overlay.clear()
    local oreCount = 0

    for _, block in ipairs(blocks) do
        if string.find(block.name, "ore") or string.find(block.name, "debris") then
            oreCount = oreCount + 1

            overlay.createBox({
                x = block.x,
                y = block.y,
                z = block.z,
                sizeX = 1,
                sizeY = 1,
                sizeZ = 1,
                color = getOreColor(block.name),
                opacity = 0.6,
                relativePosition = true,
                depthTest = false,
                culling = true
            })
        end
    end

    if not overlay.isAutoUpdating() then
        overlay.update()
    end
    print("Highlighted " .. oreCount .. " colored ores on your HUD.")
end

scanAndRender()

while true do
    local event, keyBind, keyPressDuration = os.pullEvent("glasses_key_pressed")
    local keyStr = string.lower(keyBind)

    if keyStr == "key.mouse.5" then
        scanAndRender()
    else
        print("Unrecognized keybind pressed: " .. keyBind)
    end
end
