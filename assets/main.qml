import bb.cascades 1.2

TabbedPane
{
    activeTab: exportTab
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
            
            if (exportControl.object) {
                exportControl.object.initialize();
                
                tutorial.execActionBar( "exportTab", qsTr("In the '%1' tab you can select one or more conversations that you wish to view or save.").arg(exportTab.title), "b" );
                tutorial.execActionBar( "purchaseTab", qsTr("In the '%1' tab you can purchase additional features to maximize the app's functionality.").arg(purchaseTab.title), "r" );
            }
        }
    }
    
    Tab {
        id: exportTab
        imageSource: "images/tabs/ic_export.png"
        title: qsTr("Export") + Retranslate.onLanguageChanged
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        delegate: Delegate {
            id: exportControl
            source: "ExportPane.qml"
        }
        
        onTriggered: {
            console.log("UserEvent: ExportTab");
        }
    }
    
    Tab
    {
        id: purchaseTab
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