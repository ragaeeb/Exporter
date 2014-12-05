import bb.cascades 1.2

TabbedPane
{
    activeTab: exportPane
    showTabsOnActionBar: true
    
    Menu.definition: CanadaIncMenu
    {
        labelColor: 'Signature' in ActionBarPlacement ? Color.Black : Color.White
        projectName: "exporter10"
        help.imageSource: "images/menu/ic_help.png"
        help.title: qsTr("Help") + Retranslate.onLanguageChanged
        settings.imageSource: "images/menu/ic_settings.png"
        settings.title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    Tab {
        id: exportPane
        imageSource: "images/menu/ic_save.png"
        title: qsTr("Export") + Retranslate.onLanguageChanged
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        delegate: Delegate {
            source: "ExportPane.qml"
        }
        
        onTriggered: {
            console.log("UserEvent: ExportTab");
        }
    }
    
    Tab
    {
        title: qsTr("Purchase") + Retranslate.onLanguageChanged
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        imageSource: "images/menu/ic_purchase.png"
        
        delegate: Delegate {
            source: "PurchasePane.qml"
        }
        
        onTriggered: {
            console.log("UserEvent: PurchasePane");
        }
    }
}