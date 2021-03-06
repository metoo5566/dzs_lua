local data_item_item = require("data.data_item_item")

--@SuperType luaIde#cc.TableViewCell
local Item =
    class(
    "item",
    function()
        return CCTableViewCell:new()
    end
)

function Item:getContentSize()
    return cc.size(105, 95)
end

function Item:create(param)
    local _viewSize = param.viewSize
    local _itemData = param.itemData

    self.sprite = display.newSprite("ui/ui_empty.png")
    self.sprite:setPosition(self:getContentSize().width / 2, _viewSize.height * 0.57)
    self:addChild(self.sprite)

    self.nameLabel =
        newTTFLabelWithOutline(
        {
            text = "",
            font = FONTS_NAME.font_fzcy,
            size = 20,
            align = cc.TEXT_ALIGNMENT_CENTER
        }
    )
    self.nameLabel:setPosition(self:getContentSize().width / 2, _viewSize.height * 0.13)
    self:addChild(self.nameLabel)

    self.numLabel =
        newTTFLabelWithOutline(
        {
            text = "",
            font = FONTS_NAME.font_fzcy,
            size = 20,
            color = FONT_COLOR.GREEN,
            align = cc.TEXT_ALIGNMENT_RIGHT
        }
    )
    --    self.numLabel:setPosition(cc.p(self:getContentSize().width - self.numLabel:getContentSize().width - 10, self:getContentSize().height * 0.5))
    self:addChild(self.numLabel)
    self:refresh(param)
    return self
end

function Item:refresh(param)
    local _itemData = param.itemData

    ResMgr.refreshIcon(
        {
            itemBg = self.sprite,
            id = _itemData.id,
            resType = ResMgr.getResType(_itemData.t)
        }
    )

    self.nameLabel:setString(data_item_item[_itemData.id].name)
    self.nameLabel:setColor(NAME_COLOR[data_item_item[_itemData.id].quality])
    self.numLabel:setString(tostring(_itemData.num))
    self.numLabel:setPosition(cc.p(self:getContentSize().width - self.numLabel:getContentSize().width / 2 - 10, self:getContentSize().height * 0.5))
end

--@SuperType BaseScene
local SplitStoveScene =
    class(
    "SplitStoveScene",
    function()
        return require("game.BaseScene").new(
            {
                contentFile = "lianhualu/ccb_lianhualu.ccbi",
                subTopFile = "lianhualu/lianhualu_tab_view.ccbi",
                bgImage = "ui/jpg_bg/lianhualu_bg2.jpg",
                scaleMode = 1
            }
        )
    end
)

local BTN_NAME_MAPPING = {
    "#lianhualu_add_xk_btn.png",
    "#lianhualu_add_zb_btn.png",
    "#lianhualu_add_wx_btn.png",
    "#lianhualu_add_sz_btn.png"
}

local VIEW_TYPE = {
    REFINE = 1,
    REBORN = 2
}

