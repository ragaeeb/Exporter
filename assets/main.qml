import bb.cascades 1.2
import CustomComponent 1.0

NavigationPane
{
    id: navigationPane

    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]

    Menu.definition: CanadaIncMenu
    {
        projectName: "exporter10"
        bbWorldID: "22552876"
        showSubmitLogs: true
    }

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
	            ActionBar.placement: ActionBarPlacement.OnBar
	            title: qsTr("Select All") + Retranslate.onLanguageChanged
	            enabled: false
	            
	            onTriggered: {
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
	        leftPadding: 10
	        rightPadding: 10
	        topPadding: 10
	        horizontalAlignment: HorizontalAlignment.Fill
	        
            ProgressDelegate
            {
                onCreationCompleted: {
                    app.conversationLoadProgress.connect(onProgressChanged);
                }
            }
	        
	        Label {
	            id: instructions
	            text: qsTr("Tap on a conversation to open up its messages and share them. Press-and-hold on a conversation to export them to persistant storage.")
	            textStyle.fontSize: FontSize.XSmall
	            multiline: true
	            horizontalAlignment: HorizontalAlignment.Fill
	            verticalAlignment: VerticalAlignment.Fill
	            textStyle.textAlign: TextAlign.Center
	            visible: !accountsDropDown.expanded
	            
		        animations: [
		            FadeTransition {
		                id: fadeInTransition
		                fromOpacity: 0
		                duration: 1000
		            }
		        ]
	            
		        onCreationCompleted: {
                    fadeInTransition.play();
		        }
	        }
	        
	        Divider {
	            bottomMargin: 0; topMargin: 0;
	        }
	        
	        ListView {
	            id: listView
	            horizontalAlignment: HorizontalAlignment.Fill
	            verticalAlignment: VerticalAlignment.Fill
	            
	            leadingVisual: AccountsDropDown
	            {
	                id: accountsDropDown
	                selectedAccountId: 23
	                
	                onAccountsLoaded: {
	                    if (numAccounts == 0) {
                            instructions.text = qsTr("No accounts found. Are you sure you gave the app the permissions it needs?");
	                    } else {
                            divider.visible = false;
	                    }
                    }
	                
	                onSelectedValueChanged: {
                        app.getConversationsFor(selectedValue);
                    }
                }
	            
	            function doExport(conversationIds)
	            {
	                filePicker.directories = [ persist.getValueFor("output"), "/accounts/1000/shared/documents"]
	                filePicker.conversationIds = conversationIds;
	                filePicker.open();
	            }
	            
	            function onConversationsImported(conversations)
	            {
	                adm.clear();
	                adm.append(conversations);
	                
                    selectAllAction.enabled = conversations.length > 0;

                    scrollToPosition(0, ScrollAnimation.None);
                    scroll(-100, ScrollAnimation.Smooth);
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
 
                                    delay: control.ListItem.indexInSection * 100
                                }
                            ]
                            
                            onCreationCompleted: {
                                showAnim.play();
                            }
	                        
    	                    contextActions: [
    	                        ActionSet {
    	                            title: ListItemData.name
    	                            subtitle: qsTr("%1 messages").arg(ListItemData.messageCount)
    	                            
						            ActionItem {
						                id: exportAction
						                title: qsTr("Export TXT")
						                imageSource: "images/menu/ic_export.png"
						                
						                onTriggered: {
							                control.ListItem.view.doExport([ListItemData.conversationId])
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
					    
					    id: filePicker
					    mode: FilePickerMode.SaverMultiple
		                title : qsTr("Select Folder") + Retranslate.onLanguageChanged
		                filter: ["*.txt"]
		                
		                onFileSelected : {
					        var result = selectedFiles[0];
							persist.saveValueFor("output", result);
							
                            app.exportSMS(conversationIds, accountsDropDown.selectedValue);
		                }
					}
                ]
	            
	            multiSelectAction: MultiSelectActionItem {}
                                
                multiSelectHandler {
                    actions: [
			            ActionItem {
			                id: multiExportAction
			                enabled: false
			                title: qsTr("Export TXT") + Retranslate.onLanguageChanged
			                imageSource: "images/menu/ic_export.png"
			                
			                onTriggered: {
				                var selectedIndices = listView.selectionList();
				                var result = [];
				
				                for (var i = 0; i < selectedIndices.length; i++) {
				                    result.push( listView.dataModel.data(selectedIndices[i]).conversationId );
				                }
				                
				                listView.doExport(result);
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

	            layoutProperties: StackLayoutProperties {
	                spaceQuota: 1
	            }

                onSelectionChanged: {
                    var n = selectionList().length;
                    multiSelectHandler.status = qsTr("%1 conversations selected").arg(n);
                    multiExportAction.enabled = n > 0;
                }

			    onTriggered: {
			        definition.source = "ConversationView.qml"
	                var page = definition.createObject();
                    page.accountId = accountsDropDown.selectedValue;
	                page.contact = dataModel.data(indexPath);
	                navigationPane.push(page);
			    }
	        }
	    }
    }
}