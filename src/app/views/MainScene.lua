local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png"):move(display.center):addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World 0", "Arial", 40):move(display.cx, display.cy + 200):addTo(self)

    print("ffffff")
end

return MainScene
