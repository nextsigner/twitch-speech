import QtQuick 2.0

Item {
    function getVoice(user){
        unik.sqliteInit('users.sqlite')
        let sql='select * from users where nickname=\''+user+'\''
        let rows=unik.getSqlData(sql)
        if(rows.length>=1){
            return parseInt(rows[0].col[2])
        }
        return -1
    }
    function setVoice(user, voice){
        unik.sqliteInit('users.sqlite')
        let sql='update users set voice='+voice+' where nickname=\''+user+'\''
        unik.sqlQuery(sql)
    }
    function setUser(user){
        unik.sqliteInit('users.sqlite')
        let sql='select * from users where nickname=\''+user+'\''
        let rows=unik.getSqlData(sql)
        if(rows.length===0){
            let sql='insert into users (nickname, voice)values(\''+user+'\', 0)'
            unik.sqlQuery(sql)
        }
    }

    Component.onCompleted: {
        unik.sqliteInit('users.sqlite')
        let sql='CREATE TABLE IF NOT EXISTS users'
            +'('
            +'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            +'nickname TEXT NOT NULL,'
            +'voice NUMERIC NOT NULL'
            +')'
        unik.sqlQuery(sql)
    }
}
