import QtQuick 2.0

Item {
    id: r
    property string url: ''
    signal usuarioNuevo(string user)
    function getVoice(user){
        //unik.sqliteInit(r.url)
        let sql='select * from users where nickname=\''+user+'\''
        let rows=unik.getSqlData(sql)
        if(rows.length>=1){
            return parseInt(rows[0].col[2])
        }
        return -1
    }
    function setVoice(user, voice){
        //unik.sqliteInit(r.url)
        let sql='update users set voice='+voice+' where nickname=\''+user+'\''
        unik.sqlQuery(sql)
    }
    function setUser(user){
        //unik.sqliteInit(r.url)
        let sql='select * from users where nickname=\''+user+'\''
        let rows=unik.getSqlData(sql)
        if(rows.length===0){
            let sql='insert into users (nickname, voice)values(\''+user+'\', 0)'
            unik.sqlQuery(sql)
        }
    }

    //Mansajes
    function setMsg(user, msg){
        //unik.sqliteInit(r.url)
        let d = new Date(Date.now())
        let sql='insert into msgs (nickname, msg, ms)values(\''+user+'\', \''+msg+'\', '+d.getTime()+')'
        unik.sqlQuery(sql)
    }

    //Rangos
    function setRango(user, rango){
        //unik.sqliteInit(r.url)
        let sql='select * from rangos where nickname=\''+user+'\''
        let rows=unik.getSqlData(sql)
        //console.log('Rango: '+rows.length)
        if(rows.length>=1){
            let sql='update rangos set rango='+rango+' where nickname=\''+user+'\''
            unik.sqlQuery(sql)
        }else{
            let sql='insert into rangos (nickname, rango)values(\''+user+'\', '+rango+')'
            unik.sqlQuery(sql)
        }
    }
    function getRango(user){
        //unik.sqliteInit(r.url)
        let sql='select rango from rangos where nickname=\''+user+'\''
        let rows=unik.getSqlData(sql)
        if(rows.length>=1){
            return parseInt(rows[0].col[0])
        }
        usuarioNuevo(user)
        setRango(user, 100)
        return 100
    }

    //Codes
    function getCode(code, rango){
        ////unik.sqliteInit(r.url)
        let sql='select code from codes where codeid='+code+' and rp>'+rango+';'
        let rows=unik.getSqlData(sql)
        if(rows.length>=1){
            return rows[0].col[0]
        }
        return ''
    }
    Component.onCompleted: {
        let folder=pws+'/'+app.moduleName
        if(!unik.folderExist(pws)){
            unik.mkdir(pws)
        }
        if(!unik.folderExist(folder)){
            unik.mkdir(folder)
        }
        r.url=folder+'/data.sqlite'
        unik.sqliteInit(r.url)
        let sql='CREATE TABLE IF NOT EXISTS users'
            +'('
            +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            +'nickname TEXT NOT NULL,'
            +'voice NUMERIC NOT NULL'
            +')'
        unik.sqlQuery(sql)
        sql='CREATE TABLE IF NOT EXISTS msgs'
                +'('
                +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
                +'nickname TEXT NOT NULL,'
                +'msg TEXT NOT NULL,'
                +'ms NUMERIC NOT NULL'
                +')'
        unik.sqlQuery(sql)
        sql='CREATE TABLE IF NOT EXISTS rangos'
                +'('
                +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
                +'nickname TEXT NOT NULL,'
                +'rango NUMERIC NOT NULL'
                +')'
        unik.sqlQuery(sql)
        sql='CREATE TABLE IF NOT EXISTS codes'
                +'('
                +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
                +'codeid NUMERIC NOT NULL,'
                +'author TEXT NOT NULL,'
                +'code TEXT NOT NULL,'
                +'rp NUMERIC NOT NULL,'
                +'ms NUMERIC NOT NULL'
                +')'
        unik.sqlQuery(sql)
    }
}
