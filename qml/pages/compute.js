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

function get_time() {
    var date = new Date()
    return date.toTimeString()
}

function is_next_day(day) {
    var date = new Date()
    if(date.getDate() !== day) {
        console.log("next day")
        return true
    }
    else {
        console.log("not next day")
        return false
    }
}

function get_seperator() {
    var type = settings.get_seperator_type()
    var seperator
    switch(type) {
    case Settings.Period: seperator = "."
        return seperator
    case Settings.Slash: seperator = "/"
        return seperator
    case Settings.Hhyphen: seperator = "-"
        return seperator
    default: seperator = "."
        return seperator
    }
}

function get_date_text(year,month,day,datetext) {
    var type = settings.get_date_format()
    var seperator = get_seperator()
    var text
    switch(type) {
    case Settings.System_locale_short: text = datetext
        console.log("type"+type+"date_text"+text)
        return text
    case Settings.System_locale: text = get_date(year,month,day)
        console.log("type"+type+"date_text"+text)
        return text
    case Settings.YYYYMMDD: text = year + seperator + month + seperator + day
        console.log("date_text"+text)
        return text
    case Settings.DDMMYYYY: text = day + seperator + month + seperator + year
        console.log("date_text"+text)
        return text
    case Settings.MMDDYYYY: text = month + seperator + day + seperator + year
        console.log("date_text"+text)
        return text
    default: text = datetext
        console.log("default date text")
        return text
    }
}
