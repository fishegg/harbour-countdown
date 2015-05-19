function nextZeroPoint() {
    var date = new Date();
    var newday = new Date();
    newday.setHours(0);
    newday.setMinutes(0);
    newday.setSeconds(0);
    newday.setMilliseconds(0)
    return newday-date+86400000
}
