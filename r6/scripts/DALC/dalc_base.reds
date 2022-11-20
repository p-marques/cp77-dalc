// Disassemble As Looting Choice by pMarK
// v1.2

module DALC.Base

public class DALC {
    private let lootingController: wref<LootingController>;
    private let gameInstance: GameInstance;
    private let dataManager: wref<InventoryDataManagerV2>;
    private let player: ref<PlayerPuppet>;
    private let blackboard: ref<IBlackboard>;
    private let craftingSystem: ref<CraftingSystem>;
    private let customChoice: InteractionChoiceData;
    private let settings: DALCDefaultSettings;

    public func Setup(
        lootingController: wref<LootingController>,
        gi: GameInstance,
        dataManager: wref<InventoryDataManagerV2>,
        referenceChoice: InteractionChoiceData
        ) -> Void {
        this.lootingController = lootingController;
        this.gameInstance = gi;
        this.dataManager = dataManager;
        this.craftingSystem = GameInstance.GetScriptableSystemsContainer(gi).Get(n"CraftingSystem") as CraftingSystem;
        this.player = dataManager.GetPlayer();
        this.blackboard = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications);
        this.customChoice = new InteractionChoiceData(n"ChoiceDisassemble_Hold",
            EInputKey.IK_Z, true, GetLocalizedText("Gameplay-Devices-DisplayNames-DisassemblableItem"),
            referenceChoice.type, referenceChoice.data, referenceChoice.captionParts);

