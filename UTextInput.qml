import QtQuick 2.0

Item{
    id:r
    width: parent.width
    height: r.fontSize*2
    property var us: app&&app.us?app.us:unikSettings
    property alias textInput:tiData
    property int diffWidth: width-label.contentWidth
    property alias text:tiData.text
    property alias textInputContainer: rectXTextInput
    property string dataType: 'text'
    property alias maximumLength: tiData.maximumLength
    property alias focusTextInput:tiData.focus
    property alias customCursor: rectCursor
    property string label: 'Input: '
    property color fontColor: app.c2
    property int fontSize: app.fs
    property int customHeight: -1
    property RegExpValidator regularExp
    signal seted(string text)
    onFocusChanged: {
        if(focus){
            tiData.focus=true
        }
    }
    Row{
        spacing: app.fs*0.5
        Text{
            id: label
            text: r.label
            font.family: r.us.fontFamily
            font.pixelSize: r.fontSize
            color: r.fontColor
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle{
            id: rectXTextInput
            width: r.width-label.contentWidth-parent.spacing
            height: r.customHeight===-1?r.fontSize*2:r.customHeight
            color: 'transparent'
            border.width: r.us.borderWidth
            border.color: r.fontColor
            radius: r.us.radius
            Rectangle{
                anchors.fill: parent
                color: !tiData.focus?app.c2:'transparent'
                opacity: !tiData.focus?0.25:1.0
                radius: parent.radius
                border.width: !tiData.focus?rectXTextInput.border.width:rectXTextInput.border.width+1
                border.color: rectXTextInput.border.color
            }
            TextInput{
                id: tiData
                font.pixelSize: r.fontSize
                //focus: true
                width: parent.width-r.fontSize
                height: r.fontSize
                clip: true
                anchors.centerIn: parent
                onTextChanged: r.textChanged(text)
                Keys.onReturnPressed: r.seted(text)
                color: r.fontColor
                validator: r.regularExp
                cursorDelegate: rectCursor
            }
        }
    }
    RegExpValidator{
        id: regExpDataType
    }
    Component{
        id: rectCursor
        Rectangle {
            color: r.fontColor
            width: r.fontSize*0.25
            Timer{
                running: true
                repeat: true
                interval: 500
                onTriggered: {
                    if(tiData.focus){
                        parent.visible=!parent.visible
                    }else{
                        parent.visible=false
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        if(r.dataType!=='text'){
            if(r.dataType==='dd.dd'){
                regExpDataType.regExp = /^(^([1-9][0-9]{1})[\.]{1}[0-9]{2})|^(^([1-9][0-9]{0})[\.]{1}[0-9]{2})/
                r.regularExp = regExpDataType
            }
        }
    }
}
