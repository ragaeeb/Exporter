import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    Page
    {
        titleBar: TitleBar {
            title: qsTr("Purchases") + Retranslate.onLanguageChanged
        }
        
        ListView
        {
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        enabled: !ListItemData.purchased
                        title: ListItemData.title
                        description: ListItemData.description
                        status: enabled ? qsTr("$0.99") : qsTr("Unlocked!");
                        imageSource: enabled ? "images/ic_good.png" : ListItemData.imageSource
                    }
                }
            ]
            
            onTriggered: {
                var data = dataModel.data(indexPath);
                console.log("UserEvent: PurchaseElementTapped", data.sku);
                
                if (!data.purchased) {
                    payment.requestPurchase(data.sku, data.title);
                }
            }
            
            function onSettingChanged(key)
            {
                if (key == "exporter_csv" || key == "exporter_mms")
                {
                    adm.clear();
                    adm.append({'title': qsTr("CSV Exporting"), 'description': "Support for comma-separated-value format", 'imageSource': "images/menu/ic_export_csv.png", 'sku': "exporter_csv", 'purchased': persist.contains("exporter_csv")});
                    adm.append({'title': qsTr("MMS Support"), 'description': "Save multimedia content (videos, images, etc.)", 'imageSource': "images/ic_mms.png", 'sku': "exporter_mms", 'purchased': persist.contains("exporter_mms")});
                }
            }
            
            onCreationCompleted: {
                persist.settingChanged.connect(onSettingChanged);
                onSettingChanged("exporter_csv");
            }
        }
    }
}