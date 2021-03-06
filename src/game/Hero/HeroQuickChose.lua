local HeroQuickChose =
    class(
    "HeroQuickChose",
    function(param)
        return require("utility.ShadeLayer").new()
    end
)

local function btn_effect(sender, callback)
    sender:runAction(
        transition.sequence(
            {
                cc.ScaleTo:create(0.08, 0.8),
                cc.ScaleTo:create(0.1, 1.01),
                cc.ScaleTo:create(0.01, 1),
                cc.CallFunc:create(
                    function()
                        if callback then
                            callback()
                        end
                    end
                )
            }
        )
    )
end

function HeroQuickChose:removeFunc()
    if self.removeListener ~= nil then
        self.removeListener()
    end
end

function HeroQuickChose:ctor(callback, removeListener)
    self.removeListener = removeListener
    local baseNode = display.newNode()
    self:addChild(baseNode)
    local rootProxy = CCBProxy:create()
    self._rootnode = {}

    local rootnode = CCBReaderLoad("hero/hero_quick_select", rootProxy, self._rootnode)
    baseNode:setPosition(display.cx, display.cy)
    baseNode:addChild(rootnode, 1)

    local selected = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false
    }

    local function onSelecteAllBtn()
        for i = 1, 4 do
            selected[i] = true
            self._rootnode["selectedFlag_" .. tostring(i)]:setVisible(true)
        end
    end
    self._rootnode["titleLabel"]:setString("选择星级")
    local function onConfirmBtn()
        if callback then
            callback(selected)
        end
        self:removeFunc()
        self:removeSelf()
    end

    local function onSelectedStar(tag)
        print("ttt tage" .. tag)
        if (selected[tag]) then
            selected[tag] = false
        else
            selected[tag] = true
        end

        self._rootnode["selectedFlag_" .. tostring(tag)]:setVisible(selected[tag])
    end

    self._rootnode["closeBtn"]:registerControlEventHandler(
        function(button, event)
            btn_effect(
                button,
                function()
                    self:removeFunc()
                    self:removeSelf()
                end
            )
        end,
        CCControlEventTouchDown
    )

    self._rootnode["chooseAllBtn"]:registerControlEventHandler(
        function(button, event)
            btn_effect(button, onSelecteAllBtn)
        end,
        CCControlEventTouchDown
    )

    self._rootnode["confirmBtn"]:registerControlEventHandler(
        function(button, event)
            btn_effect(button, onConfirmBtn)
        end,
        CCControlEventTouchDown
    )

    for i = 1, 4 do
        self._rootnode["chooseStarBtn_" .. tostring(i)]:registerScriptTapHandler(onSelectedStar)
    end
end

return HeroQuickChose
