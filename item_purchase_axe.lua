

local tableItemsToBuy = { 
				"item_stout_shield", -------we need to sell it later
				"item_tango",
				"item_tango",
				"item_tranquil_boots",
				"item_blink",
				"item_blade_mail",
				"item_crimson_guard",
				"item_shivas_guard",
				"item_heart",
			};


----------------------------------------------------------------------------------------------------

function ItemPurchaseThink()

	local npcBot = GetBot();

	if ( #tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end
--wehn the list of items are all purchased
	local sNextItem = tableItemsToBuy[1];

	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
		npcBot:ActionImmediate_PurchaseItem( sNextItem );
		table.remove( tableItemsToBuy, 1 );
	end

end

----------------------------------------------------------------------------------------------------
