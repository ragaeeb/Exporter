import bb.cascades 1.2

TabbedPane
{
    activeTab: exportPane
    showTabsOnActionBar: true
    
    Menu.definition: CanadaIncMenu
    {
        bbWorldID: "22552876"
        helpPageQml: "ExporterHelp.qml"
        projectName: "exporter"
        
        onFinished: {
            if (clean) {
                tutorial.execAppMenu();
            }
        }
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
        imageSource: "images/tabs/ic_purchase.png"
        
        delegate: Delegate {
            source: "PurchasePane.qml"
        }
        
        onTriggered: {
            console.log("UserEvent: PurchasePane");
        }
    }
}