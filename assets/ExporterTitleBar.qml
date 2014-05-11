import bb.cascades 1.0

TitleBar
{
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties
    {
        Container
        {
            background: back.imagePaint
            id: titleBarControl
            preferredHeight: 150
            minHeight: 150
            leftPadding: 20; topPadding: 20
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/title_bg.amd" 
                }
            ]
            
            ImageView {
                imageSource: "images/logo.png"
                loadEffect: ImageViewLoadEffect.FadeZoom
            }
            
            Divider {
                
            }
        }
    }
}