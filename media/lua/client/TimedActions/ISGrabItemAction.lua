--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISGrabItemAction = ISBaseTimedAction:derive("ISGrabItemAction");

function ISGrabItemAction:isValid()
	-- Check that the item wasn't picked up by a preceding action
	if self.item == nil or self.item:getSquare() == nil then return false end

	local destContainer = getSpecificPlayer(self.character:getPlayerNum()):getInventory()
	return destContainer:hasRoomFor(self.character, self.item:getItem())
end

function ISGrabItemAction:update()
	self.item:getItem():setJobDelta(self:getJobDelta());
end

function ISGrabItemAction:start()
	self.item:getItem():setJobType(getText("ContextMenu_Grab"));
	self.item:getItem():setJobDelta(0.0);
end

function ISGrabItemAction:stop()
    ISBaseTimedAction.stop(self);
    self.item:getItem():setJobDelta(0.0);

end

function ISGrabItemAction:perform()
	print("check steral")
	
	if(self.item ~= nil) then
		
		local ssquare = getSourceSquareOfItem(self.item,self.character)
		if(ssquare ~= nil) then			
			local OwnerGroupId = SSGM:GetGroupIdFromSquare(ssquare)
			local TakerGroupId = self.character:getModData().Group
			if(OwnerGroupId ~= -1) and (TakerGroupId ~= OwnerGroupId) then
				print("ga stealing detected!")
				SSGM:Get(OwnerGroupId):stealingDetected(self.character)
			end
		end	
	end
	
    local inventoryItem = self.item:getItem()
    self.item:getSquare():transmitRemoveItemFromSquare(self.item);
    self.item:removeFromWorld()
    self.item:removeFromSquare()
    self.item:setSquare(nil)
    inventoryItem:setWorldItem(nil)
    inventoryItem:setJobDelta(0.0);
    self.character:getInventory():setDrawDirty(true);
    self.character:getInventory():AddItem(inventoryItem);

    local pdata = getPlayerData(self.character:getPlayerNum());
    if pdata ~= nil then
        pdata.playerInventory:refreshBackpacks();
        pdata.lootInventory:refreshBackpacks();
    end
	

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
	
	
end

function ISGrabItemAction:new (character, item, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.item = item;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	return o
end
