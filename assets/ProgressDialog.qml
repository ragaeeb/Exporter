import bb.cascades 1.0

FullScreenDialog
{
    id: fd
    
    dialogContent: Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        leftPadding: 10; rightPadding: 10
        
        layout: DockLayout {}

        ImageView
        {
            id: progressBar
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            imageSource: "images/progress/progress_bar.png"
            scaleX: 0
            
            animations: [
                ScaleTransition {
                    id: st
                    fromX: 1
                    toX: 0
                    duration: 1000
                    easingCurve: StockCurve.QuarticIn
                    
                    onEnded: {
                        tt.fromY = 0;
                        tt.toY = 1000;
                        tt.duration = 1000;
                        tt.easingCurve = StockCurve.QuinticIn;
                        tt.play();
                    }
                }
            ]
        }
        
        Container
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            translationY: -1000
            
            ImageView
            {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                imageSource: "images/progress/circle.png"
                preferredHeight: 150
                preferredWidth: 150
            }
            
            Label
            {
                id: label
                textStyle.textAlign: TextAlign.Center
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                textStyle.base: SystemDefaults.TextStyles.SmallText
                textStyle.fontWeight: FontWeight.Bold
                textStyle.color: Color.White
                opacity: 0.8
                text: qsTr("Loading...") + Retranslate.onLanguageChanged
            }
            
            animations: [
                TranslateTransition {
                    id: tt
                    fromY: -1000
                    toY: 0
                    duration: 1000
                    easingCurve: StockCurve.QuinticOut
                    
                    onEnded: {
                        if (toY == 1000) {
                            fd.close();
                        }
                    }
                }
            ]
        }
    }
    
    onOpened: {
        tt.play();
    }
    
    function onProgressChanged(current, total)
    {
        label.text = qsTr("%1/%2").arg(current).arg(total);
        progressBar.scaleX = current/total;
        
        if (current == total) {
            st.play();
        }
    }
}