function SplitStoveScene:ctor()
    ResMgr.removeBefLayer()
    game.runningScene = self
    display.loadSpriteFrames("icon/icon_equip.plist", "icon/icon_equip.png")

    if game.player:getAppOpenData().lianhuashenmi == APPOPEN_STATE.close then
        self._rootnode["secretShopBtn"]:setVisible(false)
    else
        self._rootnode["secretShopBtn"]:setVisible(true)
    end

    -- fire循环特效
    local xunhuanEffect =
        ResMgr.createArma(
        {
            resType = ResMgr.UI_EFFECT,
            armaName = "lianhualuhuoyan",
            isRetain = true
        }
    )
    xunhuanEffect:setPosition(self._rootnode["firePos"]:getContentSize().width / 2, xunhuanEffect:getContentSize().height / 7)
    self._rootnode["firePos"]:addChild(xunhuanEffect, -10)

    -- 清除按钮状态
    local function resetQuickBtn(tag)
        for i = 1, 4 do
            if i ~= tag then
                resetctrbtnimage(self._rootnode[string.format("quickAddBtn_%d", i)], BTN_NAME_MAPPING[i])
                self._rootnode[string.format("quickAddBtn_%d", i)].index = nil
            else
                resetctrbtnimage(self._rootnode[string.format("quickAddBtn_%d", i)], "#lianhualu_huanyipi.png")
            end
        end
    end

    self._selectedType = LIAN_HUA_TYEP.HERO --默认为武将
    self._selected = {}

    local function initHero()
        for _, v in pairs(VIEW_TYPE) do
            local n = #self._itemsData[v][LIAN_HUA_TYEP.HERO]
            for i = 1, n do
                table.remove(self._itemsData[v][LIAN_HUA_TYEP.HERO], 1)
            end
        end
        local heros = self._list[LIAN_HUA_TYEP.HERO]
        for k, v in ipairs(heros) do
            v.name = ResMgr.getCardData(v.resId).name
            if v.refining == 1 then
                table.insert(self._itemsData[VIEW_TYPE.REFINE][LIAN_HUA_TYEP.HERO], k)
            end

            if v.reborn == 1 then
                table.insert(self._itemsData[VIEW_TYPE.REBORN][LIAN_HUA_TYEP.HERO], k)
            end
        end
    end

    local function initEquip()
        for _, v in pairs(VIEW_TYPE) do
            local n = #self._itemsData[v][LIAN_HUA_TYEP.EQUIP]
            for i = 1, n do
                table.remove(self._itemsData[v][LIAN_HUA_TYEP.EQUIP], 1)
            end
        end

        local equips = self._list[LIAN_HUA_TYEP.EQUIP]
        for k, v in ipairs(equips) do
            v.name = data_item_item[v.resId].name

            if v.refining == 1 then
                table.insert(self._itemsData[VIEW_TYPE.REFINE][LIAN_HUA_TYEP.EQUIP], k)
            end

            if v.reborn == 1 then
                table.insert(self._itemsData[VIEW_TYPE.REBORN][LIAN_HUA_TYEP.EQUIP], k)
            end
        end
    end

    --  单个添加
    local function onAddBtn(tag)
        --        if self._viewType == VIEW_TYPE.REFINE then
        --            if self._itemsData then
        setTouchEnabled(self._rootnode["btn" .. tostring(tag)], false)
        initHero()
        initEquip()
        push_scene(
            require("game.SplitStove.ItemChooseScene").new(
                {
                    list = self._list,
                    items = self._itemsData[self._viewType],
                    splitType = self._selectedType,
                    viewType = self._viewType,
                    selected = self._selected,
                    closeListener = function(splitType, data)
                        if data ~= self._selected then
                            resetQuickBtn(0)
                        end
                        self:refreshItem(splitType, data)
                        setTouchEnabled(self._rootnode["btn" .. tostring(tag)], true)
                    end
                }
            )
        )
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        --            end
        --        elseif self._viewType == VIEW_TYPE.REBORN then
        --
        --        end
    end

    --  快速添加
    local function onQuickAddBtn(sender)
        local t
        if sender:getTag() == LIAN_HUA_TYEP.HERO then
            t = LIAN_HUA_TYEP.HERO
        elseif sender:getTag() == LIAN_HUA_TYEP.EQUIP then
            t = LIAN_HUA_TYEP.EQUIP
        else
            show_tip_label(data_error_error[2800001].prompt)
            return
        end
        local data = {}
        local idx = sender.index or 0
        local len
        if #self._itemsData[self._viewType][t] >= 4 then
            len = 4
        else
            len = #self._itemsData[self._viewType][t]
        end
        for i = 1, len do
            idx = idx + 1
            if idx > #self._itemsData[self._viewType][t] then
                idx = 1
                break
            end
            if self._itemsData[self._viewType][t][idx] then
                --                data[idx] = true
                data[self._itemsData[self._viewType][t][idx]] = true
                sender.index = idx
                if idx == #self._itemsData[self._viewType][t] then
                    sender.index = 0
                    break
                end
            else
                break
            end
        end

        if (len == 0) then
            local str = "您没有符合炼化条件的侠客"
            if (t == LIAN_HUA_TYEP.EQUIP) then
                str = "您没有符合炼化条件的装备"
            end
            show_tip_label(str)
        else
            resetQuickBtn(sender:getTag())
        end
        self:refreshItem(t, data)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end

    --    点击选项卡
    local function onTabBtn(tag)
        if self._animIsRunning then
            return
        else
            self:refreshItem()
            if tag == 1 then
                self:onRefineView()
            elseif tag == 2 then
                self:onRebornView()
            end
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end

    local function onDescBtn()
        local layer = require("game.SplitStove.SplitDescLayer").new(self._viewType)
        self:addChild(layer, 100)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end

    local function onReborn()
        --        dump(self._selected)
        local id
        for k, v in pairs(self._selected) do
            if v then
                id = k
            end
        end
        if id == nil then
            show_tip_label("请选择重生物品")
            return
        end

        if checknumber(self._rootnode["costGoldLabel"]:getString()) > game.player:getGold() then
            show_tip_label("金币不足")
            return
        end

        dump(self._list[self._selectedType][id])
        self._rootnode["btn0"]:setVisible(false)
        self._rootnode["rebornBtn"]:setEnabled(false)
        self._rootnode["descBtn"]:setEnabled(false)

        self._animIsRunning = true
        RequestHelper.split.reborn(
            {
                callback = function(data)
                    dump(data)
                    if data["3"] then
                        self:bagFull(data["3"])

                        self._rootnode["btn0"]:setVisible(true)
                        self._rootnode["rebornBtn"]:setEnabled(true)
                        self._rootnode["descBtn"]:setEnabled(true)
                    else
                        self:updataData(id, data["2"][1])
                        game.player:setGold(data["4"])
                        self:clearIcon()
                        local effect =
                            ResMgr.createArma(
                            {
                                resType = ResMgr.UI_EFFECT,
                                armaName = "lianhuatexiao",
                                isRetain = false,
                                finishFunc = function()
                                    self:updateResult(data["1"])
                                    self._rootnode["btn0"]:setVisible(true)
                                    self._rootnode["rebornBtn"]:setEnabled(true)
                                    self._rootnode["descBtn"]:setEnabled(true)
                                    self._selectedType = LIAN_HUA_TYEP.HERO
                                    self._selected = {}
                                    self._animIsRunning = false
                                end
                            }
                        )
                        effect:setPosition(display.width / 2, display.height / 2)
                        self:addChild(effect, 1000)
                    end
                end,
                t = tostring(self._selectedType),
                id = self._list[self._selectedType][id].id
            }
        )
    end

    for i = 0, 4 do
        local key = "btn" .. tostring(i)
        -- self._rootnode[key]:addNodeEventListener(cc.NODE_TOUCH_EVENT, c_func(onAddBtn, i))
        addNodeEventListener(
            self._rootnode[key],
            cc.Handler.EVENT_TOUCH_ENDED,
            function()
                onAddBtn(i)
            end
        )
        setTouchEnabled(self._rootnode[key], true)
    end

    self._rootnode["lianhuaBtn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            local bShow = false
            for k, v in pairs(self._selected) do
                --            dump(self._list[self._selectedType][k])
                if self._list[self._selectedType][k].star == 5 then
                    bShow = true
                end
            end

            if bShow then
                local str
                if self._selectedType == LIAN_HUA_TYEP.HERO then
                    str = "您要炼化的是5星侠客，可用于同名侠客的进阶，\n确定要炼化吗？"
                elseif self._selectedType == LIAN_HUA_TYEP.EQUIP then
                    str = "您要炼化的是5星装备，确定要炼化吗？"
                end

                local layer =
                    require("game.SplitStove.SplitTip").new(
                    {
                        listener = function()
                            self:onLianHua(
                                function()
                                    initHero()
                                    initEquip()
                                end
                            )
                        end,
                        str = str
                    }
                )
                self:addChild(layer, 10)
            else
                self:onLianHua(
                    function()
                        initHero()
                        initEquip()
                    end
                )
            end
        end,
        CCControlEventTouchDown
    )

    for i = 1, 4 do
        self._rootnode["quickAddBtn_" .. tostring(i)]:registerControlEventHandler(onQuickAddBtn, CCControlEventTouchDown)
    end

    --    onTabBtn(1)
    self:refreshItem()
    self:onRefineView()

    --    self._rootnode["btn0"]:addNodeEventListener(cc.NODE_TOUCH_EVENT, onAddBtn)
    self._rootnode["rebornBtn"]:registerControlEventHandler(onReborn, CCControlEventTouchDown)
    self._rootnode["tab1"]:registerScriptTapHandler(onTabBtn)
    self._rootnode["tab2"]:registerScriptTapHandler(onTabBtn)
    self._rootnode["descBtn"]:registerControlEventHandler(onDescBtn, CCControlEventTouchDown)
    self._rootnode["secretShopBtn"]:registerControlEventHandler(handler(self, SplitStoveScene.onSecretShopBtn), CCControlEventTouchDown)

    self._itemsData = {
        [VIEW_TYPE.REFINE] = {
            [LIAN_HUA_TYEP.HERO] = {},
            [LIAN_HUA_TYEP.EQUIP] = {}
        },
        [VIEW_TYPE.REBORN] = {
            [LIAN_HUA_TYEP.HERO] = {},
            [LIAN_HUA_TYEP.EQUIP] = {}
        }
    }

    local function sort(l, r)
        if l.star ~= r.star then
            return l.star < r.star
        else
            if l.cls == 0 and r.cls > 0 then
                return true
            elseif l.cls > 0 and r.cls > 0 then
                if l.cls == r.cls then
                    return l.level < r.level
                else
                    return l.cls < r.cls
                end
            elseif l.cls == 0 and r.cls == 0 then
                return l.level + l.resId < r.level + r.resId
            end
        end
    end

    RequestHelper.split.status(
        {
            callback = function(data)
                table.sort(data[1], sort)

                self._list = {
                    [LIAN_HUA_TYEP.HERO] = data[1],
                    [LIAN_HUA_TYEP.EQUIP] = data[2]
                }
                initHero()
                initEquip()
            end
        }
    )
    self:enableNodeEvents()
