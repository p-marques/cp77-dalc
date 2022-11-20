// Disassemble As Looting Choice by pMarK
// v1.3

public static exec func DALCListWardrobe(gi: GameInstance) -> Void {
    let wardrobeSys: wref<WardrobeSystem>;
    let stored: array<ItemID>;
    let itemData: wref<gameItemData>;

    wardrobeSys = GameInstance.GetWardrobeSystem(gi);

    stored = wardrobeSys.GetStoredItemIDs();

    LogChannel(n"DALC", "======================");
    LogChannel(n"DALC", "== LISTING WARDROBE ==");
    LogChannel(n"DALC", "======================");
    LogChannel(n"DALC", "=> Count: " + ArraySize(stored));

    for el in stored {
        itemData = RPGManager.GetItemData(gi, GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject(), el);

        LogChannel(n"DALC", "=> [" + EnumValueToString("gamedataItemType", Cast<Int64>(EnumInt(itemData.GetItemType()))) + "] " + UIItemsHelper.GetItemName(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(el)), itemData));
    }

    LogChannel(n"DALC", "==       DONE       ==");
}