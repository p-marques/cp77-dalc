// Disassemble As Looting Choice by pMarK
// v1.2

module DALC.Overrides
import DALC.Base.DALC

@if(ModuleExists("DALC.Menu"))
import DALC.Menu.DALCWithMenu

@addField(LootingController)
private let disassembleAsLootingOptionMod: ref<DALC>;

@wrapMethod(LootingController)
private final func RefreshChoicesPool(choices: script_ref<array<InteractionChoiceData>>) -> Void {
    if !IsDefined(this.disassembleAsLootingOptionMod) {
        this.InitializeDALC();
        this.disassembleAsLootingOptionMod.Setup(
            this,
            this.m_gameInstance,
            this.m_dataManager,
            this.m_currendData.choices[0]);
    }

    this.m_currendData = this.disassembleAsLootingOptionMod.HandleAdditionOfChoiceDisassemble(this.m_currendData);

    wrappedMethod(this.m_currendData.choices);
}

@if(ModuleExists("DALC.Menu"))
@addMethod(LootingController)
private func InitializeDALC() -> Void {
    this.disassembleAsLootingOptionMod = new DALCWithMenu();
}
@if(!ModuleExists("DALC.Menu"))
@addMethod(LootingController)
private func InitializeDALC() -> Void {
    this.disassembleAsLootingOptionMod = new DALC();
}

@addMethod(LootingController)
public func GetIsLocked() -> Bool {
    return this.m_isLocked;
}

@addMethod(LootingController)
public func GetCurrentItem() -> InventoryItemData {
    let itemData: ref<gameItemData> = this.m_dataManager.GetExternalGameItemData(this.m_currendData.ownerId, this.m_currendData.itemIDs[this.m_currendData.currentIndex]);

    return this.m_dataManager.GetInventoryItemData(this.GetLootOwner(), itemData);
}

@addMethod(LootingController)
public func GetLootOwner() -> wref<GameObject> {
    return GameInstance.FindEntityByID(this.m_gameInstance, this.m_currendData.ownerId) as GameObject;
}

@addMethod(InventoryDataManagerV2)
public func GetPlayer() -> wref<PlayerPuppet> {
    return this.m_Player;
}