import bb.cascades 1.0
import bb.cascades.pickers 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        id: rootPage
        
        titleBar: ExporterTitleBar {}
        
        actions: [
            ActionItem {
                id: selectAllAction
                imageSource: "images/menu/selectAll.png"
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement.Signature : ActionBarPlacement.OnBar
                title: qsTr("Select All") + Retranslate.onLanguageChanged
                enabled: false
                
                onTriggered: {
                    console.log("UserEvent: SelectAllTriggered");
                    
                    listView.multiSelectHandler.active = true;
                    listView.selectAll();
                }
            }
        ]
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        Container
        {
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/background.amd"
                }
            ]
            
            background: back.imagePaint
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            AccountsDropDown
            {
                id: accountsDropDown
                selectedAccountId: persist.contains("accountId") ? persist.getValueFor("accountId") : 23
                bottomMargin: 0
                
                onAccountsLoaded: {
                    if (numAccounts == 0) {
                        persist.showToast( qsTr("No accounts found. Are you sure you gave the app the permissions it needs?"), qsTr("OK"), "asset:///images/dropdown/ic_account.png" );
                    }
                    
                    else if ( persist.tutorialVideo("http://youtu.be/_sSZJPBwlnc") ) {}
                    else if ( persist.tutorial("tutorialExportTxt", qsTr("These are a list of all the conversations, press-and-hold on one and from the menu choose 'Select More' and then 'Export TXT' to save it. You can also tap on the conversation itself and save only parts of it if you wish."), "asset:///images/menu/ic_export.png" ) ) {}
                    else if ( persist.tutorial("tutorialExportTxt", qsTr("These are a list of all the conversations, press-and-hold on one and from the menu choose 'Select More' and then 'Export TXT' to save it. You can also tap on the conversation itself and save only parts of it if you wish."), "asset:///images/menu/ic_export.png" ) ) {}
                    else if ( persist.tutorial("tutorialSelectAll", qsTr("You can tap the Select All button at the bottom of the screen to quickly export all your conversations!"), "asset:///images/menu/selectAll.png" ) ) {}
                    else if ( persist.tutorial("tutorialDropDown", qsTr("Use the dropdown at the top to switch between your mailboxes."), "asset:///images/dropdown/ic_account.png" ) ) {}
                    else if ( persist.tutorial("tutorialSettings", qsTr("There are many customizations you can make to the way the messages are exported. You can do this from the Settings. To access the app settings, swipe-down from the top-bezel and choose 'Settings' from the application menu."), "file:///usr/share/icons/bb_action_install.png" ) ) {}
                    else if ( persist.reviewed() ) {}
                    else if ( reporter.performCII() ) {}
                }
                
                onSelectedValueChanged: {
                    definition.source = "ProgressDialog.qml";
                    var progress = definition.createObject();
                    progress.open();
                    
                    console.log("UserEvent: AccountSelected", selectedValue);
                    
                    app.getConversationsFor(selectedValue);
                    persist.saveValueFor("accountId", selectedValue, false);
                }
            }
            
            ListView
            {
                id: listView
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                function doExport(conversationIds, format)
                {
                    if ( format == OutputFormat.CSV && !persist.contains("exporter_csv") ) {
                        persist.showToast( qsTr("This is a purchasable feature. You can buy it for just $0.99!"), qsTr("OK"), "asset:///images/ic_good.png" );
                        app.requestPurchase("exporter_csv", qsTr("CSV Export") );
                    } else {
                        filePicker.directories = [ persist.getValueFor("output"), "/accounts/1000/shared/documents"]
                        filePicker.conversationIds = conversationIds;
                        filePicker.format = format;
                        filePicker.open();
                    }
                }
                
                function getAllSelected()
                {
                    var selectedIndices = listView.selectionList();
                    var result = [];
                    
                    for (var i = 0; i < selectedIndices.length; i++) {
                        result.push( listView.dataModel.data(selectedIndices[i]).conversationId );
                    }
                    
                    return result;
                }
                
                function onConversationsImported(conversations)
                {
                    adm.clear();
                    adm.append(conversations);
                    
                    selectAllAction.enabled = conversations.length > 0;
                    emptyDelegate.delegateActive = conversations.length == 0;
                    listView.visible = conversations.length > 0;
                }
                
                onCreationCompleted: {
                    app.conversationsImported.connect(onConversationsImported);
                }
                
                listItemComponents:
                [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: control
                            
                            scaleX: 0.8
                            scaleY: 0.8
                            opacity: 0
                            animations: [
                                ParallelAnimation
                                {
                                    id: showAnim
                                    ScaleTransition
                                    {
                                        fromX: 0.8
                                        toX: 1
                                        fromY: 0.8
                                        toY: 1
                                        duration: 800
                                        easingCurve: StockCurve.ElasticOut
                                    }
                                    
                                    FadeTransition {
                                        fromOpacity: 0
                                        toOpacity: 1
                                        duration: 200
                                    }
                                    
                                    delay: Math.min(control.ListItem.indexInSection * 100, 1000);
                                }
                            ]
                            
                            onCreationCompleted: {
                                showAnim.play();
                            }
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: ListItemData.name
                                    subtitle: qsTr("%1 messages").arg(ListItemData.messageCount)
                                    
                                    ActionItem {
                                        id: exportAction
                                        title: qsTr("Export TXT")
                                        imageSource: "images/menu/ic_export.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: ExportTxtTriggered");
                                            control.ListItem.view.doExport([ListItemData.conversationId], OutputFormat.TXT)
                                        }
                                    }
                                    
                                    ActionItem {
                                        title: qsTr("Export CSV")
                                        imageSource: "images/menu/ic_export_csv.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: ExportCsvTriggered");
                                            control.ListItem.view.doExport([ListItemData.conversationId], OutputFormat.CSV)
                                        }
                                    }
                                }
                            ]
                            
                            title: ListItemData.name ? ListItemData.name : ListItemData.number
                            description: ListItemData.number
                            status: ListItemData.messageCount
                            imageSource: ListItemData.smallPhotoFilepath.length > 0 ? "file://"+ListItemData.smallPhotoFilepath : "images/ic_user.png"
                        }
                    }
                ]
                
                attachedObjects: [
                    FilePicker {
                        property variant conversationIds
                        property int format
                        
                        id: filePicker
                        mode: FilePickerMode.SaverMultiple
                        title : qsTr("Select Folder") + Retranslate.onLanguageChanged
                        filter: ["*.txt"]
                        
                        onFileSelected : {
                            var result = selectedFiles[0];
                            console.log("UserEvent: FolderSelected", result);
                            persist.saveValueFor("output", result, false);
                            
                            definition.source = "ProgressDialog.qml";
                            var progress = definition.createObject();
                            progress.open();
                            
                            app.exportSMS(conversationIds, accountsDropDown.selectedValue, format);
                        }
                    }
                ]
                
                multiSelectAction: MultiSelectActionItem {
                    imageSource: "images/menu/ic_select_more.png"
                }
                
                multiSelectHandler {
                    
                    actions: [
                        ActionItem {
                            id: multiExportAction
                            enabled: false
                            title: qsTr("Export TXT") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_export.png"
                            
                            onTriggered: {
                                console.log("UserEvent: ExportTxtMultiTriggered");
                                listView.doExport( listView.getAllSelected(), OutputFormat.TXT );
                            }
                        },
                        
                        ActionItem {
                            id: multiExportCsvAction
                            enabled: false
                            title: qsTr("Export CSV") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_export_csv.png"
                            
                            onTriggered: {
                                console.log("UserEvent: ExportCsvMultiTriggered");
                                listView.doExport( listView.getAllSelected(), OutputFormat.CSV );
                            }
                        }
                    ]
                    
                    onActiveChanged: {
                        if (!active) {
                            listView.clearSelection();
                        }
                    }
                    
                    status: qsTr("None selected") + Retranslate.onLanguageChanged
                }
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                onSelectionChanged: {
                    var n = selectionList().length;
                    multiSelectHandler.status = qsTr("%1 conversations selected").arg(n);
                    multiExportCsvAction.enabled = multiExportAction.enabled = n > 0;
                }
                
                onTriggered: {
                    definition.source = "ConversationView.qml"
                    var page = definition.createObject();
                    page.accountId = accountsDropDown.selectedValue;
                    page.contact = dataModel.data(indexPath);
                    navigationPane.push(page);
                    
                    console.log("UserEvent: ConversationTriggered");
                }
            }
            
            EmptyDelegate
            {
                id: emptyDelegate
                graphic: "images/placeholders/empty_conversations.png"
                labelText: qsTr("There are no messages found for that specific mailbox.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: EmptyConversationTapped");
                    accountsDropDown.expanded = true;
                }
            }
        }
    }
}