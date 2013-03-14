import bb.cascades 1.0
import CustomComponent 1.0

NavigationPane
{
    id: navigationPane

    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]

    Menu.definition: MenuDefinition
    {
        settingsAction: SettingsActionItem
        {
    	    property variant settingsPage
            
            onTriggered:
            {
                if (!settingsPage) {
                    definition.source = "SettingsPage.qml"
                    settingsPage = definition.createObject()
                }
                
                navigationPane.push(settingsPage);
            }
        }

        helpAction: HelpActionItem
        {
    	    property variant helpPage
            
            onTriggered:
            {
                if (!helpPage) {
                    definition.source = "HelpPage.qml"
                    helpPage = definition.createObject();
                }

                navigationPane.push(helpPage);
            }
        }
    }

    onPopTransitionEnded: {
        page.destroy();
    }
    
    BasePage
    {
        actions: [
	        ActionItem {
	            imageSource: "asset:///images/selectAll.png"
	            ActionBar.placement: ActionBarPlacement.OnBar
	            title: qsTr("Select All") + Retranslate.onLanguageChanged
	            
	            onTriggered: {
	                listView.multiSelectHandler.active = true
	                listView.selectAll();
	            }
	        }
        ]
        
        contentContainer: Container
        {
	        leftPadding: 20
	        rightPadding: 20
	        topPadding: 20
	        horizontalAlignment: HorizontalAlignment.Fill
	        
	        Label {
	            text: qsTr("Tap on a conversation to open up its messages and share them. Press-and-hold on a conversation to export them to persistant storage.")
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
		            if ( app.getValueFor("animations") == 1 ) {
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
	            id: listView
	            horizontalAlignment: HorizontalAlignment.Fill
	            verticalAlignment: VerticalAlignment.Fill
	            
	            function doExport(conversationIds)
	            {
	                filePicker.directories = [ app.getValueFor("output"), "/accounts/1000/shared/documents"]
	                filePicker.conversationIds = conversationIds
	                filePicker.open()
	            }
	
	            listItemComponents:
	            [
	                ListItemComponent
	                {
	                    StandardListItem
	                    {
	                        id: control
	                        
    	                    contextActions: [
    	                        ActionSet {
    	                            title: ListItemData.name
    	                            subtitle: qsTr("%1 messages").arg(ListItemData.messageCount)
    	                            
						            ActionItem {
						                id: exportAction
						                title: qsTr("Export TXT")
						                imageSource: "file:///usr/share/icons/ic_forward.png"
						                
						                onTriggered: {
							                control.ListItem.view.doExport([ListItemData.conversationId])
						                }
						            }
    	                        }
    	                    ]
	                        
	                        title: ListItemData.name
	                        description: ListItemData.number == "+16132206739" ? "+14042221034" : ListItemData.number
	                        status: ListItemData.messageCount
	                        imageSource: ListItemData.smallPhotoFilepath.length > 0 ? ListItemData.smallPhotoFilepath : "file:///usr/share/icons/tmb_contact.png"
	                    }
	                }
	            ]
	            
                attachedObjects: [
					FilePicker {
	                    property variant conversationIds
					    
					    id: filePicker
					    mode: FilePickerMode.SaverMultiple
		                title : qsTr("Select Folder") + Retranslate.onLanguageChanged
		                filter: ["*.txt"]
		                
		                onFileSelected : {
					        var result = selectedFiles[0]
							app.saveValueFor("output", result)
							
							app.exportSMS(conversationIds)
		                }
					}
                ]
	            
	            multiSelectAction: MultiSelectActionItem {}
                                
                multiSelectHandler {
                    actions: [
			            ActionItem {
			                property variant filePicker
			                
			                id: exportAction
			                enabled: false
			                title: qsTr("Export TXT")
			                imageSource: "file:///usr/share/icons/ic_forward.png"
			                
			                onTriggered: {
				                var selectedIndices = listView.selectionList()
				                var result = []
				
				                for (var i = 0; i < selectedIndices.length; i++) {
				                    result.push( listView.dataModel.data(selectedIndices[i]).conversationId )
				                }
				                
				                listView.doExport(result)
			                }
			            }
                    ]
                    
                    onActiveChanged: {
                        if (!active) {
                            listView.clearSelection()
                        }
                    }
             
                    status: qsTr("None selected")
                }
	            
	            dataModel: ArrayDataModel {
	                objectName: "dataModel"
	                id: theDataModel
	            }
	            
	            layoutProperties: StackLayoutProperties {
	                spaceQuota: 1
	            }
	            
                onSelectionChanged: {
                    var n = selectionList().length
                    multiSelectHandler.status = qsTr("%1 elements selected").arg(n)
                    exportAction.enabled = n > 0
                }
                
			    onTriggered: {
			        definition.source = "ConversationView.qml"
	                var page = definition.createObject()
	                page.contact = dataModel.data(indexPath)
	                navigationPane.push(page);
			    }
	        }
	    }
    }
}