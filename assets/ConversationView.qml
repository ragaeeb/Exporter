import bb.cascades 1.0
import bb.cascades.pickers 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    property variant accountId
    property variant contact
    property int timeSetting
    property string userName
    
    titleBar: TitleBar {
        id: tb
    }
    
    onContactChanged:
    {
        userName = persist.getValueFor("userName");
        timeSetting = persist.getValueFor("timeFormat");

        definition.source = "ProgressDialog.qml";
        var progress = definition.createObject();
        
        progress.open();
        app.getMessagesFor(contact.conversationId, accountId);
    }
    
    function onSettingChanged(key)
    {
        if (key == "latestFirst" || key == "timeFormat" || key == "userName" || key == "serverTimestamp") {
            contactChanged(contact);
        }
    }
    
    function onMessagesImported(results)
    {
        theDataModel.clear();
        
        if (results.length > 0) {
            theDataModel.append(results);
            tb.title = contact.name.length > 0 ? contact.name : contact.number;
        } else {
            tb.title = qsTr("No messages found") + Retranslate.onLanguageChanged
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
    
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    actions: [
        ActionItem {
            imageSource: "images/menu/selectAll.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            title: qsTr("Select All") + Retranslate.onLanguageChanged
            
            onTriggered: {
                listView.selectAll();
            }
        },

        ActionItem {
            id: copyAction
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "images/ic_copy.png"
            enabled: false

            onTriggered: {
                var result = concatenate();
                persist.copyToClipboard(result);
            }
        },
        
        ActionItem {
            title: qsTr("Save All") + Retranslate.onLanguageChanged
            imageSource: "images/menu/ic_save.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                sld.show();
            }
            
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
                        persist.saveValueFor("output", result, false);
                        
                        definition.source = "ProgressDialog.qml";
                        var progress = definition.createObject();
                        progress.open();
                        
                        app.exportSMS(contact.conversationId, accountId, OutputFormat.TXT);
                    }
                }
            ]
        },

        InvokeActionItem
        {
		    id: iai
		    title: qsTr("Share") + Retranslate.onLanguageChanged

            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            enabled: false
            
            onTriggered: {
                persist.showBlockingToast( qsTr("Note that BBM has a maximum limit for the length of text that can be inputted into the message field. So if your conversation is too big it may not paste properly.\n\nUse the Range Selector if the message gets truncated."), qsTr("OK") );
                iai.data = persist.convertToUtf8( concatenate() );
            }
            
            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    
    Container
    {
        background: back.imagePaint
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
		ListView
		{
            property alias backgroundIncoming: backIncoming
            property alias backgroundOutgoing: backOutgoing

            id: listView
	        objectName: "listView"

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
			    var timeFormat = "MMM d/yy, hh:mm:ss";
			    
			    if (timeSetting == 1) {
			        timeFormat = "hh:mm:ss"
			    } else if (timeSetting == 2) {
			        timeFormat = ""
			    }
                
                var time = Qt.formatDateTime(data.time, timeFormat);
                var name = data.inbound ? data.sender : userName;
                var text = data.text;
                
                if (timeSetting == 2) {
                    return name+": "+text
                } else {
					return time+" - "+name+": "+text
                }
            }
            
            dataModel: ArrayDataModel {
                id: theDataModel
            }
            
            onSelectionChanged: {
                copyAction.enabled = iai.enabled = selectionList().length > 0
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
		        toggleSelection(indexPath);
		    }
		
		    horizontalAlignment: HorizontalAlignment.Fill
		    verticalAlignment: VerticalAlignment.Fill
		
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
                if (result == SystemUiResult.ConfirmButtonSelection)
                {
                    filePicker.format = selectedIndices[0];
                    filePicker.directories = [ persist.getValueFor("output"), "/accounts/1000/shared/documents"]
                    filePicker.open();
                }
            }
        }
    ]
    
    onCreationCompleted: {
        persist.settingChanged.connect(onSettingChanged);
        addAction(rangeSelector.rangeSelectAction);
        
        app.messagesImported.connect(onMessagesImported);
        
        sld.appendItem( "CSV", persist.contains("exporter_csv") );
        sld.appendItem( "TXT", true, true );
    }
}