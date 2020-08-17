import QtQuick 2.0

Rectangle {
    id: r
    width: parent.width*0.3
    height: parent.height*0.5
    border.width: 2
    border.color: app.c2
    color: app.c1
    radius: app.fs*0.5
    anchors.centerIn: parent
    visible: false
    onVisibleChanged: {
        if(visible)tiSetMod.focus=true
    }
    Column{
        spacing: app.fs*0.5
        anchors.centerIn: r
        UTextInput{
            id: tiSetMod
            label: 'Usuario de Twich: '
            width: r.width-app.fs
            KeyNavigation.tab: botSetMod
             Keys.onReturnPressed: r.setMod()
             onSeted: r.setMod()
        }
        BotonUX{
            id: botSetMod
            text: 'Listo'
            anchors.right: parent.right
            KeyNavigation.tab: tiSetMod
            Keys.onReturnPressed: r.setMod()
            onClicked:{
                r.setMod()
            }
        }
    }
    function setMod(){
        app.moderador=tiSetMod.text.toLowerCase().replace(/ /g, '')
        app.user=app.moderador
        app.url='https://www.twitch.tv/embed/'+app.moderador+'/chat?parent=nextsigner.github.io'
        wv.url=app.url
        r.visible=false
        setDesktopIcon("-twitchUser="+app.user)
    }
}
