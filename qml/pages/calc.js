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
function nextZeroPoint() {
    var date = new Date();
    var newday = new Date();
    newday.setHours(0);
    newday.setMinutes(0);
    newday.setSeconds(0);
    newday.setMilliseconds(0)
    return newday-date+86400000
}