end

function SplitStoveScene:bagFull(info)
    local layer =
        require("utility.LackBagSpaceLayer").new(
        {
            bagObj = info
        }
    )
    self:addChild(layer, 10)
end

function SplitStoveScene:refreshItem(selectedType, data)
    self._selectedType = selectedType or LIAN_HUA_TYEP.HERO
    self._selected = data or {}
    self._rootnode["costGoldLabel"]:setString("0")
    --显示要分解的图标
    local items = {}
    local function showSplitIcon()
        local i
        if self._viewType == VIEW_TYPE.REFINE then
            i = 1
        else
            i = 0
        end

        for k, v in pairs(self._selected) do
            local index = "icon" .. tostring(i) .. "Sprite"
            self._rootnode[index]:setVisible(false)
            local icon

            if self._selectedType == LIAN_HUA_TYEP.HERO then
                icon =
                    ResMgr.getIconSprite(
                    {
                        --                    id = self._list[LIAN_HUA_TYEP.HERO][self._itemsData[self._viewType][LIAN_HUA_TYEP.HERO][k]].resId,
                        id = self._list[LIAN_HUA_TYEP.HERO][k].resId,
                        resType = ResMgr.HERO
                    }
                )
            elseif self._selectedType == LIAN_HUA_TYEP.EQUIP then
                icon =
                    ResMgr.getIconSprite(
                    {
                        --                    id = self._list[LIAN_HUA_TYEP.EQUIP][self._itemsData[self._viewType][LIAN_HUA_TYEP.EQUIP][k]].resId,
                        id = self._list[LIAN_HUA_TYEP.EQUIP][k].resId,
                        resType = ResMgr.EQUIP
                    }
                )
            end

            if icon then
                self._rootnode["iconPos_" .. tostring(i)]:addChild(icon)
                --                local resid = self._list[self._selectedType][self._itemsData[self._viewType][self._selectedType][k]].resId
                local resid = self._list[self._selectedType][k].resId
                local iconName =
                    newTTFLabelWithShadow(
                    {
                        text = "",
                        font = FONTS_NAME.font_fzcy,
                        size = 20
                    }
                )
                local name = ""
                if self._selectedType == LIAN_HUA_TYEP.HERO then
                    local card = ResMgr.getCardData(resid)
                    name = card.name
                    iconName:setColor(NAME_COLOR[card.star[1]])
                elseif self._selectedType == LIAN_HUA_TYEP.EQUIP then
                    name = data_item_item[resid].name
                    iconName:setColor(NAME_COLOR[data_item_item[resid].quality])
                end

                iconName:setString(name)
                iconName:setPosition(icon:getContentSize().width / 2, -iconName:getContentSize().height * 0.45)
                icon:addChild(iconName)
            end

            i = i + 1

            local rtn
            if self._viewType == VIEW_TYPE.REFINE then
                rtn = "rtn"
            else
                rtn = "rtnReborn"
            end

            --            dump(self._list[self._selectedType][k][rtn])
            self._rootnode["costGoldLabel"]:setString(tostring(self._list[self._selectedType][k].cost))

            --            for kk, vv in ipairs(self._list[self._selectedType][self._itemsData[self._viewType][self._selectedType][k]][rtn]) do
            for kk, vv in ipairs(self._list[self._selectedType][k][rtn]) do
                if items[vv.id] then
                    items[vv.id] = {
                        n = items[vv.id].n + vv.num,
                        t = vv.type
                    }
                else
                    items[vv.id] = {
                        n = vv.num,
                        t = vv.type
                    }
                end
            end
        end
    end
    --
    --显示分解结果的图标
    local function showResultIcon()
        local _tempData = {}
        for k, v in pairs(items) do
            table.insert(
                _tempData,
                {
                    id = k,
                    num = v.n,
                    t = v.t
                }
            )
        end

        table.sort(
            _tempData,
            function(l, r)
                return l.t < r.t
            end
        )

        local tableView =
            require("utility.TableViewExt").new(
            {
                size = self._rootnode["splitItemsBg"]:getContentSize(),
                direction = kCCScrollViewDirectionHorizontal,
                createFunc = function(idx)
                    idx = idx + 1
                    local item = Item.new()
                    return item:create(
                        {
                            itemData = _tempData[idx],
                            viewSize = self._rootnode["splitItemsBg"]:getContentSize(),
                            idx = idx
                        }
                    )
                end,
                refreshFunc = function(cell, idx)
                    idx = idx + 1
                    cell:refresh(
                        {
                            itemData = _tempData[idx],
                            idx = idx
                        }
                    )
                end,
                cellNum = #_tempData,
                cellSize = cc.size(105, 95)
            }
        )
        self._rootnode["splitItemsBg"]:addChild(tableView)
    end

    self:clearIcon()
    showSplitIcon()
    showResultIcon()
