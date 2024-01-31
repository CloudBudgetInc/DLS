function calculateDurationfromScript(record,holidaysObj) {
    var dayList = [];
    var hours = 0;
    if(record.Sunday__c) {
        dayList.push(0);
    }
    if(record.Monday__c) {
        dayList.push(1);
    }
    if(record.Tuesday__c) {
        dayList.push(2);
    }
    if(record.Wednesday__c) {
        dayList.push(3);
    }
    if(record.Thursday__c) {
        dayList.push(4);
    }
    if(record.Friday__c) {
        dayList.push(5);
    }
    if(record.Saturday__c) {
        dayList.push(6);
    }

    var startDate = record.Start_Date__c;
    var endDate = record.End_Date__c;
    var startTime = record.Start_Time__c;
    var endTime = record.End_Time__c;
    //console.log('endDate :::::',endDate );
    //console.log('startDate :::::',startDate );
    var tDate = new Date(moment(startDate,'MM-DD-YYYY').format('YYYY-MM-DD'));
    tDate.setTime(tDate.getTime() + tDate.getTimezoneOffset() * 60 * 1000);
	console.log(':::::::tDate:::::',tDate);
    var tEndDate = new Date(moment(endDate,'MM-DD-YYYY').format('YYYY-MM-DD'));
    console.log('tEndDate:::::',tEndDate);
    //console.log('endDate :::::',endDate );
    //console.log('startDate :::::',startDate );
    tEndDate.setTime(tEndDate.getTime() + tEndDate.getTimezoneOffset() * 60 * 1000);
    var duration = record.Hours_Planned__c;
    var eventDay = {};
    while(tDate <= tEndDate) {
        if(checkDayList(tDate, dayList)) {
            var intersectDay = checkIntersection(tDate, record.Exclude_Federal_Holidays__c,holidaysObj);
            if(intersectDay || eventDay[moment(tDate).format('YYYY-MM-DD')]) {
                if((intersectDay && intersectDay.RescheduleDate && checkIntersection(intersectDay.RescheduleDate, record.Exclude_Federal_Holidays__c,holidaysObj)) || (intersectDay && !intersectDay.RescheduleDate) || eventDay[moment(tDate).format('YYYY-MM-DD')]) {
                    //pushIntersectionDate(tDate);
                    tDate.setDate(tDate.getDate() + 1);
                    continue;
                }
                if(intersectDay.RescheduleDate) {
                    console.log('Event Rescheduled.', new Date(intersectDay.RescheduleDate));
                    eventDay[moment(intersectDay.RescheduleDate).format('YYYY-MM-DD')] = true;
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
        if(!excludeFederalHolidays && holidaysObj[date].Type == 'HOLIDAY') {
            console.log('holiday intersected', date);
            return false;
        }
        return holidaysObj[date];
    }
    return false;
}
