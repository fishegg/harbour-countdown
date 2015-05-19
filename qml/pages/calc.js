function daysBetween(endyear ,endmonth, endday) {
    var date = new Date();
    var currentyear = date.getFullYear()
    var currentmonth = date.getMonth()
    var currentday = date.getDate()
    var currentdate = new Date(currentyear,currentmonth,currentday)
    var enddate = new Date(endyear,endmonth-1,endday);
    var daysbetween = parseInt((enddate-currentdate)/1000/60/60/24);
    return daysbetween;
}
