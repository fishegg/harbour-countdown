.import QtQuick.LocalStorage 2.0 as SQL

function getDatabase() {
    return SQL.LocalStorage.openDatabaseSync("days", "1.0", "daysinfo", 25000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS day(dayid INTEGER, name TEXT, datetext TEXT, year INTEGER, month INTEGER, day INTEGER, favorite INTEGER);');
                });
    console.log("initialized");

    if(checkColumnExists("datetext") == "false") {
        console.log("datetext==false");
        updateTableDatetext();
    }
    if(checkColumnExists("favorite") == "false") {
        console.log("favorite==false");
        updateTableFavorite();
    }
}

function updateTableDatetext() {
    console.log("updatetabledatetext");
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('ALTER TABLE day ADD column datetext TEXT;');
    });
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE day set datetext = " ";');
    });
}

function updateTableFavorite() {
    console.log("updatetablefavorite");
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('ALTER TABLE day ADD column favorite INTEGER DEFAULT 0;');
    });
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE day set favorite = 0 ;');
    });
}

function checkColumnExists(columnName){
    var flag = "true";
    var sql = 'select * from sqlite_master where name = "day" and sql like "%'+columnName+'%";';
    console.log("SQL:"+sql)
    try{
        var db = getDatabase();
        db.transaction(function(tx){
          var rs =  tx.executeSql(sql);
            if(rs.rows.length > 0) {
               flag = "true";
            }else {
               flag = "false";
            }
        });
    }catch(e){
        console.log("exception:"+e.message)
    }
    return flag;
}

function createDays(dayid,name,datetext,year,month,day,favorite) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx){
        var rs = tx.executeSql('INSERT INTO day(dayid,name,datetext,year,month,day,favorite) VALUES(?, ?, ?, ?, ?, ?, ?);', [dayid, name, datetext, year, month, day, favorite]);
        if (rs.rowsAffected > 0) {
            res = "yes";
        } else {
            res = "no";
        }
    });
    return res;
}

function editDays(dayid,newTitle,year,month,day,datetext,favorite) {

    var db = getDatabase();
    var flag = false
    db.transaction(function(tx){
        var rs = tx.executeSql('UPDATE day set name=?, year=?, month=?, day=?, datetext=?, favorite=? WHERE dayid=?;',[newTitle,year,month,day,datetext,favorite,dayid]);
        if(rs.rowsAffected >0 ){
            flag = true;
        }else{
            flag = false;
        }
    });
    return flag;
}

function updateFavorite(dayid,favorite) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx){
        var rs = tx.executeSql('UPDATE day set favorite=? WHERE dayid=?;',[favorite,dayid]);
        if (rs.rowsAffected > 0) {
            res = "yes";
        } else {
            res = "no";
        }
        });
    return res;
}

function deleteDays(dayid) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx){
        var rs = tx.executeSql('DELETE FROM day WHERE dayid=?;',[dayid]);
        if (rs.rowsAffected > 0) {
            res = "yes";
        } else {
            res = "no";
        }
        });
    return res;
}

function getDays(status) {
    var sql = 'SELECT * FROM day;';
    if( status === "favorite" ) {
        sql = 'SELECT * FROM day WHERE favorite = 1;';
    }

    var db = getDatabase()
    listModel.clear()
    db.transaction(function(tx) {
        var rs = tx.executeSql(sql);
        if ( rs.rows.length > 0 ) {
            for ( var i = 0; i < rs.rows.length; i++){
                listModel.append({
                                     "dayid": rs.rows.item(i).dayid,
                                     "name": rs.rows.item(i).name,
                                     "year": rs.rows.item(i).year,
                                     "month": rs.rows.item(i).month,
                                     "day": rs.rows.item(i).day,
                                     "datetext": rs.rows.item(i).datetext,
                                     "favorite": rs.rows.item(i).favorite
                                 }
                                     )
            }
        }
    })
}
