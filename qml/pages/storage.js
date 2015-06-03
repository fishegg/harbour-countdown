.import QtQuick.LocalStorage 2.0 as SQL

function getDatabase() {
    return SQL.LocalStorage.openDatabaseSync("days", "1.0", "daysinfo", 25000);
}

function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    tx.executeSql('CREATE TABLE IF NOT EXISTS day(dayid INTEGER, name TEXT, datetext TEXT, year INTEGER, month INTEGER, day INTEGER);');
                });
    if(checkIfColumnExists("datetext") === "false") {
        updateTable();
    }
}

function updateTable() {
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('ALTER TABLE day ADD column datetext TEXT;');
    });
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE day set datetext = " ";');
    });
}

function checkIfColumnExists(columnName) {
    var flag = "true";
    try {
        var db = getDatabase();
        db.transaction(function(tx) {
            var rs = tx.executeSql("SELECT * FROM sqlite_master WHERE name = 'day' AND sql like '%?%'",[columnName]);
            if(rs.rows.item(0).count > 0) {
                flag = "true";
            }else {
                flag = "false";
            }
        });
    }catch(e){}
    return flag;
}

function createDays(dayid,name,datetext,year,month,day) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx){
        var rs = tx.executeSql('INSERT INTO day(dayid,name,datetext,year,month,day) VALUES(?, ?, ?, ?, ?, ?);', [dayid, name, datetext, year, month, day]);
        if (rs.rowsAffected > 0) {
            res = "yes";
        } else {
            res = "no";
        }
    });
    return res;
}

function editDays(dayid,newTitle,year,month,day,datetext) {
    var db = getDatabase();
    db.transaction(function(tx){
        tx.executeSql('UPDATE day set name=?, year=?, month=?, day=?, datetext=? WHERE dayid=?;',[newTitle,year,month,day,datetext,dayid]);
    });
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

function getDays(all) {
    var sql = 'SELECT * FROM day;';

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
                                     "datetext": rs.rows.item(i).datetext
                                 }
                                     )
            }
        }
    })
}
