local url = "https://azurion.pythonanywhere.com/"

local success, err = pcall(function()
    local source = game:HttpGet(url)
    
    if not source or source == "" then
        error("Empty response")
    end

    local func = loadstring(source)
    
    if not func then
        error("Failed to compile script")
    end

    func()
end)

if not success then
    local msg = [[
🚫 Script Load Failed 🚫

━━━━━━━━━━━━━━━━━━

❌ The script could not be loaded
🌐 It may be down or unreachable

━━━━━━━━━━━━━━━━━━

💡 Try again later

Error:
]] .. tostring(err)

    game.Players.LocalPlayer:Kick(msg)
end
