import bb.cascades 1.0

BasePage
{
    property variant contact
    
    onContactChanged: {
        label.text = qsTr("Conversation with %1").arg(contact.name)
        var messages = app.getMessagesFor(contact.conversationId)
        theDataModel.clear()
        theDataModel.append(messages)
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
    
    actions: [
        ActionItem {
            imageSource: "asset:///images/selectAll.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            title: qsTr("Select All") + Retranslate.onLanguageChanged
            
            onTriggered: {
                listView.selectAll();
            }
        },

        ActionItem {
            id: copyAction
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ic_copy.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: false

            onTriggered: {
                var result = concatenate()
                persist.copyToClipboard(result)
            }
        },

        InvokeActionItem {
		    id: iai
		    title: qsTr("Share")

            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            
            enabled: false
            
            onTriggered: {
                iai.data = concatenate()
            }
            
            ActionBar.placement: ActionBarPlacement.OnBar
        },

		ActionItem {
			title: qsTr("Range Select") + Retranslate.onLanguageChanged
			imageSource: "file:///usr/share/icons/bb_action_moveother.png"
			enabled: !listView.rangeSelect
			onTriggered: {
			    persist.showToast( qsTr("This mode allows you to select a range of messages.\n\nTap the first message, then tap the last message and all of the ones in between will then be selected."), qsTr("OK") )
			    listView.first = listView.last = undefined
                listView.rangeSelect = true
            }
      	}
    ]
    
    contentContainer: Container
    {
        leftPadding: 20
        rightPadding: 20
        topPadding: 20
        
        Label {
            id: label
            textStyle.fontSize: FontSize.XSmall
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
            bottomMargin: 65
            
	        animations: [
	            FadeTransition {
	                id: fadeInTransition
	                fromOpacity: 0
	                duration: 1000
	            }
	        ]
            
	        onCreationCompleted:
	        {
	            if ( persist.getValueFor("animations") == 1 ) {
	                fadeInTransition.play()
	            }
	        }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            preferredHeight: 1
            background: Color.LightGray
        }
        
		ListView {
            property alias background: back
            property variant first
            property variant last
            property bool rangeSelect: false

            id: listView
	        objectName: "listView"

            attachedObjects: [
		        ImagePaintDefinition {
		            id: back
		            imageSource: "asset:///images/listitem.amd"
		        }
            ]
            
            function render(data)
            {
			    var timeFormat = "MMM d/yy, hh:mm:ss";
			    var timeSetting = persist.getValueFor("timeFormat")
			    
			    if (timeSetting == 1) {
			        timeFormat = "hh:mm:ss"
			    } else if (timeSetting == 2) {
			        timeFormat = ""
			    }
                
                var time = Qt.formatDateTime(data.time, timeFormat)
                var name = data.inbound ? data.sender : persist.getValueFor("userName")
                var text = data.text
                
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
                if (rangeSelect)
                {
                    if (!first) {
                        first = listView.selected()
                    } else if (!last) {
                        last = selectionList()[selectionList().length - 1]

                        for (var i = first[0] + 1; i < last[0]; i ++) {
                            listView.select([i], true)
                        }
                        
                        rangeSelect = false
                    }
                }

                copyAction.enabled = iai.enabled = selectionList().length > 0
            }
		
		    listItemComponents: [
		        ListItemComponent {
		            Container {
		                id: listItemRoot
		                property bool active: ListItem.active
		                property bool selected: ListItem.selected
		                opacity: 0.5
		                
		                onSelectedChanged: {
		                    opacity = selected ? 1 : 0.5
		                }
		                
		                leftPadding: 40; bottomPadding: 30; topPadding: 20
		                
		                background: ListItem.view.background.imagePaint
		                horizontalAlignment: HorizontalAlignment.Fill
		                preferredWidth: 1280
		                
		                Label {
		                    id: messageLabel
		                    text: {
							    listItemRoot.ListItem.view.render(ListItemData)
		                    }
		                    multiline: true
		                    verticalAlignment: VerticalAlignment.Center
		                }
		                
		                contextActions: [
		                    ActionSet {
		                        ActionItem {
		                            title: qsTr("Copy") + Retranslate.onLanguageChanged
		                        }
		                    }
		                ]
		            }
		        }
		    ]
		    
		    onTriggered: {
		        toggleSelection(indexPath)
		    }
		
		    horizontalAlignment: HorizontalAlignment.Fill
		    verticalAlignment: VerticalAlignment.Fill
		
		    layoutProperties: StackLayoutProperties {
		        spaceQuota: 1
		    }
		}
    }
}