end

function SplitStoveScene:updataData(index, data)
    if self._list[self._selectedType][index] then
        for k, v in pairs(self._list[self._selectedType][index]) do
            self._list[self._selectedType][index][k] = data[k]
        end
    end
end

function SplitStoveScene:removeData(ids)
    for _, v in ipairs(ids) do
        for k, vv in ipairs(self._list[self._selectedType]) do
            if vv.id == v then
                table.remove(self._list[self._selectedType], k)
                break
            end
        end
    end
end

function SplitStoveScene:setIconVisible(bVisible)
    for i = 1, 4 do
        local key = "btn" .. tostring(i)
        self._rootnode[key]:setVisible(bVisible)
    end
end

--  清除上次图标
function SplitStoveScene:clearIcon()
    self._rootnode["costGoldLabel"]:setString("0")

    for i = 0, 4 do
        self._rootnode["icon" .. tostring(i) .. "Sprite"]:setVisible(true)
        self._rootnode["iconPos_" .. tostring(i)]:removeAllChildren(true)
    end
    self._rootnode["splitItemsBg"]:removeAllChildren(true)
end

function SplitStoveScene:updateResult(data)
    local itemData = {}
    for k, v in ipairs(data) do
        local itemInfo = data_item_item[v.id]
        local iconType = ResMgr.getResType(v.type) or ResMgr.ITEM
        table.insert(
            itemData,
            {
                id = v.id,
                type = itemInfo.type,
                name = itemInfo.name,
                describe = itemInfo.describe,
                iconType = iconType,
                num = v.num or 0,
                hideCorner = true
            }
        )
        if 2 == v.id then
            game.player:addSilver(v.num)
        end
    end

    local title = "恭喜您获得如下奖励"
    local msgBox =
        require("game.Huodong.RewardMsgBox").new(
        {
            title = title,
            cellDatas = itemData
        }
    )
    self:addChild(msgBox, 10)

    PostNotice(NoticeKey.CommonUpdate_Label_Silver)
    PostNotice(NoticeKey.CommonUpdate_Label_Gold)
