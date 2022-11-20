// Disassemble As Looting Choice by pMarK
// v1.2

module DALC.Menu
import DALC.Base.DALC

public class DALCWithMenu extends DALC {
    private let menuSettings: ref<DALCMenuSettings>;

    protected func SetupSettings() -> Void {
        this.menuSettings = new DALCMenuSettings();
        ModSettings.RegisterListenerToClass(this.menuSettings); // Hard "Mod Settings" dependency
    }

    public func GetIsEnabled() -> Bool {
        return this.menuSettings.IsEnabled;
    }

    protected func ShouldPlaySound() -> Bool {
        return this.menuSettings.ShouldPlaySound;
    }

    protected func IsQualityExcluded(quality: CName) -> Bool {
        return !this.GetShowSettingByQuality(quality);
    }

    private func GetShowSettingByQuality(quality: CName) -> Bool {
        if (Equals(quality, n"Common")) {
            return this.menuSettings.ShowForCommon;
        }

        if (Equals(quality, n"Uncommon")) {
            return this.menuSettings.ShowForUncommon;
        }

        if (Equals(quality, n"Rare")) {
            return this.menuSettings.ShowForRare;
        }

        if (Equals(quality, n"Epic")) {
            return this.menuSettings.ShowForEpic;
        }

        return this.menuSettings.ShowForLegendary;
    }
}

public class DALCMenuSettings {
    @runtimeProperty("ModSettings.mod", "D.A.L.C.")
    @runtimeProperty("ModSettings.category", "Main")
    @runtimeProperty("ModSettings.displayName", "Enabled")
    @runtimeProperty("ModSettings.description", "Enable/Disable mod.")
    public let IsEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "D.A.L.C.")
    @runtimeProperty("ModSettings.category", "Main")
    @runtimeProperty("ModSettings.displayName", "Play Sound")
    @runtimeProperty("ModSettings.description", "If this is enabled a sound will be played when you disassemble an item.")
    public let ShouldPlaySound: Bool = true;

    @runtimeProperty("ModSettings.mod", "D.A.L.C.")
    @runtimeProperty("ModSettings.category", "Show Disassemble By Quality")
    @runtimeProperty("ModSettings.displayName", "Common")
    @runtimeProperty("ModSettings.description", "Should the disassemble option appear for Common items?")
    public let ShowForCommon: Bool = true;

    @runtimeProperty("ModSettings.mod", "D.A.L.C.")
    @runtimeProperty("ModSettings.category", "Show Disassemble By Quality")
    @runtimeProperty("ModSettings.displayName", "Uncommon")
    @runtimeProperty("ModSettings.description", "Should the disassemble option appear for Uncommon items?")
    public let ShowForUncommon: Bool = true;

    @runtimeProperty("ModSettings.mod", "D.A.L.C.")
    @runtimeProperty("ModSettings.category", "Show Disassemble By Quality")
    @runtimeProperty("ModSettings.displayName", "Rare")
    @runtimeProperty("ModSettings.description", "Should the disassemble option appear for Rare items?")
    public let ShowForRare: Bool = true;

    @runtimeProperty("ModSettings.mod", "D.A.L.C.")
    @runtimeProperty("ModSettings.category", "Show Disassemble By Quality")
    @runtimeProperty("ModSettings.displayName", "Epic")
    @runtimeProperty("ModSettings.description", "Should the disassemble option appear for Epic items?")
    public let ShowForEpic: Bool = true;

    @runtimeProperty("ModSettings.mod", "D.A.L.C.")
    @runtimeProperty("ModSettings.category", "Show Disassemble By Quality")
    @runtimeProperty("ModSettings.displayName", "Legendary")
    @runtimeProperty("ModSettings.description", "Should the disassemble option appear for Legendary items?")
    public let ShowForLegendary: Bool = false;
}
