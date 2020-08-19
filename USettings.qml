import QtQuick 2.0
Item{
    id: r
    property bool loaded: false
    property string url: 'conf-unik'
    property string lang: 'es'
    property int currentNumColor: 9
    property string defaultColors: "black-white-#666-#aaa|black-white-#aaa-#666|white-black-#aaa-#666|white-black-#666-#aaa|white-#006edb-#00b7b7-black|#006edb-white-#00b7b7-black|#006edb-white-black-#00b7b7|#00b7b7-white-#006edb-black|#00b7b7-black-#006edb-white|black-#00b7b7-#006edb-white|black-#00b7b7-white-#006edb|#1fbc05-black-green-white|#1fbc05-black-white-green|black-#1fbc05-white-green|black-#1fbc05-green-white|black-red-#ff6666-white|black-red-white-#ff6666|black-#ff6666-red-white|black-#ff6666-white-red|red-black-#ff6666-white|red-black-white-#ff6666|#ff2200-#ff8833-black-white|#ff2200-#ff8833-white-black|#930000-#ff9224-white-black|#ff9224-#930000-white-black|#ff9224-white-#930000-black|#930000-white-#ff9224-black"
    property bool sound: false
    property bool showBg: false
    property int numberRun: 0
    property real zoom: 1.0
    property real padding: 1.0
    property int radius: 6
    property int borderWidth: 4
    property string fontFamily: 'Arial'
    property string jsonCode: '{"cfg":{"zoom":0.8,"padding":0.25,"radius":6,"borderWidth":2,"fontFamily":"Arial", "sound" : false, "showBg": false, "lang" : "es", "currentNumColor": 9, "defaultColors":"black-white-#666-#aaa|black-white-#aaa-#666|white-black-#aaa-#666|white-black-#666-#aaa|white-#006edb-#00b7b7-black|#006edb-white-#00b7b7-black|#006edb-white-black-#00b7b7|#00b7b7-white-#006edb-black|#00b7b7-black-#006edb-white|black-#00b7b7-#006edb-white|black-#00b7b7-white-#006edb|#1fbc05-black-green-white|#1fbc05-black-white-green|black-#1fbc05-white-green|black-#1fbc05-green-white|black-red-#ff6666-white|black-red-white-#ff6666|black-#ff6666-red-white|black-#ff6666-white-red|red-black-#ff6666-white|red-black-white-#ff6666|#ff2200-#ff8833-black-white|#ff2200-#ff8833-white-black|#930000-#ff9224-white-black|#ff9224-#930000-white-black|#ff9224-white-#930000-black|#930000-white-#ff9224-black" }}'
    signal dataChanged
    onCurrentNumColorChanged: {
        if(loaded){
            setCfgFile()
        }
    }
    onDefaultColorsChanged: {
        if(loaded){
            setCfgFile()
        }
    }
    onSoundChanged: {
        if(loaded){
            setCfgFile()
        }
        if(sound){
            let m=r.lang==='es'?'Audio activado.':'Audio enabled.'
            unik.speak(m)
        }
    }
    onShowBgChanged: {
        if(loaded){
            setCfgFile()
        }
    }
    onZoomChanged: {
        if(loaded){
            setCfgFile()
        }
    }
    onPaddingChanged: {
        if(loaded){
            setCfgFile()
        }
    }
    onRadiusChanged: {
        if(loaded){
            setCfgFile()
        }
    }
    onBorderWidthChanged: {
        if(loaded){
            setCfgFile()
        }
    }
    onFontFamilyChanged: {
        if(loaded){
            setCfgFile()
        }
    }

    Component.onCompleted: {
        console.log('Archivo Unik Settings: '+pws+'/conf-'+r.url)
        if(!unik.fileExist(pws+'/conf-'+r.url)){
            console.log('Archivo Unik Settings inexistente.')
            setCfgFile()
        }else{
            console.log('Archivo Unik Settings existente.')
            getCfgFile()
        }
        numberRun++
        r.loaded=true
    }
    function getCfgFile(){
        //console.log('getCfgFile()...')
        var unikCfgFile=pws+'/conf-'+r.url
        //console.log('unikCfgFile: '+unikCfgFile)
        var unikCfgFileData=unik.getFile(unikCfgFile)
        //console.log('unikCfgFileData: '+unikCfgFileData)
        var json
        if(unikCfgFileData!=='error') {
            try {
                json = JSON.parse(unikCfgFileData);
            } catch(e) {
                console.log('Error when loading unik-cfg.json file: '+e)
            }
            if(json){
                r.loaded=false
                r.zoom = json['cfg'].zoom
                r.padding = json['cfg'].padding
                r.radius = json['cfg'].radius
                r.borderWidth = json['cfg'].borderWidth
                r.fontFamily = json['cfg'].fontFamily
                r.lang = json['cfg'].lang
                r.currentNumColor = json['cfg'].currentNumColor
                r.showBg = json['cfg'].showBg
                r.sound = json['cfg'].sound
                r.defaultColors = json['cfg'].defaultColors
            }
            r.loaded=true
        }else{
            unik.setFile(unikCfgFile, r.jsonCode)
            getCfgFile()
        }
    }

    function setCfgFile(){
        var unikCfgFile=pws+'/conf-'+r.url
        //console.log('unikCfgFile: '+unikCfgFile)
        var unikCfgFileData=unik.getFile(unikCfgFile)
        //console.log('1: url: '+r.url+' unikCfgFileData: '+unikCfgFileData)
        var json
        if(unikCfgFileData!=='error') {
            try {
                json = JSON.parse(unikCfgFileData);
            } catch(e) {
                console.log('Error when loading unik-cfg.json file: '+e)
            }
            if(json){
                json['cfg']={
                    zoom : r.zoom,
                    padding : r.padding,
                    radius: r.radius,
                    borderWidth: r.borderWidth,
                    fontFamily: r.fontFamily,
                    lang: r.lang,
                    currentNumColor: r.currentNumColor,
                    showBg: r.showBg,
                    sound: r.sound,
                    defaultColors: r.defaultColors
                }
                //console.log('Settings cfg file '+unikCfgFile+' \n'+JSON.stringify(json))
                unik.setFile(unikCfgFile, JSON.stringify(json))
                getCfgFile()
                //unik.setFile('/home/nextsigner/aaa.json', JSON.stringify(json))
            }
        }else{
            unik.setFile(unikCfgFile, r.jsonCode)
            getCfgFile()
            setCfgFile()
        }
        //if(r.loaded){
            r.dataChanged()
        //}
    }
}