end

function SplitStoveScene:onLianHua(callback)
    local ids = {}
    for k, v in pairs(self._selected) do
        table.insert(ids, self._list[self._selectedType][k].id)
    end

    if 0 == #ids then
        show_tip_label("请选择要炼化的物品")
    else
        self:setIconVisible(false)

        self._rootnode["lianhuaBtn"]:setEnabled(false)
        self._rootnode["quickAddBtn_1"]:setEnabled(false)
        self._rootnode["quickAddBtn_2"]:setEnabled(false)
        self._rootnode["descBtn"]:setEnabled(false)
        self._animIsRunning = true

        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_lianhualu))
        RequestHelper.split.refine(
            {
                callback = function(data)
                    self:removeData(ids)
                    self:clearIcon()

                    local effect =
                        ResMgr.createArma(
                        {
                            resType = ResMgr.UI_EFFECT,
                            armaName = "lianhuatexiao",
                            isRetain = false,
                            finishFunc = function()
                                dump(data)
                                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_duobaohecheng))
                                self:updateResult(data[1])
                                self:setIconVisible(true)
                                self._rootnode["lianhuaBtn"]:setEnabled(true)
                                self._rootnode["quickAddBtn_1"]:setEnabled(true)
                                self._rootnode["quickAddBtn_2"]:setEnabled(true)
                                self._rootnode["descBtn"]:setEnabled(true)

                                self._selectedType = LIAN_HUA_TYEP.HERO
                                self._selected = {}

                                resetctrbtnimage(self._rootnode["quickAddBtn_1"], BTN_NAME_MAPPING[1])
                                resetctrbtnimage(self._rootnode["quickAddBtn_2"], BTN_NAME_MAPPING[2])
                                self._rootnode[string.format("quickAddBtn_%d", 1)].index = nil
                                self._rootnode[string.format("quickAddBtn_%d", 2)].index = nil
                                self._animIsRunning = false

                                if callback then
                                    callback()
                                end
                            end
                        }
                    )
                    effect:setPosition(display.width / 2, display.height / 2)
                    self:addChild(effect, 1000)
                end,
                t = tostring(self._selectedType),
                ids = ids
            }
        )
    end
