import QtQuick 2.7
import QtQuick.Controls 2.0
import QtWebEngine 1.5
import QtQuick.Window 2.2
ApplicationWindow {
    id: app
    visible: Qt.platform.os!=='android'?false:true
    visibility: Qt.platform.os!=='android'?'Windowed':'Maximized'
    width: dev?xApp.width:xStart.width
    height: dev?xApp.height:xStart.height
    flags: Qt.Window | Qt.FramelessWindowHint
    x:Screen.width*0.5-width*0.5
    y:Screen.height*0.5-height*0.5
    color: 'transparent'

    property bool dev: false

    property string moduleName: 'twitch-speech'
    property int fs: app.width*0.035
    property color c1: 'black'
    property color c2: 'white'
    property color c3: 'gray'
    property color c4: 'red'
    property string uHtml: ''
    property bool voiceEnabled: true
    property string user: ''
    property string url: ''
    property string moderador:''
    property var mods: ['ricardo__martin', 'nextsigner', 'lucssagg']
    property var ue: ['ricardo__martin', 'lucssagg', 'nextsigner']
    property bool allSpeak: true

    property var arrayLanguages: ["es-ES_EnriqueVoice", "es-ES_EnriqueV3Voice", "es-ES_LauraVoice", "es-ES_LauraV3Voice", "es-LA_SofiaVoice","es-LA_SofiaV3Voice","es-US_SofiaVoice","es-US_SofiaV3Voice" ]

    FontLoader{name: "FontAwesome"; source: "qrc:/fontawesome-webfont.ttf"}
    USettings{
        id: unikSettings
        url:app.moduleName+'.cfg'
        onCurrentNumColorChanged: setVars()
        Component.onCompleted: {
            if(Qt.platform.os!=='android'){
                setVars()
            }
        }
        function setVars(){
            let m0=defaultColors.split('|')
            let ct=m0[currentNumColor].split('-')
            app.c1=ct[0]
            app.c2=ct[1]
            app.c3=ct[2]
            app.c4=ct[3]
        }
    }

    Item{
        id: xApp
        width: Screen.width
        height: Screen.desktopAvailableHeight
        //anchors.centerIn: parent
        Row{
            //Url texto a voz http://texttospeechrobot.com/tts/es/texto-a-voz/
            Rectangle{
                width: xApp.width*0.8
                height: xApp.height
                color: '#ff8833'
                WebEngineView{
                    id: wvtav
                    //url: 'http://texttospeechrobot.com/tts/es/texto-a-voz/'

                    anchors.fill: parent
                    property QtObject defaultProfile: WebEngineProfile {
                        id: wep
                        //httpUserAgent: raiz.userAgent
                        //useForGlobalCertificateVerification: true
                        httpUserAgent: 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36'
                        storageName: "Default"
                        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
                        //persistentStoragePath: '.'
                        //httpCacheType: WebEngineProfile.MemoryHttpCache
                        onDownloadRequested: {
                            app.onDLR(download)
                        }
                        onDownloadFinished: {

                        }
                    }
                    settings.javascriptCanOpenWindows: true
                    settings.allowRunningInsecureContent: false
                    //settings.hyperlinkAuditingEnabled:  true
                    settings.javascriptCanAccessClipboard: true
                    settings.localStorageEnabled: true
                    settings.javascriptEnabled: true
                    onLoadProgressChanged:{
                        if(loadProgress===100){
                            tInit.start()
                        }
                    }
                }
            }
            Rectangle{
                width: xApp.width*0.2
                height: xApp.height
                color: '#ff8833'
                WebEngineView{
                    id: wv
                    anchors.fill: parent
                    visible: false
                    onUrlChanged: {
                        if((''+url)==='https://www.twitch.tv/?no-reload=true'){
                            let c='<iframe frameborder="0"
        scrolling="no"
        id="chat_embed"
        src="https://www.twitch.tv/embed/nextsigner/chat?parent=nextsigner.github.io"
        height="500"
        width="350">
</iframe>'
                            //wv.loadHtml(c)
                            //app.url='http://twitch.tv/nextsigner/embed'
                            //app.url='https://www.twitch.tv/login?no-mobile-redirect=true'
                            wv.url=app.url
                            wv.visible=true
                        }
                    }
                    onLoadProgressChanged: {
                        if(loadProgress===100){
                            //                        if((''+wv.url)==='http://twitch.tv/nextsigner/embed'){
                            //                            app.url='https://www.twitch.tv/embed/nextsigner/chat?parent=nextsigner.github.io'
                            //                            wv.url=app.url
                            //                            wv.visible=true
                            //                        }
                            wv.visible=true
                            tCheck.start()

                        }
                    }
                }
            }
        }
        XSetMod{
            id: xSetMod
            width: xApp.width
            anchors.horizontalCenter: parent.horizontalCenter
        }
        //ULogView{id: uLogView}
        //UWarnings{id: uWarnings}



    }
    Rectangle{
        id: xStart
        width: 100
        height: 100
        color: 'blue'
        Boton{
            id: btn1
            width: parent.width*0.5
            height: width
            t: '\uf04b'
            anchors.centerIn: parent
            enabled: false
            onClicking: Qt.quit()
        }
        //opacity: 0.5
        //anchors.bottom: parent.bottom
    }
    //    UText{
    //        text: 'Url: '+wv.url
    //        width: xApp.width
    //        color: 'red'
    //        font.pixelSize: app.fs*4
    //        wrapMode: Text.WrapAnywhere
    //    }
    property bool iniciado: false
    property int vInit: 0
    property string uMsg: ''
    property real uMp3Duration: 0.0
    property string initString: 'iniciando audio del chat'
    Timer{
        id:tCheck
        running: false
        repeat: true
        interval: 200
        onTriggered: {
            wv.runJavaScript('document.getElementById("root").innerText', function(result) {
                if(result!==app.uHtml){
                    let d0=result//.replace(/\n/g, 'XXXXX')
                    app.uHtml=result
                    if(d0.indexOf(':')>0){
                        let d1=d0.split(':')
                        let d2=d1[d1.length-1]
                        let d3=d2.split('Enviar')
                        let mensaje = d3[0]

                        let d5=d0.split('\n\n')
                        let d6=d5[d5.length-3]
                        let d7=d0.split(':')
                        let d8=d7[d7.length-2].split('\n')
                        let usuario=''+d8[d8.length-1].replace('chat\n', '')
                        let msg=usuario+' dice '+mensaje
                        let user=''+usuario.replace(/\n/g, '' )

                        if(isVM(msg)&&(''+msg).indexOf('chat.whatsapp.com')<0&&(''+mensaje).indexOf('!')!==1){
                            console.log('u['+usuario+'] '+app.ue.toString())
                            if(app.ue.indexOf(usuario)>=0 || app.allSpeak){
                                //                                if(Qt.platform.os==='windows'){
                                //                                    unik.speak(msg)
                                //                                }else{
                                console.log(msg)
                                if(user.indexOf('itomyy17')>=0){
                                    unik.speak(msg)
                                }else{
                                    speakMp3(user, msg)
                                }
                                //}

                            }
                        }

                        //Comandos de Usuarios
                        if(isVM(msg)){
                            //Set all speak
                            if((''+mensaje).indexOf('!voz=')===1){
                                let m0=(''+mensaje).split('!voz=')
                                let voice=parseInt(m0[1])
                                if(voice<=app.arrayLanguages.length-1){
                                    manSqliteData.setVoice(user, voice)
                                }
                            }
                        }

                        //Comandos de Administradores
                        if(isVM(msg)&&(''+msg).indexOf('chat.whatsapp.com')<0&&(''+mensaje).indexOf('!')===1&&app.mods.indexOf(user)>=0){
                            let m0=mensaje.split('!')
                            let m1=m0[1].split(' ')
                            let paramUser=m1[1].replace(/\n/g, '' )
                            //Set all speak
                            if(m1[0].length>1&&m1[0]==='alls'){
                                app.allSpeak=!app.allSpeak
                                if(app.allSpeak){
                                    unik.speak("Ahora se oirán todos los mensajes del chat.")
                                }else{
                                    unik.speak("Ahora solo algunos usuarios del chat se oirán.")
                                }
                            }
                            //Add user speak
                            if(m1[0].length>1&&m1[0]==='as'){
                                if(app.ue.indexOf(paramUser)<0){
                                    unik.speak("Se agrega para hablar a "+paramUser)
                                    app.ue.push(paramUser)
                                }else{
                                    unik.speak(paramUser+' ya estaba agregado.')
                                }
                            }
                            //Remove user speak
                            if(m1[0].length>1&&m1[0]==='rs'){
                                if(app.ue.indexOf(paramUser)>=0){
                                    unik.speak("Se quita para hablar a "+paramUser)
                                    app.ue.pop(paramUser)
                                }else{
                                    unik.speak(paramUser+' no estaba agregado.')
                                }
                            }
                            //Set volume speak
                            if(m1[0].length>1&&m1[0]==='sv'){
                                if(app.ue.indexOf(paramUser)>=0){
                                    unik.setTtsVolume(parseInt(paramUser))
                                }else{
                                    unik.speak('El comando no se ha aplicado. Falta el valor del volumen.')
                                }
                            }
                            app.uHtml=result
                            return
                        }
                        if(msg.indexOf(''+app.user)>=0 &&msg.indexOf('show')>=0){
                            app.visible=true
                        }
                        if(msg.indexOf(''+app.user)>=0 &&msg.indexOf('hide')>=0){
                            app.visible=false
                        }
                        if(msg.indexOf(''+app.user)>=0 &&msg.indexOf('launch')>=0){
                            Qt.openUrlExternally(app.url)
                        }
                        app.flags = Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
                        app.flags = Qt.Window | Qt.FramelessWindowHint
                    }
                }
                app.uHtml=result
                //uLogView.showLog(result)
            });
        }
    }
    Timer{
        id: tInit
        running: false
        repeat: false
        interval: 3000
        //onRunningChanged: {}
        onTriggered: {
            running=false
            wvtav.runJavaScript('document.getElementById(\'selectlang_lbm\').value="'+app.arrayLanguages[0]+'";', function(resultSelectLanguage) {
                wvtav.runJavaScript('document.getElementsByTagName("TEXTAREA")[3].value="'+app.initString+'"', function(result) {
                    //console.log('R001: '+result)
                    wvtav.runJavaScript('document.getElementsByTagName("TEXTAREA")[3].value', function(result2) {
                        // console.log('R002: '+result2)
                        if(result2!==app.initString){
                            restart()
                        }else{
                            wvtav.runJavaScript('document.getElementsByTagName("BUTTON")[2].click()', function(result3) {
                                //console.log('Resultado 4: '+result3)
                                tInit2.start()
                            });
                        }
                    });
                });
            });
            console.log('Iniciando....')
        }
    }
    Timer{
        id: tInit2
        running: false
        repeat: true
        interval: 2000
        onTriggered: {
            wvtav.runJavaScript('document.getElementById(\'audioElement1\').play()', function(result) {
                //console.log('RP: '+result)
                if(result){
                    //console.log('RP1: '+result)
                }else{
                    //console.log('RP2: '+result)
                }
            });
        }
    }
    Timer{
        id: tInit3
        running: tInit2.running
        repeat: true
        interval: 100
        onTriggered: {
            running=false
            wvtav.runJavaScript('function aip(){var audio100=document.getElementById(\'audioElement1\');return audio100.duration > 0 && !audio100.paused}; aip();', function(result) {
                //console.log('RP: '+result)
                if(result===true){
                    tInit2.stop()
                    xStart.color='red'
                    btn1.enabled=true
                    btn1.t='\uf04d'
                    return
                }
                running=true
            });
        }
    }
    Timer{
        id: tGetMp3Duration
        running: true
        repeat: true
        interval: 250
        onTriggered: {
            wvtav.focus=true
            running=false
            wvtav.runJavaScript('document.getElementById(\'audioElement1\').duration', function(result) {
                //wvtav.runJavaScript('document.getElementsByTagName("AUDIO")[1].duration', function(result) {

                if(result===undefined){
                    console.log('NO Resultado Duration: '+result)
                    restart()
                    //running=true
                    return
                }
                console.log('Resultado Duration: '+result)
                /*if(!app.iniciado&&app.vInit<10){
                    wvtav.runJavaScript('document.getElementsByTagName("AUDIO")[1].play()', function(result4) {
                        //wvtav.runJavaScript('document.getElementById(\'audioElement1\').play()', function(result4) {
                        //console.log('Resultado Play: '+result4)
                        if(app.vInit<=10){
                            app.vInit++
                        }else{
                            app.iniciado=true
                        }
                        running=true
                    });
                }else{
                    running=true
                }*/
                if(app.uMp3Duration===result){
                    return
                }
                //tInit2.stop()
                app.uMp3Duration=result
                //lm.get(0).dur=result*1000
                //console.log('Duration: '+result)

            });
        }
    }

    ManSqliteData{
        id: manSqliteData

    }
    Shortcut{
        sequence: 'Esc'
        onActivated: {
            //            if(uLogView.visible){
            //                uLogView.visible=false
            //                return
            //            }
            Qt.quit()
        }
    }
    Shortcut{
        sequence: 'Ctrl+a'
        onActivated: {
            //let element = document.getElementById(id)
            wvtav.runJavaScript('document.getElementsByTagName("AUDIO")[1].play()', function(result4) {
                console.log('Resultado Play: '+result4)
            });
            /*wvtav.runJavaScript('document.getElementById(\'tab3\').checked=true;', function(result) {
                console.log('Resultado RADIO: '+result)
                wvtav.runJavaScript('document.getElementsByTagName("LABEL")[2].click();', function(result2) {
                    console.log('Resultado Label: '+result2)

                });
            });*/
            /*
            //Funcionó speak para html.txt
            let text='dato ingresado!'
            console.log("Convirtiendo a MP3: "+text)
            let nText=(''+text).replace(/\n/g, '')
            console.log("Convirtiendo a MP3: "+text)
            wvtav.runJavaScript('document.getElementsByTagName("TEXTAREA").length', function(result) {
                console.log('Resultado 1: '+result)
                wvtav.runJavaScript('document.getElementsByTagName("TEXTAREA")[3].value="'+nText+'"', function(result2) {
                    console.log('Resultado 2: '+result2)
                    wvtav.runJavaScript('document.getElementsByTagName("BUTTON").length', function(result3) {
                        console.log('Resultado 3: '+result3)
                        wvtav.runJavaScript('document.getElementsByTagName("BUTTON")[2].click()', function(result4) {
                            console.log('Resultado 4: '+result4)
                        });
                    });
                });
            });*/

        }
    }
    Component.onCompleted: {
        unik.setTtsVolume(100)
        if(Qt.platform.os==='linux'){
            let m0=(''+ttsLocales).split(',')
            let index=0
            for(var i=0;i<m0.length;i++){
                console.log('Language: '+m0[i])
                if((''+m0[i]).indexOf('Spanish (Spain)')>=0){
                    index=i
                    break
                }
            }
            unik.ttsLanguageSelected(index)
            //unik.speak('Idioma Español seleccionado.')
        }
        let user=''
        let launch=false
        let args = Qt.application.arguments
        //uLogView.showLog(args)
        for(var i=0;i<args.length;i++){
            //uLogView.showLog(args[i])
            if(args[i].indexOf('-twitchUser=')>=0){
                let d0=args[i].split('-twitchUser=')
                //uLogView.showLog(d0[1])
                user=d0[1]
                app.user=user
                app.url='https://www.twitch.tv/embed/'+user+'/chat?parent=nextsigner.github.io'
                console.log('app.url: '+app.url)
            }
            if(args[i].indexOf('-launch')>=0){
                launch=true
            }
        }
        if(Qt.platform.os==='android'){
            user='nextsigner'
            //app.url='https://m.twitch.tv/login'
            //app.url='https://m.twitch.tv/login?client_id=nextsigner&desktop-redirect=true'
            app.url='https://www.twitch.tv/login?no-mobile-redirect=true'
            //app.url='https://www.twitch.tv/embed/nextsigner/chat?parent=nextsigner.github.io'
        }
        if(user===''){
            app.visible=true
            xSetMod.visible=true
            return
        }
        manSqliteData.setUser(user)
        //manSqliteData.setVoice(user, 2)
        wv.url=app.url
        if(launch){
            Qt.openUrlExternally(app.url)
        }

        //Depurando
        app.visible=true
        //getViewersCount()
        setHtml()
    }
    function isVM(m){
        let s1='Nightbot'
        if(m.indexOf(s1)>=0)return false;
        let s2='StreamElements'
        if(m.indexOf(s2)>=0)return false;
        let s3='[Juego dice]'
        if(m.indexOf(s3)>=0)return false;
        let s4='Podes enviar audios por whatsapp'
        if(m.indexOf(s4)>=0)return false;
        return true
    }
    function setDesktopIcon(params){
        let path=pws+"/"+app.moduleName
        if(Qt.platform.os==='windows'){
            if(!unik.folderExist(path)){
                unik.mkdir(path)
                app.l(path)
            }
            unik.createLink(unik.getPath(1)+"/unik.exe", " "+params+" -git=https://github.com/nextsigner/"+app.moduleName+".git",  unik.getPath(7)+"/Desktop/Update-"+app.moduleName.toUpperCase()+".lnk", "Update-"+app.moduleName.toUpperCase()+"", path);
        }
    }

    function speakMp3(user, text){
        console.log("Convirtiendo a MP3: "+text)
        let indexLang=manSqliteData.getVoice(user)
        if(indexLang===-1){
            indexLang=0
            manSqliteData.setUser(user)
        }
        let nText=(''+text).replace(/\n/g, '')
        console.log("Convirtiendo a MP3: "+text)
        wvtav.runJavaScript('document.getElementById(\'selectlang_lbm\').value="'+app.arrayLanguages[indexLang]+'";', function(resultSelectLanguage) {
            wvtav.runJavaScript('document.getElementsByTagName("TEXTAREA").length', function(result) {
                console.log('Resultado 1: '+result)
                wvtav.runJavaScript('var ta=document.getElementsByTagName("TEXTAREA")[3]; ta.value="'+nText+'"; ta.autofocus=true; ta.focus();', function(result2) {
                    console.log('Resultado 2: '+result2)
                    wvtav.runJavaScript('document.getElementsByTagName("BUTTON").length', function(result3) {
                        console.log('Resultado 3: '+result3)
                        wvtav.runJavaScript('document.getElementsByTagName("BUTTON")[2].click()', function(result4) {
                            console.log('Resultado 4: '+result4)
                        });
                    });
                });
            });
        });
    }
    function play(){
        wvtav.runJavaScript('document.getElementsByTagName("BUTTON")[2].click()', function(result4) {
            console.log('Resultado 4: '+result4)
        });
    }
    function setHtml(){
        let c=unik.getFile('html.txt')
        wvtav.loadHtml(c)
    }
}



