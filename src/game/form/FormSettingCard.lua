--@SuperType luaIde#cc.Node
local FormSettingCard =
    class(
    "FormSettingCard",
    function()
        return display.newNode()
    end
)
--@SuperType CardObj
local TouchCard =
    class(
    "TouchCard",
    function(param)
        return require("game.Object.CardObj").new(param)
    end
)

function TouchCard:ctor(param)
    self:setTag(123)
end

function FormSettingCard:ctor(param)
    local _data = param.data
    local _touchBegan = param.touchBegan
    local _touchMove = param.touchMove
    local _touchEnd = param.touchEnd
    local _index = param.index

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBReaderLoad("formation/formation_setting_card.ccbi", proxy, rootnode)
    self:addChild(node, 1)

    local _bOpen = true
    local _bg = rootnode["imageSprite"]
    local _sz = _bg:getContentSize()
    local _pos = cc.p(_sz.width / 2, _sz.height / 2)

    rootnode["lvNum_node"]:setVisible(false)

    local nameLabel =
        newTTFLabelWithShadow(
        {
            text = "",
            font = FONTS_NAME.font_fzcy,
            size = 20
        }
    )
    rootnode["nameNode"]:addChild(nameLabel)
    nameLabel:setPosition(nameLabel:getContentSize().width / 2, 0)

    local image

    --[[
    @desc: 
   
    time:2020-06-01 19:07:01
        --@touch: luaIde#cc.Touch
    	--@event: luaIde#cc.EventTouch
    @return:
]]
    local function touchBegan(touch, event)
        _touchBegan(
            {
                cardnode = event:getCurrentTarget():getParent():getParent():getParent(),
                image = event:getCurrentTarget(),
                event = touch
            }
        )
        return true
    end

    local function touchMoved(touch, event)
        _touchMove(
            {
                cardnode = event:getCurrentTarget():getParent():getParent():getParent(),
                image = event:getCurrentTarget(),
                event = touch
            }
        )
    end

    local function touchEnded(touch, event)
        _touchEnd(
            {
                cardnode = event:getCurrentTarget():getParent():getParent():getParent(),
                image = event:getCurrentTarget(),
                event = touch
            }
        )
    end

    self.setTouchEnabled = function(_, b)
        _bg:setTouchEnabled(b)
    end

    self.equipCard = function(_, cardData)
        if _bOpen and type(cardData) == "table" then
            rootnode["lvLabel"]:setString(tostring(cardData.level))
            rootnode["lvNum_node"]:setVisible(true)
            --@RefType luaIde#cc.Node
            local card =
                TouchCard.new(
                {
                    id = cardData.resId,
                    cls = cardData.cls,
                    lv = cardData.level,
                    star = cardData.star
                    --star = 1
                }
            )
            card:setPosition(_pos)
            _bg:addChild(card)
            setTouchEnabled(card, true)
            addNodeEventListener(
                card,
                cc.Handler.EVENT_TOUCH_BEGAN,
                function(touch, event)
                    return touchBegan(touch, event)
                end
            )
            addNodeEventListener(
                card,
                cc.Handler.EVENT_TOUCH_MOVED,
                function(touch, event)
                    touchMoved(touch, event)
                end
            )
            addNodeEventListener(
                card,
                cc.Handler.EVENT_TOUCH_ENDED,
                function(touch, event)
                    touchEnded(touch, event)
                end
            )

            if cardData.resId == 1 or cardData.resId == 2 then
                nameLabel:setString(game.player:getPlayerName())
            else
                nameLabel:setString(card:getName())
            end

            nameLabel:setTextColor(NAME_COLOR[card:getStar(card:getStar())])
            if card:getCls() > 0 then
                rootnode["clsLabel"]:setString(string.format("+%d", card:getCls()))
                rootnode["clsLabel"]:setPosition(nameLabel:getContentSize().width / 2, 0)
            else
                rootnode["clsLabel"]:setString("")
            end
        end
    end

    self.getTargetPos = function()
        return _pos
    end

    self.isInCard = function(_, x, y)
        if (cc.rectContainsPoint(cc.rect(0, 0, _sz.width, _sz.height), _bg:convertToNodeSpace(cc.p(x, y)))) then
            return true
        else
            return false
        end
    end

    self.getHeroImage = function()
        return _bg:getChildByTag(123)
    end

    self.addHeroImage = function(_, card)
        if card then
            _bg:addChild(card)
            rootnode["lvLabel"]:setString(tostring(card:getLv()))
            rootnode["lvNum_node"]:setVisible(true)

            if card:getResId() == 1 or card:getResId() == 2 then
                nameLabel:setString(game.player:getPlayerName())
            else
                nameLabel:setString(card:getName())
            end
            nameLabel:setTextColor(NAME_COLOR[card:getStar()])

            if card:getCls() > 0 then
                rootnode["clsLabel"]:setString(string.format("+%d", card:getCls()))
                rootnode["clsLabel"]:setPosition(nameLabel:getContentSize().width / 2, 0)
            else
                rootnode["clsLabel"]:setString("")
            end
        else
            rootnode["lvLabel"]:setString("0")
            rootnode["lvNum_node"]:setVisible(false)
            nameLabel:setString("")
            rootnode["clsLabel"]:setString("")
        end
    end

    self.empty = function(_)
        if _bg:getChildByTag(123) then
            return false
        end
        return true
    end

    self.getIndex = function(_)
        return _index
    end

    self.isOpen = function(_)
        return _bOpen
    end

    self:equipCard(_data)
    self._bg = _bg
end

function FormSettingCard:switchWithCard(touchCard, x, y)
    if self:isOpen() then
        local cardA = self:getHeroImage()
        local cardB = touchCard:getHeroImage()

        if cardA == cardB then
            return false
        end

        if cardA then
            cardA:retain()
            cardA:removeFromParent(false)
        end
        cardB:retain()
        cardB:removeFromParent(false)
        cardB:setPosition(self._bg:convertToNodeSpace(cc.p(x, y)))

        self:addHeroImage(cardB)
        touchCard:addHeroImage(cardA)

        cardB:release()

        if cardA then
            cardA:release()
        end

        return true
    else
        show_tip_label(string.format("当前位置%d级开启", self:getOpenLv()))
        return false
    end
end

return FormSettingCard
