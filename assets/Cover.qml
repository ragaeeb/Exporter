import bb.cascades 1.0

Container
{
	background: back.imagePaint
    topPadding: 20
    leftPadding: 20
    rightPadding: 20
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill

    layout: DockLayout {}

    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/title_bg.png"
        }
    ]

    ImageView {
        imageSource: "images/logo.png"
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
    }
}