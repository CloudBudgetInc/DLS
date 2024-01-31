window.calculateDurationfromScript = function(record,holidaysObj) {
    var dayList = [];
    var hours = 0;
    if(record.sunday) {
        dayList.push(0);
    }
    if(record.monday) {
        dayList.push(1);
    }
    if(record.tuesday) {
        dayList.push(2);
    }
    if(record.wednesday) {
        dayList.push(3);
    }
    if(record.thursday) {
        dayList.push(4);
    }
    if(record.friday) {
        dayList.push(5);
    }
    if(record.saturday) {
        dayList.push(6);
    }

    var startDate = record.startDate;
    var endDate = record.endDate;
    var startTime = record.startTime;
    var endTime = record.endTime;
    //console.log('endDate :::::',endDate );
    //console.log('startDate :::::',startDate );
    var tDate = new Date(moment(startDate).format('YYYY-MM-DD'));
    tDate.setTime(tDate.getTime() + tDate.getTimezoneOffset() * 60 * 1000);
	console.log(':::::::tDate:::::',tDate);
    var tEndDate = new Date(moment(endDate).format('YYYY-MM-DD'));
    console.log('tEndDate:::::',tEndDate);
    //console.log('endDate :::::',endDate );
    //console.log('startDate :::::',startDate );
    tEndDate.setTime(tEndDate.getTime() + tEndDate.getTimezoneOffset() * 60 * 1000);
    var duration = record.hoursPlanned;
    var eventDay = {};
    while(tDate <= tEndDate) {
        if(checkDayList(tDate, dayList)) {
            var intersectDay = checkIntersection(tDate, record.excludeFederalHoliday,holidaysObj);
            if(intersectDay || eventDay[moment(tDate).format('YYYY-MM-DD')]) {
                if((intersectDay && intersectDay.rescheduleDate && checkIntersection(intersectDay.rescheduleDate, record.excludeFederalHoliday,holidaysObj)) || (intersectDay && !intersectDay.rescheduleDate) || eventDay[moment(tDate).format('YYYY-MM-DD')]) {
                    //pushIntersectionDate(tDate);
                    tDate.setDate(tDate.getDate() + 1);
                    continue;
                }
                if(intersectDay.rescheduleDate) {
                    console.log('Event Rescheduled.', new Date(intersectDay.rescheduleDate));
                    eventDay[moment(intersectDay.rescheduleDate).format('YYYY-MM-DD')] = true;
                }
            }
            hours += duration;
        }
        tDate.setDate(tDate.getDate() + 1);
    }
    return hours;
}

var checkDayList = function (date, dayList) {
    var day = date.getDay();
    if(dayList.indexOf(day) != -1) {
        return true;
    }
    return false;
}

function checkIntersection(tDate, excludeFederalHolidays,holidaysObj) {
    var date = moment(tDate).format('YYYY-MM-DD');
    if(holidaysObj[date]) {
        if(!excludeFederalHolidays && holidaysObj[date].type == 'HOLIDAY') {
            console.log('holiday intersected', date);
            return false;
        }
        return holidaysObj[date];
    }
    return false;
}