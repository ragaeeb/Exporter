import bb.cascades 1.2

TabbedPane
{
    activeTab: exportPane
    showTabsOnActionBar: true
    
    Menu.definition: CanadaIncMenu
    {
        projectName: "exporter10"
        bbWorldID: "22552876"
        showSubmitLogs: true
    }
    
    Tab {
        id: exportPane
        imageSource: "images/menu/ic_save.png"
        title: qsTr("Export") + Retranslate.onLanguageChanged
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        delegate: Delegate {
            source: "ExportPane.qml"
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
    }
}