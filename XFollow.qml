import QtQuick 2.7
import QtQuick.Controls 2.0
//import QtWebEngine 1.5
import QtWebView 1.1
import Qt.labs.settings 1.1


Item {
    id: r
    width: app.fs*10
    height: width*2
    signal newFollowEvent(string user)
    signal newDonationEvent(string user, string donation)
    property string moduleName: 'followEvents'
    property alias urlWidget: w.url
    Settings{
        id: sr
        fileName: r.moduleName
        property string uHtml: ''
    }

    WebView{
        id: w
        anchors.fill: parent
        opacity: 0.0
        onLoadProgressChanged:{
            if(loadProgress===100){
                t.start()
            }
        }
    }
    Timer{
        id:t
        running: false
        repeat: true
        interval: 1000
        onTriggered: {
            //running=false
            w.runJavaScript('function ret(){var aaa=document.getElementsByTagName("body")[0].innerHTML; return aaa;} ret()', function(result) {
                if(result&&result!==sr.uHtml){
                    //unik.speak('Nuevo Evento')
                    //console.log('RRRR1: '+result)
                    w.runJavaScript('function ret(){var aaa=document.getElementsByTagName("li")[0].innerText; return aaa;} ret()', function(result2) {
                        let s=''+result2
                        let m0
                        if(s.indexOf('FOLLOW')>=0){
                            m0=result2.replace(/FOLLOW/g, '').replace(/\n/g, '')
                            r.newFollowEvent(m0)
                        }
                        if(s.indexOf('$')>=0){
                            m0=result2//.replace(/\n/g, '---')
                            let m1=m0.split('\n')
                            r.newDonationEvent(m1[1], m1[0])
                        }
                        //unik.speak('Nuevo Evento '+m0)
                        //console.log('RRRR3: '+m0)
                    });
                }
                sr.uHtml=result
                running=true
            });
            /*wv.runJavaScript('document.getElementsByClassName("chat-line__message").length', function(result0) {
                //console.log('V'+tCheck.v+': ----------------------------------->'+result0)
                wv.runJavaScript('function ret(){var aaa=document.getElementsByClassName("chat-line__message")['+parseInt(result0 -1)+'].innerText; return aaa;} ret()', function(result) {
                    if(result!==sr.uHtml){

                    }
                    sr.uHtml=result
                    running=true
                });
            });*/

        }
    }
}
