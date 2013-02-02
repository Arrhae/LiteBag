--[[----------------------------------------------------------------------------

  LiteBag/LiteBagBagButtonTemplate.lua

  Copyright 2013 Mike Battersby

----------------------------------------------------------------------------]]--

local BankContainers = { [BANK_CONTAINER]  = true }
do
    for i = 1,NUM_BANKBAGSLOTS do
        BankContainers[NUM_BAG_SLOTS+i] = true
    end
end

function LiteBagBagButton_Update(self)

    self.bagID = self:GetID()
    self.isBank = BankContainers[self:GetID()]

    if self.bagID == BACKPACK_CONTAINER then
        SetItemButtonTexture(self, "Interface\\Buttons\\Button-Backpack-Up")
        self.tooltipText = BACKPACK_TOOLTIP
        return
    elseif self.bagID == BANK_CONTAINER then
        SetItemButtonTexture(self, "Interface\\Buttons\\Button-Backpack-Up")
        self.tooltipText = "Bank"
        return
    end

    self.slotID = ContainerIDToInventoryID(self:GetID())

    local texture = _G[self:GetName().."IconTexture"]
    local textureName = GetInventoryItemTexture("player", self.slotID)

    local numBankSlots, bankFull = GetNumBankSlots()
    local buyBankSlot = numBankSlots + 4

    if self.bagID == buyBankSlot then
        self.purchaseCost = GetBankSlotCost()
    else
        self.purchaseCost = nil
    end

    if textureName then
        SetItemButtonTexture(self, textureName)
    elseif self.purchaseCost then
        SetItemButtonTexture(self, "Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab")
    else
        textureName = select(2, GetInventorySlotInfo("Bag0Slot"))
        SetItemButtonTexture(self, textureName)
    end

    if self.isBank and self.bagID > buyBankSlot then
        SetItemButtonTextureVertexColor(self, 1, 0, 0)
    else
        SetItemButtonTextureVertexColor(self, 1, 1, 1)
    end

end

function LiteBagBagButton_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE")
end

function LiteBagBagButton_OnEvent(self)
    if event == "INVENTORY_SEARCH_UPDATE" then
        if IsContainerFiltered(self.slotID) then
            self.searchOverlay:Show()
        else
            self.searchOverlay:Hide()
        end
    end
end

function LiteBagBagButton_OnEnter(self)

    LiteBagFrame_HighlightBagButtons(self:GetParent(), self:GetID())

    if self.bagID == BACKPACK_CONTAINER or self.bagID == BANK_CONTAINER then
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local hasItem = GameTooltip:SetInventoryItem("player", self.slotID)
    if not hasItem then
        if self.purchaseCost then
            GameTooltip:ClearLines()
            GameTooltip:AddLine(BANK_BAG_PURCHASE)
            GameTooltip:AddDoubleLine(COSTS_LABEL, GetCoinTextureString(self.purchaseCost))
        elseif self.bagID == BACKPACK_CONTAINER then        
            GameTooltip:SetText(BACKPACK_TOOLTIP)
        elseif self.isBank and self.bagID > GetNumBankSlots() + 4 then
            GameTooltip:SetText(BANK_BAG_PURCHASE)
        elseif self.isBank then
            GameTooltip:SetText(BANK_BAG)
        else
            GameTooltip:SetText(BAGSLOT)
        end
    end
    GameTooltip:Show()
end

function LiteBagBagButton_OnLeave(self)
    LiteBagFrame_UnhighlightBagButtons(self:GetParent(), self:GetID())
    GameTooltip:Hide()
    ResetCursor()
end

function LiteBagBagButton_OnDrag(self)
    if self.bagID ~= BACKPACK_CONTAINER and self.bagID ~= BANK_CONTAINER then
        PickupBagFromSlot(self.slotID)
    end
end

function LiteBagBagButton_OnClick(self)
    if self.bagID == BACKPACK_CONTAINER then
        PutItemInBackpack()
    elseif self.purchaseCost then
        PlaySound("igMainMenuOption");
        BankFrame.nextSlotCost = self.purchaseCost
        StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
    else
        PutItemInBag(self.slotID)
    end
end

