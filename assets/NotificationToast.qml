import bb.cascades 1.2

Delegate
{
    property string bodyText
    property variant icon
    property string titleText: qsTr("Tip!") + Retranslate.onLanguageChanged
    
    onObjectChanged: {
        if (object) {
            object.open();
        }
    }
    
    function init(text, iconUri, title)
    {
        if (text.length > 0)
        {
            active = true;
            bodyText = text;
            icon = iconUri;
            titleText = title;
        }
    }
    
    sourceComponent: ComponentDefinition
    {
        Dialog
        {
            id: root
            
            onOpened: {
                mainAnim.play();
            }
            
            Container
            {
                id: dialogContainer
                preferredWidth: Infinity
                preferredHeight: Infinity
                background: Color.create(0,0,0,0.5)
                layout: DockLayout {}
                opacity: 0
                
                Container
                {
                    id: toastBg
                    topPadding: 10; leftPadding: 10; rightPadding: 10; bottomPadding: 30
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    background: bg.imagePaint
                    minHeight: 100
                    minWidth: 300
                    maxWidth: 550
                    maxHeight: 550
                    
                    Container
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        ImageView {
                            id: infoImage
                            imageSource: "images/toast/tutorial_info.png"
                            verticalAlignment: VerticalAlignment.Center
                            translationX: -500
                        }
                        
                        Label {
                            id: tipLabel
                            text: titleText
                            textStyle.fontSize: FontSize.XXSmall
                            textStyle.fontWeight: FontWeight.Bold
                            verticalAlignment: VerticalAlignment.Top
                            horizontalAlignment: HorizontalAlignment.Fill
                            translationX: 500
                            
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                        }
                        
                        ImageButton
                        {
                            id: closeButton
                            defaultImageSource: "images/toast/toast_close.png"
                            pressedImageSource: defaultImageSource
                            horizontalAlignment: HorizontalAlignment.Right
                            verticalAlignment: VerticalAlignment.Center
                            rotationZ: 360
                            translationX: 1000
                            
                            onClicked: {
                                console.log("UserEvent: NotificationClose");
                                fadeOut.play();
                            }
                        }
                    }
                    
                    ImageView
                    {
                        id: toastIcon
                        imageSource: icon
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        loadEffect: ImageViewLoadEffect.FadeZoom
                        opacity: 0
                    }
                    
                    Container
                    {
                        leftPadding: 20; topPadding: 10
                        verticalAlignment: VerticalAlignment.Fill
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        Label {
                            id: bodyLabel
                            multiline: true
                            textStyle.fontSize: FontSize.XSmall
                            textStyle.fontStyle: FontStyle.Italic
                            text: bodyText
                            scaleX: 1.25
                            scaleY: 1.25
                            opacity: 0
                        }
                    }
                    
                    attachedObjects: [
                        ImagePaintDefinition {
                            id: bg
                            imageSource: "images/toast/toast_bg.amd"
                        }
                    ]
                }
                
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            console.log("UserEvent: NotificationToastTapped");
                            
                            if (event.propagationPhase == PropagationPhase.AtTarget) {
                                console.log("UserEvent: NotificationOutsideBounds");
                                fadeOut.play();
                            }
                        }
                    }
                ]
            }
            
            onClosed: {
                active = false;
            }
            
            attachedObjects: [
                SequentialAnimation
                {
                    id: mainAnim
                    
                    FadeTransition {
                        target: dialogContainer
                        fromOpacity: 0
                        toOpacity: 1
                        duration: 500
                        easingCurve: StockCurve.SineOut
                    }
                    
                    ParallelAnimation
                    {
                        TranslateTransition
                        {
                            target: closeButton
                            duration: 500
                            fromX: -500
                            toX: 0
                            easingCurve: StockCurve.QuinticOut
                        }
                        
                        FadeTransition
                        {
                            fromOpacity: 0
                            toOpacity: 1
                            target: toastIcon
                            duration: 750
                            easingCurve: StockCurve.ExponentialInOut
                        }
                        
                        RotateTransition
                        {
                            fromAngleZ: 0
                            toAngleZ: 360
                            target: toastIcon
                            duration: 1250
                            delay: 500
                            easingCurve: StockCurve.CubicInOut
                        }
                        
                        TranslateTransition
                        {
                            target: infoImage
                            duration: 500
                            fromX: 1000
                            toX: 0
                            easingCurve: StockCurve.CubicOut
                        }
                        
                        TranslateTransition
                        {
                            target: tipLabel
                            delay: 500
                            duration: 750
                            fromX: 500
                            toX: 0
                            easingCurve: StockCurve.ExponentialOut
                        }
                    }
                    
                    ParallelAnimation
                    {
                        RotateTransition
                        {
                            target: infoImage
                            fromAngleZ: 0
                            toAngleZ: 360
                            duration: 750
                            easingCurve: StockCurve.ExponentialIn
                        }
                        
                        RotateTransition
                        {
                            target: closeButton
                            delay: 250
                            fromAngleZ: 360
                            toAngleZ: 0
                            duration: 750
                            easingCurve: StockCurve.CircularOut
                        }
                    }
                    
                    ParallelAnimation
                    {
                        target: bodyLabel
                        
                        FadeTransition
                        {
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 500
                            easingCurve: StockCurve.QuadraticOut
                        }
                        
                        ScaleTransition
                        {
                            fromX: 1.5
                            fromY: 1.5
                            toX: 1
                            toY: 1
                            duration: 750
                            easingCurve: StockCurve.DoubleBounceIn
                        }
                    }
                },
                
                ParallelAnimation
                {
                    id: fadeOut
                    
                    FadeTransition {
                        fromOpacity: 1
                        toOpacity: 0
                        duration: 750
                        easingCurve: StockCurve.QuinticIn
                        target: dialogContainer
                    }
                    
                    TranslateTransition
                    {
                        target: toastBg
                        fromY: 0
                        toY: 1000
                        duration: 750
                        easingCurve: StockCurve.BackIn
                    }
                    
                    onEnded: {
                        root.close();
                    }
                }
            ]
        }
    }    
}