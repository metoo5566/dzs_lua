--[[
 --
 -- add by vicky
 -- 2014.11.28 
 --
 --]]
local DengjiTouziBuyMsgbox =
    class(
    "DengjiTouziBuyMsgbox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function DengjiTouziBuyMsgbox:ctor(param)
    local needGold = param.needGold
    local cancelListen = param.cancelListen
    local confirmListen = param.confirmListen

    local rootnode = {}
    local proxy = CCBProxy:create()
    local node = CCBReaderLoad("nbhuodong/dengjiTouzi_buyMsgbox.ccbi", proxy, rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    rootnode["needGold_lbl"]:setString(tostring(needGold) .. "元宝")

    local function closeFunc()
        if cancelListen ~= nil then
            cancelListen()
        end
        self:removeFromParent(true)
    end

    rootnode["closeBtn"]:registerControlEventHandler(
        function(sender)
            closeFunc()
        end,
        CCControlEventTouchUpInside
    )

    rootnode["cancelBtn"]:registerControlEventHandler(
        function(sender)
            closeFunc()
        end,
        CCControlEventTouchUpInside
    )

    rootnode["confirmBtn"]:registerControlEventHandler(
        function(sender)
            if confirmListen ~= nil then
                confirmListen()
            end
            self:removeFromParent(true)
        end,
        CCControlEventTouchUpInside
    )
end

return DengjiTouziBuyMsgbox
