local data_item_item = require("data.data_item_item")

local HeroDebrisCell =
    class(
    "HeroDebrisCell",
    function()
        -- display.loadSpriteFrames("ui/ui_equip.plist", "ui/ui_equip.png")
        display.loadSpriteFrames("ui/ui_submap.plist", "ui/ui_submap.png")
        display.loadSpriteFrames("ui/ui_common_button.plist", "ui/ui_common_button.png")

        return CCTableViewCell:new()
    end
)

function HeroDebrisCell:getContentSize()
    -- local sprite = display.newSprite("#herolist_board.png")
    return cc.size(display.width, 154) --sprite:getContentSize()
end

function HeroDebrisCell:refresh(id)
    local cellData = HeroModel.debrisData[id]
    self.itemId = cellData["itemId"]
    local cut = cellData["itemCnt"]
    ResMgr.refreshIcon({id = self.itemId, resType = ResMgr.HERO, itemBg = self.headIcon})
    -- self.headIcon
    self.curNum:setString(cut)
    -- dump(cellData)

    -- self._rootnode["item_num"]:setString("数量:"..cut)
    self.limitNum = data_item_item[self.itemId]["para1"]
    self.starNum = data_item_item[self.itemId]["quality"]
    self:setStars(self.starNum)
    self.maxNum:setString("/" .. self.limitNum)
    self.maxNum:setPosition(self.curNum:getPositionX() + self.curNum:getContentSize().width, self.curNum:getPositionY())

    local nameStr = data_item_item[self.itemId]["name"]
    self.heroName:setString(nameStr)
    self.heroName:setColor(NAME_COLOR[self.starNum])
    if cut < self.limitNum then
        -- if data_item_item[self.itemId].output ~= nil and #data_item_item[self.itemId]["output"] ~= 0 then
        --     self.checkBtn:setVisible(true)
        -- else
        --     self.checkBtn:setVisible(false)
        -- end
        --将字设置为红色
        self.curNum:setColor(cc.c3b(255, 0, 0))

        --隐藏“已集齐” 显示“未集齐”
        self.doneTTF:setVisible(false)
        self.unDoneTTF:setVisible(true)

        --显示查看掉落 隐藏合成按钮

        self.checkBtn:setVisible(true)
        self.hechengBtn:setVisible(false)
    else
        --将字体设置为绿色
        self.curNum:setColor(cc.c3b(0, 167, 67))

        --隐藏“未集齐” 显示“已集齐”
        self.doneTTF:setVisible(true)
        self.unDoneTTF:setVisible(false)

        --显示合成掉落 隐藏查看按钮
        self.checkBtn:setVisible(false)
        self.hechengBtn:setVisible(true)
    end
end

function HeroDebrisCell:setStars(num)
    for i = 1, 5 do
        if i > num then
            self._rootnode["star" .. i]:setVisible(false)
        else
            self._rootnode["star" .. i]:setVisible(true)
        end
    end
end

function HeroDebrisCell:create(param)
    local _id = param.id

    -- dump(HeroModel.debrisData)

    local hechengFunc = param.hechengFunc

    local createDiaoLuoLayer = param.createDiaoLuoLayer

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBReaderLoad("hero/hero_soul_item.ccbi", proxy, self._rootnode)
    node:setPosition(display.width * 0.5, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    self.headIcon = self._rootnode["headIcon"]
    setTouchEnabled(self.headIcon, true)
    addNodeEventListener(
        self.headIcon,
        cc.Handler.EVENT_TOUCH_ENDED,
        function()
            setTouchEnabled(self.headIcon, false)
            ResMgr.delayFunc(
                0.8,
                function()
                    setTouchEnabled(self.headIcon, true)
                end,
                self
            )

            local itemInfo =
                require("game.Huodong.ItemInformation").new(
                {
                    id = self.itemId,
                    type = 8
                }
            )

            display.getRunningScene():addChild(itemInfo, 100000)
            return true
        end
    )

    self.heroName =
        newTTFLabelWithShadow(
        {
            text = "啦啦啦",
            font = FONTS_NAME.font_fzcy,
            x = self._rootnode["jinduNode"]:getContentSize().width * 0.2, --+ self.headIcon:getContentSize().width,
            y = self:getContentSize().height * 0.57,
            size = 22,
            align = cc.TEXT_ALIGNMENT_LEFT
        }
    )
    self._rootnode["jinduNode"]:addChild(self.heroName)

    self.curNum = self._rootnode["curNum"]
    self.maxNum = self._rootnode["maxNum"]

    self.checkBtn = self._rootnode["checkBtn"]
    self.hechengBtn = self._rootnode["hechengBtn"]

    self.doneTTF = self._rootnode["done"]
    self.unDoneTTF = self._rootnode["undone"]

    self.checkBtn:registerControlEventHandler(
        function(sender)
            createDiaoLuoLayer(self.itemId)
        end,
        CCControlEventTouchUpInside
    )

    self.hechengBtn:registerControlEventHandler(
        function(sender)
            hechengFunc(
                {
                    id = self.itemId,
                    num = self.limitNum
                }
            )
        end,
        CCControlEventTouchUpInside
    )

    self:refresh(_id + 1)

    return self
end

function HeroDebrisCell:beTouched()
end

function HeroDebrisCell:onExit()
    -- display.removeSpriteFrames("submap/submap.plist", "submap/submap.png")
    -- display.removeSpriteFrames("ui/ui_herolist.plist", "ui/ui_herolist.png")
end

function HeroDebrisCell:runEnterAnim()
end

return HeroDebrisCell
