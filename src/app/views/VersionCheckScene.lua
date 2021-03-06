--@SuperType luaIde#cc.Scene
local VersionCheckScene =
    class(
    "VersionCheckScene",
    function()
        return display.newScene("VersionCheckScene")
    end
)

function VersionCheckScene:ctor()
    display.loadSpriteFrames("ui/ui_common_button.plist", "ui/ui_common_button.png")
    local bgSprite = display.newSprite("ui/jpg_bg/gamelogo.jpg")
    if (display.sizeInPixels.width / display.sizeInPixels.height) == 0.75 then
        bgSprite:setPosition(display.cx, display.height * 0.55)
        bgSprite:setScale(0.9)
    elseif (display.sizeInPixels.width == 640 and display.sizeInPixels.height == 960) then
        bgSprite:setPosition(display.cx, display.height * 0.55)
    else
        bgSprite:setPosition(display.cx, display.cy)
    end
    self:addChild(bgSprite)

    local btn = ccui.Button:create("com_btn_dark_blue.png", "", "", ccui.TextureResType.plistType)
    btn:setTitleText("登陆")
    btn:setTitleFontName("fonts/FZCuYuan-M03S.ttf")
    btn:setTitleFontSize(30)
    btn:setScale9Enabled(true)
    btn:setPosition(display.cx, 80)
    btn:setContentSize(cc.size(157, 69))
    self:addChild(btn)
    btn:addClickEventListener(
        function()
            -- if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
            --     print("准备进入游戏")
            --     GameStateManager:ChangeState(GAME_STATE.STATE_LOGIN)
            -- end
            print("准备进入游戏")
            GameStateManager:ChangeState(GAME_STATE.STATE_LOGIN)
        end
    )
end

function VersionCheckScene:onEnterTransitionFinish()
end

return VersionCheckScene