/*ApplicationWindow {
    id: app
    visible: Qt.platform.os!=='android'?false:true
    visibility: Qt.platform.os!=='android'?'Windowed':'Maximized'
    width: Screen.width*0.8//Qt.platform.os!=='android'?300:Screen.width
    height: Screen.desktopAvailableHeight
    flags: Qt.platform.os!=='android'?Qt.Window | Qt.FramelessWindowHint:app.flags// | Qt.WindowStaysOnTopHint
    x:Qt.platform.os!=='android'?Screen.width-width:0
    color: Qt.platform.os!=='android'?'transparent':'red'
    property string moduleName: 'tcv'
    property int fs: app.width*0.035
    property color c1: 'black'
    property color c2: 'white'
    property color c3: 'gray'
    property color c4: 'red'
    property string uHtml: ''
    property bool voiceEnabled: true
    property string user: ''
    property string url: ''
    property string moderador:''
    property var mods: ['ricardo__martin', 'nextsigner', 'lucssagg']
    property var ue: ['ricardo__martin', 'lucssagg', 'nextsigner']
    property bool allSpeak: true
    FontLoader{name: "FontAwesome"; source: "qrc:/fontawesome-webfont.ttf"}
    USettings{
        id: unikSettings
        url:app.moduleName+'.cfg'
        onCurrentNumColorChanged: setVars()
        Component.onCompleted: {
            if(Qt.platform.os!=='android'){
                setVars()
            }
        }
        function setVars(){
            let m0=defaultColors.split('|')
            let ct=m0[currentNumColor].split('-')
            app.c1=ct[0]
            app.c2=ct[1]
            app.c3=ct[2]
            app.c4=ct[3]
        }
    }
    onClosing: {
        if(Qt.platform.os==='android'){
            if(wv.visible){
                wv.visible=false
                close.accepted = false
            }else{
                close.accepted = true
            }
        }
    }
    Item{
        id: xApp
        anchors.fill: parent
        Row{
            //Url texto a voz http://texttospeechrobot.com/tts/es/texto-a-voz/
            Rectangle{
                width: app.width*0.5
                height: app.height
                color: '#ff8833'
                WebView{
                    id: wvtav
                    url: 'http://texttospeechrobot.com/tts/es/texto-a-voz/'
                    anchors.fill: parent
                }
            }
            Rectangle{
                width: app.width*0.5
                height: app.height
                color: '#ff8833'
                WebView{
                    id: wv
                    anchors.fill: parent
                    visible: false
                    onUrlChanged: {
                        if((''+url)==='https://www.twitch.tv/?no-reload=true'){
                            let c='<iframe frameborder="0"
        scrolling="no"
        id="chat_embed"
        src="https://www.twitch.tv/embed/nextsigner/chat?parent=nextsigner.github.io"
        height="500"
        width="350">
</iframe>'
                            //wv.loadHtml(c)
                            //app.url='http://twitch.tv/nextsigner/embed'
                            //app.url='https://www.twitch.tv/login?no-mobile-redirect=true'
                            wv.url=app.url
                            wv.visible=true
                        }
                    }
                    onLoadProgressChanged: {
                        if(loadProgress===100){
                            wv.visible=true
                            tCheck.start()
                        }
                    }
                }
            }
        }
        XSetMod{
            id: xSetMod
            width: xApp.width
            anchors.horizontalCenter: parent.horizontalCenter
        }
        //ULogView{id: uLogView}
        //UWarnings{id: uWarnings}


        ListView{
            id: lv
            width: xApp.width*0.5
            height: app.fs*10
            anchors.bottom: parent.bottom
            model: lm
            delegate: del
            ListModel{
                id: lm
                function addMsg(m){
                    return{
                        msg:m,
                        dur: -1
                    }
                }
            }
            Component{
                id: del
                Rectangle{
                    id: xMsg
                    property int ms: 0
                    width: lv.width
                    height: txtMsg.contentHeight+10
                    border.width: 2
                    border.color: 'red'
                    UText {
                        id: txtMsg
                        text: msg
                        color: 'black'
                        font.pixelSize: app.fs*0.25
                        width: parent.width-app.fs
                        wrapMode: Text.WordWrap
                        anchors.centerIn: parent
                    }
                    Timer{
                        id: timerThisFinished
                        running: false
                        repeat: false
                        interval: 99999999
                        onTriggered: {
                            lm.remove(0)
                        }
                    }
                    Timer{
                        id: timerThis
                        running: index===0
                        repeat: true
                        interval: 10
                        onTriggered: {
                            xMsg.ms+=10
                            if(dur>0){
                                running=false
                                timerThisFinished.interval=dur-xMsg.ms
                                timerThisFinished.start()
                            }
                        }
                    }
                    Component.onCompleted: speakMp3(msg)
                }
            }
        }
    }
    //    UText{
    //        text: 'Url: '+wv.url
    //        width: xApp.width
    //        color: 'red'
    //        font.pixelSize: app.fs*4
    //        wrapMode: Text.WrapAnywhere
    //    }
    property string uMsg: ''
    property real uMp3Duration: 0.0

    Timer{
        id: tGetMp3Duration
        running: false
        repeat: false
        interval: 250
        onTriggered: {
            running=false
            wvtav.runJavaScript('document.getElementById(\'audioElement1\').duration', function(result) {
                if(result===undefined){
                    running=true
                    return
                }
                if(app.uMp3Duration===result){
                    return
                }
                app.uMp3Duration=result
                lm.get(0).dur=result*1000
                console.log('Duration: '+result)
                running=true
            });
        }
    }
    Timer{
        id:tCheck
        running: false
        repeat: true
        interval: 1000
        onTriggered: {
            wv.runJavaScript('document.getElementById("root").innerText', function(result) {
                if(result!==app.uHtml){
                    let d0=result//.replace(/\n/g, 'XXXXX')
                    app.uHtml=result
                    if(d0.indexOf(':')>0){
                        let d1=d0.split(':')
                        let d2=d1[d1.length-1]
                        let d3=d2.split('Enviar')
                        let mensaje = d3[0]

                        let d5=d0.split('\n\n')
                        let d6=d5[d5.length-3]
                        let d7=d0.split(':')
                        let d8=d7[d7.length-2].split('\n')
                        let usuario=''+d8[d8.length-1].replace('chat\n', '')
                        let msg=usuario+' dice '+mensaje
                        if(msg===app.uMsg){
                            return
                        }
                        app.uMsg=msg

                        let user=''+usuario.replace(/\n/g, '' )

                        if(isVM(msg)&&(''+msg).indexOf('chat.whatsapp.com')<0&&(''+mensaje).indexOf('!')!==1){
                            //console.log('u['+usuario+'] '+app.ue.toString())
                            if(app.ue.indexOf(usuario)>=0 || app.allSpeak){
                                //console.log(msg)
                                if(user.indexOf('itomyy17')>=0){
                                    unik.speak(msg)
                                }else{
                                    lm.append(lm.addMsg(msg))
                                    //tGetMp3Duration.restart()
                                }
                            }
                        }
                        if(isVM(msg)&&(''+msg).indexOf('chat.whatsapp.com')<0&&(''+mensaje).indexOf('!')===1&&app.mods.indexOf(user)>=0){
                            let m0=mensaje.split('!')
                            let m1=m0[1].split(' ')
                            let paramUser=m1[1].replace(/\n/g, '' )
                            //Set all speak
                            if(m1[0].length>1&&m1[0]==='alls'){
                                app.allSpeak=!app.allSpeak
                                if(app.allSpeak){
                                    unik.speak("Ahora se oirán todos los mensajes del chat.")
                                }else{
                                    unik.speak("Ahora solo algunos usuarios del chat se oirán.")
                                }
                            }
                            //Add user speak
                            if(m1[0].length>1&&m1[0]==='as'){
                                if(app.ue.indexOf(paramUser)<0){
                                    unik.speak("Se agrega para hablar a "+paramUser)
                                    app.ue.push(paramUser)
                                }else{
                                    unik.speak(paramUser+' ya estaba agregado.')
                                }
                            }
                            //Remove user speak
                            if(m1[0].length>1&&m1[0]==='rs'){
                                if(app.ue.indexOf(paramUser)>=0){
                                    unik.speak("Se quita para hablar a "+paramUser)
                                    app.ue.pop(paramUser)
                                }else{
                                    unik.speak(paramUser+' no estaba agregado.')
                                }
                            }
                            //Set volume speak
                            if(m1[0].length>1&&m1[0]==='sv'){
                                if(app.ue.indexOf(paramUser)>=0){
                                    unik.setTtsVolume(parseInt(paramUser))
                                }else{
                                    unik.speak('El comando no se ha aplicado. Falta el valor del volumen.')
                                }
                            }
                            app.uHtml=result
                            return
                        }
                        if(msg.indexOf(''+app.user)>=0 &&msg.indexOf('show')>=0){
                            app.visible=true
                        }
                        if(msg.indexOf(''+app.user)>=0 &&msg.indexOf('hide')>=0){
                            app.visible=false
                        }
                        if(msg.indexOf(''+app.user)>=0 &&msg.indexOf('launch')>=0){
                            Qt.openUrlExternally(app.url)
                        }
                        app.flags = Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
                        app.flags = Qt.Window | Qt.FramelessWindowHint
                    }
                }
                app.uHtml=result
                //uLogView.showLog(result)
            });
        }
    }
    Shortcut{
        sequence: 'Esc'
        onActivated: {
            Qt.quit()
        }
    }
    Shortcut{
        sequence: 'Ctrl+a'
        onActivated: {


        }
        Component.onCompleted: {
            unik.setTtsVolume(100)
            if(Qt.platform.os==='linux'){
                let m0=(''+ttsLocales).split(',')
                let index=0
                for(var i=0;i<m0.length;i++){
                    console.log('Language: '+m0[i])
                    if((''+m0[i]).indexOf('Spanish (Spain)')>=0){
                        index=i
                        break
                    }
                }
                unik.ttsLanguageSelected(index)
                //unik.speak('Idioma Español seleccionado.')
            }
            let user=''
            let launch=false
            let args = Qt.application.arguments
            //uLogView.showLog(args)
            for(var i=0;i<args.length;i++){
                //uLogView.showLog(args[i])
                if(args[i].indexOf('-twitchUser=')>=0){
                    let d0=args[i].split('-twitchUser=')
                    //uLogView.showLog(d0[1])
                    user=d0[1]
                    app.user=user
                    app.url='https://www.twitch.tv/embed/'+user+'/chat?parent=nextsigner.github.io'
                    console.log('app.url: '+app.url)
                }
                if(args[i].indexOf('-launch')>=0){
                    launch=true
                }
            }
            if(Qt.platform.os==='android'){
                user='nextsigner'
                //app.url='https://m.twitch.tv/login'
                //app.url='https://m.twitch.tv/login?client_id=nextsigner&desktop-redirect=true'
                app.url='https://www.twitch.tv/login?no-mobile-redirect=true'
                //app.url='https://www.twitch.tv/embed/nextsigner/chat?parent=nextsigner.github.io'
            }
            if(user===''){
                app.visible=true
                xSetMod.visible=true
                return
            }
            wv.url=app.url
            if(launch){
                Qt.openUrlExternally(app.url)
            }

            //Depurando
            app.visible=true
            //getViewersCount()
        }
    }
    function isVM(m){
        let s1='Nightbot'
        if(m.indexOf(s1)>=0)return false;
        let s2='StreamElements'
        if(m.indexOf(s2)>=0)return false;
        let s3='[Juego dice]'
        if(m.indexOf(s3)>=0)return false;
        let s4='Podes enviar audios por whatsapp'
        if(m.indexOf(s4)>=0)return false;
        return true
    }
    function setDesktopIcon(params){
        let path=pws+"/"+app.moduleName
        if(Qt.platform.os==='windows'){
            if(!unik.folderExist(path)){
                unik.mkdir(path)
                app.l(path)
            }
            unik.createLink(unik.getPath(1)+"/unik.exe", " "+params+" -git=https://github.com/nextsigner/"+app.moduleName+".git",  unik.getPath(7)+"/Desktop/Update-"+app.moduleName.toUpperCase()+".lnk", "Update-"+app.moduleName.toUpperCase()+"", path);
        }
    }
    function speakMp3(text){
        console.log("Convirtiendo a MP3: "+text)
        let nText=(''+text).replace(/\n/g, '')
        console.log("Convirtiendo a MP3: "+text)
        wvtav.runJavaScript('document.getElementsByTagName("TEXTAREA").length', function(result) {
            console.log('Resultado 1: '+result)
            wvtav.runJavaScript('document.getElementsByTagName("TEXTAREA")[2].value="'+nText+'"', function(result2) {
                console.log('Resultado 2: '+result2)
                wvtav.runJavaScript('document.getElementsByTagName("BUTTON").length', function(result3) {
                    console.log('Resultado 3: '+result3)
                    wvtav.runJavaScript('document.getElementsByTagName("BUTTON")[1].click()', function(result4) {
                        //console.log('Resultado 4: '+result4)
                    });
                });
            });
        });
    }
//    function getUMp3Duration(){
//        console.log("get mp3 duration... ")
//        wvtav.runJavaScript('document.getElementById(\'audioElement1\').duration', function(result) {
//            if(result===undefined){
//                tGetMp3Duration.restart()
//                return
//            }
//            console.log('Duration: '+result)
//        });
//    }
}*/

