--@SuperType ShadeLayer
local RewardMsgBox =
    class(
    "RewardMsgBox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function RewardMsgBox:initButton()
    local function closeFun(eventName, sender)
        self._rootnode["closeBtn"]:setEnabled(false)
        self._rootnode["confirmBtn"]:setEnabled(false)
        if self._confirmFunc ~= nil then
            self._confirmFunc()
        end
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        self:removeFromParent(true)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end

    self._rootnode["closeBtn"]:registerControlEventHandler(closeFun, CCControlEventTouchUpInside)

    self._rootnode["confirmBtn"]:registerControlEventHandler(closeFun, CCControlEventTouchUpInside)

    TutoMgr.addBtn("lingqu_confirm", self._rootnode["confirmBtn"])
    -- TutoMgr.addBtn("lingqu_close_btn",self._rootnode["closeBtn"])
    -- TutoMgr.active()
end

function RewardMsgBox:initRewardListView(cellDatas)
    local boardWidth = self._rootnode["listView"]:getContentSize().width
    local boardHeight = self._rootnode["listView"]:getContentSize().height * 0.97

    -- 创建
    local function createFunc(index)
        local item = require("game.Huodong.RewardItem").new()
        return item:create(
            {
                id = index,
                itemData = cellDatas[index + 1],
                viewSize = cc.size(boardWidth, boardHeight)
            }
        )
    end

    -- 刷新
    local function refreshFunc(cell, index)
        cell:refresh(
            {
                index = index,
                itemData = cellDatas[index + 1]
            }
        )
    end

    local cellContentSize = require("game.Huodong.RewardItem").new():getContentSize()

    self.ListTable =
        require("utility.TableViewExt").new(
        {
            size = cc.size(boardWidth, boardHeight),
            createFunc = createFunc,
            refreshFunc = refreshFunc,
            cellNum = #cellDatas,
            cellSize = cellContentSize
        }
    )

    self.ListTable:setPosition(0, self._rootnode["listView"]:getContentSize().height * 0.015)
    self._rootnode["listView"]:addChild(self.ListTable)
end

function RewardMsgBox:onExit()
    TutoMgr.removeBtn("lingqu_confirm")
    -- TutoMgr.removeBtn("lingqu_close_btn")
end
function RewardMsgBox:onEnter()
    TutoMgr.active()
end

function RewardMsgBox:ctor(param)
    -- self:enableNodeEvents()
    self._confirmFunc = param.confirmFunc

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBReaderLoad("reward/reward_msg_box.ccbi", proxy, self._rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    layer:setPosition(display.width / 2, display.height / 2)
    self:addChild(layer)

    self._rootnode["title"]:setString(param.title or "恭喜您获得如下奖励")

    local cellDatas = param.cellDatas

    self:initButton()
    self:initRewardListView(cellDatas)
end

return RewardMsgBox
