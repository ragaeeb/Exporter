import bb.cascades 1.0

Page {
    property alias titleVisible: titleBarControl.visible
    property alias contentContainer: contentContainer.controls

    Container
    {
        attachedObjects: [
			ImagePaintDefinition {
			    id: back
			    imageSource: "images/background.amd"
			}
        ]
        
        background: back.imagePaint
        
		Container {
		    id: titleBarControl
		    layout: DockLayout {}
		
		    horizontalAlignment: HorizontalAlignment.Fill
		    verticalAlignment: VerticalAlignment.Top
		
		    ImageView {
		        imageSource: "images/title_bg.amd"
		        topMargin: 0
		        leftMargin: 0
		        rightMargin: 0
		        bottomMargin: 0
		
		        horizontalAlignment: HorizontalAlignment.Fill
		        verticalAlignment: VerticalAlignment.Fill
		        
		        animations: [
		            TranslateTransition {
		                id: translate
		                toY: 0
		                fromY: -100
		                duration: 1000
		            }
		        ]
		        
		        onCreationCompleted: {
                    translate.play();
		        }
		    }
		    
		    Container
		    {
		        horizontalAlignment: HorizontalAlignment.Left
		        verticalAlignment: VerticalAlignment.Center
		        leftPadding: 45; bottomPadding: 20
		        
		        ImageView {
		            imageSource: "images/logo.png"
		            topMargin: 0
		            leftMargin: 0
		            rightMargin: 0
		            bottomMargin: 0
		    
		            animations: [
		                ParallelAnimation
		                {
		                    id: fadeTranslate
		                    
			                FadeTransition {
			                    duration: 1000
			                    easingCurve: StockCurve.CubicIn
			                    fromOpacity: 0
			                    toOpacity: 1
			                }
			    
			                TranslateTransition {
			                    fromX: -200
			                    duration: 1000
			                }
		                }
		            ]
		            
		            onCreationCompleted: {
                        fadeTranslate.play();
		            }
		        }
		    }
		}

        Container // This container is replaced
        {
            layout: DockLayout {
                
            }
            
            id: contentContainer
            objectName: "contentContainer"
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
    }
}