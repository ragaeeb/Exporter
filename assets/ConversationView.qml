import bb.cascades 1.0
import bb.cascades.pickers 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: rootPage
    property variant accountId
    property variant contact
    property string userName
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar {
        id: tb
    }
    
    onActionMenuVisualStateChanged: {
        if (actionMenuVisualState == ActionMenuVisualState.VisibleFull)
        {
            tutorial.execOverFlow( "selectRange", qsTr("You can use the '%1' feature from the menu to pick start and end points. Once you have your selection you can choose 'Share' and pick Exporter from the Share menu."), rangeSelector.rangeSelectAction );
            tutorial.execOverFlow( "copySelected", qsTr("You can use the '%1' feature from the menu to copy the selected messages to your clipboard."), copyAction );

            reporter.record("ConversationViewMenuShown");
        }
    }
    
    function cleanUp()
    {
        app.messagesImported.disconnect(onMessagesImported);
        persist.settingChanged.disconnect(onSettingChanged);
    }
    
    onContactChanged:
    {
        userName = persist.getValueFor("userName");

        definition.source = "ProgressDialog.qml";
        var progress = definition.createObject();
        
        progress.open();
        app.getMessagesFor(contact.conversationId, accountId);
    }
    
    function onSettingChanged(newValue, key)
    {
        if ( contact && (key == "latestFirst" || key == "userName" || key == "serverTimestamp") ) {
            contactChanged(contact);
        }
    }
    
    function concatenate()
    {
        var selectedIndices = listView.selectionList()
        var result = ""
        var doubleSpace = persist.getValueFor("doubleSpace") == 1

        for (var i = 0; i < selectedIndices.length; i ++) {
            result += listView.render(listView.dataModel.data(selectedIndices[i]))

            if (i < selectedIndices.length - 1) {
                result += "\n"
                
                if (doubleSpace) {
                    result += "\n"
                }
            }
        }
        
        return result
    }
    
    function onMessagesImported(results)
    {
        theDataModel.clear();
        reporter.record("MessagesLoaded", results.length);
        
        if (results.length > 0) {
            theDataModel.append(results);
            tb.title = contact.name.length > 0 ? contact.name : contact.number;
        } else {
            tb.title = qsTr("No messages found") + Retranslate.onLanguageChanged
        }
        
        tutorial.execActionBar( "saveAll", qsTr("To save this entire conversation, use the '%1' action at the bottom to save all the messages in one shot!").arg(saveAll.title) );
        tutorial.execActionBar( "selectAllMessages", qsTr("If you want to select all the messages to copy them to the clipboard or share them, use the '%1' action.").arg(selectAll.title), "l" );
    }
    
    onCreationCompleted: {
        persist.registerForSetting(rootPage, "latestFirst");
        persist.registerForSetting(rootPage, "userName", false, false);
        persist.registerForSetting(rootPage, "serverTimestamp", false, false);
        app.messagesImported.connect(onMessagesImported);

        addAction(rangeSelector.rangeSelectAction);        
        sld.appendItem( "CSV", persist.contains("exporter_csv") );
        sld.appendItem( "TXT", true, true );
        
        deviceUtils.attachTopBottomKeys(rootPage, listView);
    }
    
    actions: [
        ActionItem {
            id: selectAll
            imageSource: "images/menu/selectAll.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            title: qsTr("Select All") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: SelectAllConversationTriggered");
                listView.selectAll();
                reporter.record("SelectAllConversationTriggered");
            }
        },

        ActionItem {
            id: copyAction
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "images/common/ic_copy.png"
            enabled: false

            onTriggered: {
                console.log("UserEvent: CopyConversationTriggered");
                
                var result = concatenate();
                persist.copyToClipboard(result);
                reporter.record("CopyConversationTriggered");
            }
        },
        
        ActionItem {
            id: saveAll
            title: qsTr("Save All") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_save.png"
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SaveAllTriggered");
                sld.show();
                reporter.record("SaveAllTriggered");
            }
            
            attachedObjects: [
                FilePicker {
                    id: filePicker
                    property variant conversationIds
                    property int format
                    mode: FilePickerMode.SaverMultiple
                    title : qsTr("Select Folder") + Retranslate.onLanguageChanged
                    filter: ["*.txt"]

                    onFileSelected : {
                        var result = selectedFiles[0];
                        persist.setFlag("output", result);
                        
                        console.log("UserEvent: ConversationSelectFolderSelected", result);
                        
                        definition.source = "ProgressDialog.qml";
                        var progress = definition.createObject();
                        progress.open();
                        
                        app.exportSMS(contact.conversationId, accountId, format);
                        reporter.record("OutputFolder", result);
                        reporter.record("ExportFormat", format);
                        reporter.record("AccountId", accountId.toString());
                    }
                }
            ]
        },

        InvokeActionItem
        {
		    id: iai
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: false
            imageSource: "images/menu/ic_share.png"
		    title: qsTr("Share") + Retranslate.onLanguageChanged
		    
		    onEnabledChanged: {
		        if (enabled) {
                    tutorial.execActionBar( "shareSelected", qsTr("If you want to share the selected messages with your contacts use the '%1' action.").arg(title), "r" );
		        }
		    }

            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            onTriggered: {
                console.log("UserEvent: ShareActionTriggered");
                
                persist.showBlockingToast( qsTr("Note that BBM has a maximum limit for the length of text that can be inputted into the message field. So if your conversation is too big it may not paste properly.\n\nUse the Range Selector if the message gets truncated."), qsTr("OK") );
                iai.data = persist.convertToUtf8( concatenate() );
                
                reporter.record("ShareActionTriggered");
            }
        }
    ]
    
    Container
    {
        background: back.imagePaint
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
		ListView
		{
		    id: listView
            property alias backgroundIncoming: backIncoming
            property alias backgroundOutgoing: backOutgoing
	        objectName: "listView"
	        scrollRole: ScrollRole.Main
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

            attachedObjects: [
		        ImagePaintDefinition {
		            id: backIncoming
		            imageSource: "images/listitem.amd"
		        },
		        
                ImagePaintDefinition {
                    id: backOutgoing
                    imageSource: "images/ic_bubble.amd"
                },
		        
		        StaticRangeSelector {
		            id: rangeSelector
              	}
            ]
            
            function copyToClipboard(data) {
                persist.copyToClipboard( render(data) )
            }
            
            function render(data)
            {
                var time = offloader.renderStandardTime(data.time);
                var name = data.inbound ? data.sender : userName;
                var text = data.text;
                
                return time+" - "+name+": "+text
            }
            
            dataModel: ArrayDataModel {
                id: theDataModel
            }
            
            onSelectionChanged: {
                copyAction.enabled = iai.enabled = selectionList().length > 0;
            }
		
		    listItemComponents: [
		        ListItemComponent {
		            Container {
		                id: listItemRoot
		                property bool selected: ListItem.selected
		                opacity: 0.5
                        scaleX: 0.8
                        scaleY: 0.8
                        animations: [
                            ScaleTransition
                            {
                                id: showAnim
                                fromX: 0.8
                                toX: 1
                                fromY: 0.8
                                toY: 1
                                duration: 800
                                easingCurve: StockCurve.DoubleElasticOut
                                delay: Math.min(listItemRoot.ListItem.indexInSection * 100, 1000)
                            }
                        ]
                        
                        onCreationCompleted: {
                            showAnim.play();
                        }
		                
		                onSelectedChanged: {
		                    opacity = selected ? 1 : 0.5;
		                }
		                
		                leftPadding: 40; bottomPadding: 30; topPadding: 20; rightPadding: 20
		                
                        background: ListItemData.inbound ? ListItem.view.backgroundIncoming.imagePaint : ListItem.view.backgroundOutgoing.imagePaint
		                horizontalAlignment: HorizontalAlignment.Fill
		                preferredWidth: 1280
		                
		                Label {
		                    id: messageLabel
                            text: listItemRoot.ListItem.view.render(ListItemData)
		                    multiline: true
		                    verticalAlignment: VerticalAlignment.Center
		                }
		            }
		        }
		    ]
		    
		    onTriggered: {
                console.log("UserEvent: MessageTapped");
		        toggleSelection(indexPath);
		        
                tutorial.execCentered( "tapMessage", qsTr("Tap on the message again to deselect it.") );
		    }
		
		    layoutProperties: StackLayoutProperties {
		        spaceQuota: 1
		    }
		}
    }
    
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/background.amd"
        },
        
        SystemListDialog {
            id: sld
            body: qsTr("Choose Output Type") + Retranslate.onLanguageChanged
            title: qsTr("Output Format") + Retranslate.onLanguageChanged
            selectionMode: ListSelectionMode.Single
            
            onFinished: {
                console.log("UserEvent: OutputFormatChosen", value);
                
                if (value == SystemUiResult.ConfirmButtonSelection)
                {
                    filePicker.format = selectedIndices[0];
                    filePicker.directories = [ persist.getFlag("output"), "/accounts/1000/shared/documents"]
                    filePicker.open();
                }
            }
        }
    ]
}