        this.SetupSettings();
    }

    protected func SetupSettings() -> Void {
        let excludedQualities: array<String>;
        let shouldPlaySound: Bool;

        // ------ Settings Start ------

        // Item quality strings in here prevent the disassemble option from appearing.
        // Possible qualities: "Common", "Uncommon", "Rare", "Epic" and "Legendary"
        // Default -> excludedQualities = ["Legendary"];
        excludedQualities = ["Legendary"];

        // Play a sound after disassemble? This is not the standard disassemble sound, just a stand-in.
        // Default -> shouldPlaySound = true;
        shouldPlaySound = true;

        // ------ Settings End ------

        this.settings = DALCDefaultSettings.Initialize(excludedQualities, shouldPlaySound);
    }

    public func GetIsEnabled() -> Bool {
        return true;
    }

    public func HandleAdditionOfChoiceDisassemble(data: LootData) -> LootData {
        if this.GetIsEnabled() &&
            this.CanCurrentItemBeDisassembled() &&
            !this.lootingController.GetIsLocked() {
            if !this.IsDisassembleChoiceShowing(data) {
                ArrayPush(data.choices, this.customChoice);
            }

            this.player.RegisterInputListener(this, n"ChoiceDisassemble_Hold");
        }
        else {
            this.player.UnregisterInputListener(this, n"ChoiceDisassemble_Hold");
        }

        return data;
    }

    private func CanCurrentItemBeDisassembled() -> Bool {
        let inventoryItemData: InventoryItemData = this.lootingController.GetCurrentItem();
        let itemData: ref<gameItemData> = InventoryItemData.GetGameItemData(inventoryItemData);
        //let itemRecord: = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemData.GetID()));

        // Why does RPGManager.CanItemBeDisassembled() return true on Ammo?
        // Shards also come back as true.
        if Equals(itemData.GetItemType(), gamedataItemType.Con_Ammo) || itemData.HasTag(n"Shard") || itemData.HasTag(n"Quest") {
            return false;
        }

        if this.IsQualityExcluded(InventoryItemData.GetQuality(inventoryItemData)) {
            return false;
        }

        return RPGManager.CanItemBeDisassembled(this.gameInstance, itemData);
    }

    protected func IsQualityExcluded(quality: CName) -> Bool {
        return DALCDefaultSettings.IsQualityExcluded(this.settings, quality);
    }

    protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
        if this.GetIsEnabled() &&
            Equals(ListenerAction.GetName(action), n"ChoiceDisassemble_Hold") &&
            Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_HOLD_COMPLETE) {
            let itemData: InventoryItemData = this.lootingController.GetCurrentItem();
            let itemID: ItemID = InventoryItemData.GetID(itemData);

            if this.CanCurrentItemBeDisassembled() {
                this.DisassembleItem(itemID, InventoryItemData.GetQuantity(itemData));
            }
        }
    }

    private func DisassembleItem(itemID: ItemID, amount: Int32) -> Void {
        let restoredAttachments: array<ItemAttachments>;
        let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.gameInstance);
        let listOfIngredients: array<IngredientData> = this.craftingSystem.GetDisassemblyResultItems(this.lootingController.GetLootOwner(), itemID, amount, restoredAttachments);
        let playerGameObject: ref<GameObject> = this.player as GameObject;
        let i: Int32 = 0;

        while i < ArraySize(restoredAttachments) {
            transactionSystem.GiveItem(playerGameObject, restoredAttachments[i].itemID, 1);
            i += 1;
        };

        GameInstance.GetTelemetrySystem(this.gameInstance).LogItemDisassembled(playerGameObject, itemID);
        if (transactionSystem.RemoveItem(this.lootingController.GetLootOwner(), itemID, amount)) {
            this.ForceInteractionReactivation();
        }

        i = 0;
        while i < ArraySize(listOfIngredients) {
            transactionSystem.GiveItem(playerGameObject, ItemID.FromTDBID(listOfIngredients[i].id.GetID()), listOfIngredients[i].quantity);
            i += 1;
        };

        this.AwardExperience(listOfIngredients, amount);

        this.craftingSystem.UpdateBlackboard(CraftingCommands.DisassemblingFinished, itemID, listOfIngredients);

        if (this.ShouldPlaySound()) {
            this.PlayDisassembleSound();
        }
    }

    private func AwardExperience(ingredients: array<IngredientData>, amount: Int32) -> Void {
        RPGManager.AwardXP(this.gameInstance, Cast<Float>(8), gamedataProficiencyType.Crafting);
    }

    private func IsDisassembleChoiceShowing(data: LootData) -> Bool {
        for choice in data.choices {
            if Equals(choice.localizedName, "Disassemble") {
                return true;
            }
        }

        return false;
    }

    protected func ShouldPlaySound() -> Bool {
        return this.settings.playSoundAfterDisassemble;
    }

    protected func PlayDisassembleSound() -> Void {
        GameObject.PlaySoundEvent(this.player, n"dev_vending_machine_can_falls");
    }

    private func ForceInteractionReactivation() -> Void {
        let event: ref<InteractionActivationEvent> = new InteractionActivationEvent();

        event.eventType = gameinteractionsEInteractionEventType.EIET_activate;
        event.hotspot = this.lootingController.GetLootOwner();
        event.activator = this.player;
        event.layerData = new InteractionLayerData(n"Loot");

        this.lootingController.GetLootOwner().QueueEvent(event);
    }

    private func ShowWarningMessage(message : String) -> Void {
        let warningMsg: SimpleScreenMessage;

        warningMsg.isShown = true;
        warningMsg.duration = 5.00;
        warningMsg.message = message;

        this.blackboard.SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(warningMsg), true);
    }
}

struct DALCDefaultSettings {
    private let excludedQualities: array<CName>;

    public let playSoundAfterDisassemble: Bool;

    public static func Initialize(qualitiesStrings: array<String>, playSound: Bool) -> DALCDefaultSettings {
        let excludedQualities: array<CName>;
        let size: Int32 = ArraySize(qualitiesStrings);
        let i: Int32;

        ArrayGrow(excludedQualities, size);

        while i < size {
            excludedQualities[i] = StringToName(qualitiesStrings[i]);

            i += 1;
        }

        return new DALCDefaultSettings(excludedQualities, playSound);
    }

    public static func IsQualityExcluded(self: DALCDefaultSettings, quality: CName) -> Bool {
        return ArrayContains(self.excludedQualities, quality);
    }
}


