.import harbour.countdown.setting 1.0 as Settings

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

function get_date(year,month,day) {
    var date = new Date()
    if(arguments.length > 0) {
        month = month - 1
        date = new Date(year,month,day)
    }
    return date.toLocaleDateString()
}

function get_year() {
    var date = new Date()
    return date.getFullYear()
}

function get_month() {
    var date = new Date()
    return date.getMonth() + 1
}

function get_day() {
    var date = new Date()
    return date.getDate()
}

function refresh_seperator() {
    seperator_type = settings.get_seperator_type()
    switch(seperator_type) {
    case Settings.Period: seperator = "."
        break
    case Settings.Slash: seperator = "/"
        break
    case Settings.Hhyphen: seperator = "-"
        break
    default: seperator = "."
    }
}
