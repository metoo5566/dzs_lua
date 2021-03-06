local ChongzhiBuyMonthCardMsgbox =
    class(
    "ChongzhiBuyMonthCardMsgbox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function ChongzhiBuyMonthCardMsgbox:ctor(param)
    local leftDay = param.leftDay
    local confirmListen = param.confirmListen

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBReaderLoad("ccbi/shop/buyMonthCard_msgBox.ccbi", proxy, rootnode)
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    rootnode["leftDay_lbl"]:setString("剩余天数：" .. tostring(leftDay))

    local function closeFunc()
        self:removeFromParent(true)
    end

    rootnode["closeBtn"]:registerControlEventHandler(
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
end

return ChongzhiBuyMonthCardMsgbox
