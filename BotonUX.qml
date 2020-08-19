import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: r
    width: a.contentWidth+(r.fontSize*2*(r.us.padding*2))+(r.us.borderWidth*2)+app.fs+padding
    height: a.contentHeight+(r.fontSize*2*(r.us.padding*2))+(r.us.borderWidth*2)+app.fs+padding
    opacity: enabled?1.0:0.5
    color: 'transparent'
    radius: customRadius===-1?r.us.radius:customRadius
    border.color: xR1.border.color
    border.width: 0
    antialiasing: true
    property var us: app&&app.us?app.us:unikSettings
    property int customRadius: -1
    property int customBorderWidth: -1
    property string customBorderColor: ''
    property var settingObj
    property int padding: 0
    property int fontSize: app.fs
    property bool canceled: false
    property alias text: a.text
    property string t2
    property color backgroundColor: app.c1
    property color fontColor: app.c2
    property string fontFamily: 'Arial'
    property var objToRunQml
    property string qmlCode:''
    property int speed: 100
    property alias touchEnabled: maBX.enabled
    property alias pressed: maBX.p
    property alias hovered: maBX.e
    property alias bg: xR1
    property alias glow: glow1
    signal clicked

    Rectangle{
        id: xR1
        color: 'transparent'
        border.width: r.customBorderWidth===-1?r.us.borderWidth:r.customBorderWidth
        border.color: r.customBorderColor===''?app.c3:r.customBorderColor
        radius: r.radius//r.us.radius
        width: parent.width
        height: parent.height
        anchors.centerIn: r
        antialiasing: true
        Rectangle{
            id: b3
            opacity: maBX.p?0.25:0.0
            width: parent.width
            height: parent.height
            radius: r.radius
            anchors.centerIn: parent
            color: r.fontColor
            antialiasing: true
            Behavior on opacity{NumberAnimation{duration:r.speed}}
        }
        Rectangle{
            id: b1
            width: xR1.width
            height: xR1.height
            radius: r.radius
            rotation: -180
            anchors.centerIn: parent
            opacity: 0.25
            antialiasing: true
            gradient: Gradient {
                GradientStop {
                    position: 0.00;
                    color:'transparent';
                }
                GradientStop {
                    position: 0.35;
                    color:'transparent';
                }
                GradientStop {
                    position: 1.00;
                    color: r.fontColor;
                }
            }
            Behavior on opacity{NumberAnimation{duration:200}}
        }
        Rectangle{
            id: b1Clon
            width: xR1.width
            height: xR1.height
            radius: r.radius
            anchors.centerIn: parent
            opacity: b1.opacity
            antialiasing: true
            gradient: Gradient {
                GradientStop {
                    position: 0.00;
                    color:'transparent';
                }
                GradientStop {
                    position: 0.35;
                    color:'transparent';
                }
                GradientStop {
                    position: 1.00;
                    color: r.fontColor;
                }
            }
        }
        Rectangle{
            id: b2
            opacity: maBX.p?1.0:0.25
            width: xR1.width
            height: xR1.height
            radius: r.radius
            antialiasing: true
            onOpacityChanged: {
                if(opacity>=0.5&&!maBX.p){
                    b1.opacity=0.5
                }
            }
            anchors.centerIn: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.00;
                    color:'transparent';
                }
                GradientStop {
                    position: 1.00;
                    color: r.fontColor;
                }
            }
        }
    }
    UText {
        id: a
        font.pixelSize: r.fontSize
        font.family: r.fontFamily
        color: r.fontColor
        anchors.centerIn: xR1
    }
    UText {
        id: a2
        text:a.text
        font.pixelSize: r.fontSize
        font.family: r.fontFamily
        color: r.backgroundColor
        anchors.centerIn: xR1
        opacity: 0.0
        Behavior on x{NumberAnimation{duration:200}}
    }
    Glow {
        id: glow1
        anchors.fill: a
        radius: 6
        samples: 15
        color: r.backgroundColor
        source: a
        opacity: 1.0
    }
    MouseArea{
        id: maBX
        anchors.fill: r
        hoverEnabled: true
        property bool p: false
        property bool e: false
        onEChanged: {
            if(e){
                b1.opacity=1.0
            }else{
                b1.opacity=0.15
            }
        }
        onPChanged: {
            if(p){
                b1.opacity=1.0
                a2.opacity=1.0
                a.opacity=0.0
            }else{
                e=false
                b1.opacity=0.15
                a2.opacity=0.0
                a.opacity=1.0
            }
        }
        onEntered: {
            e=true
            p=false
        }
        onExited: {
            e=false
            p=false
        }
        onPressed: {
            e=false
            p=true
        }
        onReleased: {
            e=false
            p=false
        }
        onDoubleClicked: {
            e=false
            p=true
            if(r.qmlCode===''){
                runNormal.restart()
                return
            }
            run.start()
        }
        onClicked: {
            e=false
            p=true
            if(r.qmlCode===''){
                runNormal.restart()
                return
            }
            run.start()
        }
    }
    Timer{
        id: runNormal
        interval: r.speed*2
        onTriggered: {
            r.clicked()
        }
    }
    Timer{
        id: run
        interval: r.speed*10
        onTriggered: {
            r.clicked()
            r.runQml(qmlCode)
        }
    }
    Timer{
        id: tBxRefresh
        running: maBX.p
        interval: 1500
        onTriggered: {
            maBX.p=false
            maBX.e=false
        }
    }
    function run(){
        r.clicked()
    }
    function runQml(q){
        r.clicked()
        var obj = Qt.createQmlObject(q, objToRunQml, 'botonUx-'+r.objectName)
    }
}