end

function SplitStoveScene:onSecretShopBtn()
    -- 神秘商店
    local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShenMi_Shop, game.player:getLevel(), game.player:getVip())
    if not bHasOpen then
        show_tip_label(prompt)
    else
        GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.ShenMi)
    end
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
end

function SplitStoveScene:onRefineView()
    self._viewType = VIEW_TYPE.REFINE

    self._rootnode["tab1"]:selected()
    self._rootnode["tab2"]:unselected()

    self._rootnode["tab1"]:setLocalZOrder(1)
    self._rootnode["tab2"]:setLocalZOrder(0)

    self._rootnode["rebornNode"]:setVisible(false)
    self._rootnode["refineNode"]:setVisible(true)
end

function SplitStoveScene:onRebornView()
    self._viewType = VIEW_TYPE.REBORN

    self._rootnode["tab1"]:unselected()
    self._rootnode["tab2"]:selected()

    self._rootnode["tab1"]:setLocalZOrder(0)
    self._rootnode["tab2"]:setLocalZOrder(1)

    self._rootnode["rebornNode"]:setVisible(true)
    self._rootnode["refineNode"]:setVisible(false)
    self._rootnode["costGoldLabel"]:setString("0")
end

function SplitStoveScene:onEnter()
    game.runningScene = self

    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)

    -- 广播
    if self._bExit then
        self._bExit = false
        local broadcastBg = self._rootnode["broadcast_tag"]
        if game.broadcast:getParent() ~= nil then
            game.broadcast:removeFromParent(true)
        end
        broadcastBg:addChild(game.broadcast)
    end
end

function SplitStoveScene:onExit()
    self:unregNotice()
    self._bExit = true
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

return SplitStoveScene
