--[[
 --
 -- add by vicky
 -- 2014.10.09
 --
 --]]
require("data.data_error_error")

local ShenmiGoldMsgBox =
    class(
    "ShenmiGoldMsgBox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function ShenmiGoldMsgBox:ctor(param)
    local itemData = param.itemData
    local confirmFunc = param.confirmFunc
    local cancelFunc = param.cancelFunc

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBReaderLoad("nbhuodong/shenmi_gold_msgBox.ccbi", proxy, rootnode)
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    local function onClose()
        if cancelFunc ~= nil then
            cancelFunc()
        end
        self:removeFromParent(true)
    end

    rootnode["confirmBtn"]:registerControlEventHandler(
        function(sender)
            if game.player:getGold() < itemData.price then
                show_tip_label(data_error_error[100004].prompt)
            elseif confirmFunc ~= nil then
                confirmFunc()
                onClose()
            end
        end,
        CCControlEventTouchUpInside
    )

    rootnode["cancelBtn"]:registerControlEventHandler(
        function(sender)
            onClose()
        end,
        CCControlEventTouchUpInside
    )

    rootnode["closeBtn"]:registerControlEventHandler(
        function(sender)
            onClose()
        end,
        CCControlEventTouchUpInside
    )

    -- 花费元宝数
    rootnode["cost_num"]:setString(itemData.price)
    rootnode["gold_icon"]:setPositionX(rootnode["cost_num"]:getPositionX() + rootnode["cost_num"]:getContentSize().width + 5)

    -- 兑换物品 名称
    local nameColor = cc.c3b(0, 143, 22)
    if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then
        nameColor = ResMgr.getItemNameColor(itemData.id)
    elseif itemData.iconType == ResMgr.HERO then
        nameColor = ResMgr.getHeroNameColor(itemData.id)
    end

    local nameKey = "name_lbl"
    rootnode[nameKey]:setString(itemData.name)
    rootnode[nameKey]:setColor(nameColor)

    rootnode["content_2"]:setPositionX(rootnode[nameKey]:getPositionX() + rootnode[nameKey]:getContentSize().width + 5)

    -- local nameLbl = newTTFLabelWithShadow({
    --        text = itemData.name,
    --        size = 22,
    --        color = nameColor,
    --        shadowColor = cc.c3b(0,0,0),
    --        font = FONTS_NAME.font_fzcy,
    --        align = cc.TEXT_ALIGNMENT_LEFT
    --        })

    --    nameLbl:setPosition(-nameLbl:getContentSize().width/2, 0)
    --    rootnode["name_lbl"]:removeAllChildren()
    --    rootnode["name_lbl"]:addChild(nameLbl)
end

return ShenmiGoldMsgBox
