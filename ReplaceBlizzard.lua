--[[----------------------------------------------------------------------------

  LiteBag/ReplaceBlizzard.lua

  Copyright 2013 Mike Battersby

----------------------------------------------------------------------------]]--

local inventoryFrame, bankFrame

function LiteBagFrame_ReplaceBlizzard(inventory, bank)

    BankFrame:UnregisterAllEvents()

    inventoryFrame = inventory
    bankFrame = bank

    OpenBackpack = function () inventoryFrame:Show() end
    OpenAllBags = OpenBackpack

    ToggleBag = function (id) LiteBagFrame_ToggleShown(inventoryFrame) end
    ToggleAllBags = ToggleBag

    hooksecurefunc('CloseBackpack', function () LiteBagFrame_Hide(inventoryFrame) end)
    hooksecurefunc('CloseAllBags', function () LiteBagFrame_Hide(inventoryFrame) end)

    BagSlotButton_UpdateChecked = function () end

end

LiteBagFrame_ReplaceBlizzard(LiteBagInventory, LiteBagBank)
