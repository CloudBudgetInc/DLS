({
    convertTime : function(cmp,hourString) {
        var split1 = [];
        if(hourString != '') {
            split1 = hourString.split(' ');
        }
        
        var split2 = [];
        var minutes = 0;
        if(split1.length == 2) {
            split2 = split1[0].split(':');
        } else {
            return 0;
        }
        if(split2.length != 2) {
            return 0;
        } else {
            if(split1[1] == 'AM') {
                minutes += parseInt(split2[0]) * 60;
                if(split2[0] == '12') {
                    minutes = 0;
                }
                minutes += parseInt(split2[1]);
            } else if(split1[1] == 'PM') {
                var offset = 12;
                if(split2[0] == '12') {
                    offset = 0;
                }
                minutes = (parseInt(split2[0]) + offset) * 60;
                minutes += parseInt(split2[1]);
            }
        }
        return minutes;
    },
    getMinutes : function(time){
        if(time == undefined){
            return 0;
        }    
        var h = time.split(' ');
        var m = h[0].split(':');
        var t = [];
        if(m[1] != undefined){
            t[1] = m[1];
        } else {
            t[1] = 0;
        }
        if(h[1] == 'AM') {
            t[0] = m[0];
        } else if(h[1] == 'PM'){
            if(m[0] == '12'){
                t[0] = 12;
            } else {
                t[0] = parseInt(m[0]) + 12;
            }
        }
        return (parseInt(t[0]) * 60) + parseInt(t[1]);
    },
    endTimeCalculation : function(cmp,startTime) {
        if(startTime != '' && startTime != undefined && startTime != '--None--') {
            var stTime = this.convertTime(cmp,startTime);
            var endTimeList = [];
            
            for(var i = 0; i < cmp.get("v.startTimeList").length; i++) {
                if(stTime < this.convertTime(cmp,cmp.get("v.startTimeList")[i]) ||
                   this.convertTime(cmp,cmp.get("v.startTimeList")[i]) == 0) {
                    endTimeList.push(cmp.get("v.startTimeList")[i]);
                }
            }
            cmp.set("v.endTimeList", endTimeList);
        } else {
            cmp.set("v.endTimeList", []);
            if(cmp.get("v.buttonType") == 'Edit'){
                var obj = cmp.get("v.editRecord");
                obj.endTime = '--None--';
                cmp.set("v.editRecord",obj);
            }
        }
    },
    pmEndTimeCalculation : function(cmp,startTime) {
        if(startTime != '' && startTime != undefined && startTime != '--None--') {
            var stTime = this.convertTime(cmp,startTime);
            var endTimeList = [];
            
            for(var i = 0; i < cmp.get("v.pmStartTimeList").length; i++) {
                if(stTime < this.convertTime(cmp,cmp.get("v.pmStartTimeList")[i]) ||
                   this.convertTime(cmp,cmp.get("v.pmStartTimeList")[i]) == 0) {
                    endTimeList.push(cmp.get("v.pmStartTimeList")[i]);
                }
            }
            cmp.set("v.pmEndTimeList", endTimeList);
            
        } else {
            cmp.set("v.pmEndTimeList", []);
            if(cmp.get("v.buttonType") == 'Edit'){
                var obj = cmp.get("v.editRecord");
                obj.endTime2 = '--None--';
                cmp.set("v.editRecord",obj);
            }
        }
    },
    fireInputChangeToParent : function(cmp, event){
        var type = cmp.get("v.type");
        var day = cmp.get("v.dayRecord");
        if(!day.dayId && cmp.get("v.changedField") != 'Hours' && cmp.get("v.changedField") != 'Cancellation'){
            var time1 = cmp.get("v.startTime");
            var time2 = cmp.get("v.endTime");
            if(type == 'Normal'){
                day.startTime1 = time1;
                if(!time1){
                    day.endTime1 = '';
                }else {
                    day.endTime1 = time2;
                }
                
            }else if(type == 'AM'){
                day.startTime1 = time1;
                if(!time1){
                    day.endTime1 = '';
                }else {
                    day.endTime1 = time2;
                }
                
            }else if(type == 'PM'){
                day.startTime2 = time1;
                if(!time1){
                    day.endTime2 = '';
                }else {
                    day.endTime2 = time2;
                }
                
            }
        }
        
        console.log('enter event fire method',day.dayHours);
        var typeofAction = '';
        if(day.dayHours == 0 || day.dayHours || day.startTime1 || day.endTime1 || day.startTime2 || day.endTime2 || day.lateCancellation){
            typeofAction = 'Changed';
        }
        
        var setEvent = cmp.getEvent("UpdatedContent");
        setEvent.setParams({
            "udpatedWeekInfo": day,
            "index1": cmp.get("v.lineIndex"),
            "index2": cmp.get("v.dayIndex"),
            "typeOfAction" : typeofAction,
            "fieldName" : cmp.get("v.changedField"),
            "notesInfo" : cmp.get("v.notesInfo"),
            "oldValue" : cmp.get("v.oldValue")
        });
        setEvent.fire();
    },
    formEditModalContents : function(cmp){
        var obj = {};
        var type = cmp.get("v.type");
        var oldDay = cmp.get("v.dayRecord");
        obj.hours = oldDay.dayHours;
        obj.lateCancellation = oldDay.lateCancellation;
        obj.cancellationReason = oldDay.cancellationReason;
        obj.comments = oldDay.comments;
        obj.startTime = oldDay.startTime1;
        obj.endTime = oldDay.endTime1;
        if(type == 'PM' || (oldDay.startTime2 && oldDay.endTime2)){
            obj.startTime2 = oldDay.startTime2;
            obj.endTime2 = oldDay.endTime2;
        }
        obj.status = oldDay.status;
        
        if(oldDay.taskType != 'Preparation time'){
            obj.studentApprovalStatus = oldDay.studentApprovalStatus;
            obj.hideFromStudent = oldDay.hideFromStudent;
        }
        
        cmp.set("v.editRecord",obj);
    },
    dayValueUpdateANDNotesFormation : function(cmp,event){
        var oldDay = cmp.get("v.dayRecord");
        var type = cmp.get("v.type");
        var updatedDay = cmp.get("v.editRecord");
        
        cmp.set("v.oldValue",oldDay.dayHours);
        console.log(':::::::type::::::',type);
        
        //day records value update
        oldDay.dayHours = updatedDay.hours;
        oldDay.startTime1 = updatedDay.startTime;
        oldDay.endTime1 = updatedDay.endTime;
        //if(type == 'PM'){
            oldDay.startTime2 = updatedDay.startTime2;
            oldDay.endTime2 = updatedDay.endTime2;
        //}
        oldDay.lateCancellation = updatedDay.lateCancellation;
        oldDay.cancellationReason = updatedDay.cancellationReason;
        oldDay.comments = updatedDay.comments;
        if(cmp.get("v.buttonType") == 'Edit'){
            if(oldDay.status == 'Unposted'){
                oldDay.status = 'Draft';
                oldDay.studentApprovalStatus = updatedDay.studentApprovalStatus;
            }else {
                oldDay.status = updatedDay.status;
                oldDay.studentApprovalStatus = updatedDay.studentApprovalStatus;
            }
        }else if(cmp.get("v.buttonType") == 'Delete'){
            oldDay.status = 'Unposted';
            oldDay.studentApprovalStatus = '';
        }
        oldDay.color = updatedDay.color;
        oldDay.isHrsDisabled = false;
        oldDay.isUpdated = true;
        oldDay.showEditIcon = false;
        oldDay.isUnposted = updatedDay.isUnposted;
        oldDay.hideFromStudent = updatedDay.hideFromStudent;
        
        cmp.set("v.dayRecord",oldDay);
        
        //Call the event fire method
        cmp.set("v.changedField",'Hours');
        this.fireInputChangeToParent(cmp, event);
    },
    dateComparison : function(currentDt,columnDt){
        if(currentDt.getFullYear() <= columnDt.getFullYear() && currentDt.getMonth() <= columnDt.getMonth() 
           && currentDt.getDate() <= columnDt.getDate()){
            return true;
        }else {
            return false;
        }
    },
    timeListFormation: function(cmp){
        //AM & PM time list construction
        var pmList = [];
        var amList = [];
        var time = cmp.get("v.wholeTimeList");
        var index = time.indexOf('12:00 PM');                
        for(var i = index;i < time.length;i++){
            pmList.push(time[i]);
        }
        
        for(var i = 0;i <= index;i++){
            amList.push(time[i]);
        }
        
        cmp.set("v.amStartTimeList",amList);
        cmp.set("v.pmStartTimeList",pmList);
    },
    
})