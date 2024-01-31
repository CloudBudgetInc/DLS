/**********************************************************************
    Created by Vinitha on Mar 1 2017: Translator class used for Schedule object inner class formation
***********************************************************************/

global class ScheduleTranslator {

    /**********************************************************************
        Modified by Vinitha on Feb 1 2017: Translator class used for EventsByRoomCloneCtrl inner class formation
    ***********************************************************************/
    
    global static List<ScheduleDomain.roomRelatedinfo> RoomInfoMethod(List<Schedule__c> scheList){        
        system.debug('::scheList:::'+scheList);
        List<ScheduleDomain.roomRelatedinfo> roomRecList = new List<ScheduleDomain.roomRelatedinfo>();
        integer i; 
        String roomno; 
        String starttime;
        String endtime; 
        String customdet;
        String enddate;
        String loc;
        String fromto;
        
        system.debug('::scheList:size:'+scheList.size());    
        for(i = 0; i < scheList.size() ;i++){
           
            customdet = '';
            if(scheList[i].End_Date__c != null){
                enddate = scheList[i].End_Date__c.Month()+'/'+scheList[i].End_Date__c.day()+'/'+scheList[i].End_Date__c.Year();
            }
            if(scheList[i].Room__r.Room_Location__c == 'Interior' && scheList[i].Room__r.Room_Location__c != null){
                loc = scheList[i].Room__r.Room_Location__c.replace('Interior','I');
            }else if(scheList[i].Room__r.Room_Location__c != null && scheList[i].Room__r.Room_Location__c == 'Window'){
                loc = scheList[i].Room__r.Room_Location__c.replace('Window','W');  
            }
            
            if(scheList[i].Room__r.Name != null)
                roomno = scheList[i].Room__r.Name +'-'+loc;
                
            if(scheList[i].Days__c != null){
                if(scheList[i].Days__c.contains(';')){
                    fromto = scheList[i].Days__c.replace(';','/');
                } else {
                    fromto = scheList[i].Days__c;
                }
            }
                
            starttime = scheList[i].Start_Time__c;
            endtime = scheList[i].End_Time__c;
            system.debug(':::::'+scheList[i].Id);
            system.debug(':::::'+scheList[i].Opportunity__r.Name);
            system.debug(':::::'+scheList[i].Opportunity__r.Language__c);
            system.debug(':::::'+scheList[i].End_Date__c);
            system.debug(':::::'+scheList[i].Instructor__r.Name);
            system.debug(':::::'+scheList[i].Project_Task__r.Project_Task_Type__c);
            system.debug('::scheList[i].Opportunity__c:::'+scheList[i].Opportunity__c);
            system.debug(':::scheList[i].Project__c::'+scheList[i].Project__c);
            system.debug('::scheList[i].Project__r.AcctSeed__Opportunity__c:::'+scheList[i].Project__r.AcctSeed__Opportunity__c);
            if(scheList[i].Opportunity__c != null){
                if(scheList[i].Opportunity__r.Section__c != null){
                    //customdet = fromto+' '+scheList[i].Opportunity__r.Section__c;  
                    customdet = fromto; 
                }
                
                if(scheList[i].Project_Task__r.Project_Task_Type__c != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Project_Task__r.Project_Task_Type__c;
                    }else{
                        customdet = fromto+' '+scheList[i].Project_Task__r.Project_Task_Type__c;
                    }
                }
                
                if(scheList[i].Opportunity__r.Name != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Opportunity__r.Name;
                    }else{
                        customdet = fromto+' '+scheList[i].Opportunity__r.Name;
                    }
                }
                
                if(scheList[i].Opportunity__r.Language__c != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Opportunity__r.Language__c;
                    }else{
                        customdet = fromto+' '+scheList[i].Opportunity__r.Language__c;
                    }
                }
                
                if(scheList[i].End_Date__c != null){
                    if(customdet != null){
                        customdet += ' '+enddate;
                    }else{
                        customdet = fromto+' (End '+enddate+')';
                    }
                }
                
                if(scheList[i].Instructor__r.Name != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Instructor__r.Name;
                    }else{
                        customdet = fromto+' '+scheList[i].Instructor__r.Name;
                    }
                }

            } else if(scheList[i].Project__c != null && scheList[i].Project__r.AcctSeed__Opportunity__c != null){
                system.debug(':::::'+scheList[i].Id);
                system.debug(':::::'+scheList[i].Project__r.AcctSeed__Opportunity__r.Name);
                system.debug(':::::'+scheList[i].Project__r.AcctSeed__Opportunity__r.Language__c);
                system.debug(':::::'+scheList[i].End_Date__c);
                system.debug(':::::'+scheList[i].Instructor__r.Name);
                system.debug(':::::'+scheList[i].Project_Task__r.Project_Task_Type__c);
                system.debug(':::::'+customdet);
                if(scheList[i].Project__r.AcctSeed__Opportunity__r.Section__c != null){
                    //customdet = fromto+' '+scheList[i].Project__r.AcctSeed__Opportunity__r.Section__c; 
                    customdet = fromto;  
                }
                
                if(scheList[i].Project_Task__r.Project_Task_Type__c != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Project_Task__r.Project_Task_Type__c;
                    }else{
                        customdet = fromto+' '+scheList[i].Project_Task__r.Project_Task_Type__c;
                    }
                }
                
                if(scheList[i].Project__r.AcctSeed__Opportunity__r.Name != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Project__r.AcctSeed__Opportunity__r.Name;
                    }else{
                        customdet = fromto+' '+scheList[i].Project__r.AcctSeed__Opportunity__r.Name;
                    }
                }
                
                if(scheList[i].Project__r.AcctSeed__Opportunity__r.Language__c != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Project__r.AcctSeed__Opportunity__r.Language__c;
                    }else{
                        customdet = fromto+' '+scheList[i].Project__r.AcctSeed__Opportunity__r.Language__c;
                    }
                }
                
                if(scheList[i].End_Date__c != null){
                    if(customdet != null){
                        customdet += ' '+enddate;
                    }else{
                        customdet = fromto+' (End '+enddate+')';
                    }
                }
                
                if(scheList[i].Instructor__r.Name != null){
                    if(customdet != null){
                        customdet += ' '+scheList[i].Instructor__r.Name;
                    }else{
                        customdet = fromto+' '+scheList[i].Instructor__r.Name;
                    }
                }
                
            }
            ScheduleDomain.roomRelatedinfo roominfo = new ScheduleDomain.roomRelatedinfo();
            roominfo.RoomNumber = roomno;
            roominfo.RoomName = scheList[i].Room__r.Name; 
            roominfo.EndTime = scheList[i].End_Time__c;
            roominfo.StratTime = scheList[i].Start_Time__c; 
            roominfo.customInfo = customdet;
            roominfo.RoomId = scheList[i].Room__c;
            roominfo.ScheduleId = scheList[i].Id; 
            if(scheList[i].Opportunity__c != null){
                roominfo.sectionType = scheList[i].Opportunity__r.Section__c;
            } else if(scheList[i].Project__c != null && scheList[i].Project__r.AcctSeed__Opportunity__c != null){
                roominfo.sectionType = scheList[i].Project__r.AcctSeed__Opportunity__r.Section__c;
            }          
            roomRecList.add(roominfo);
            system.debug('::::roomRecList'+roomRecList);
        }        
        return roomRecList;
    }  
    
    /***************************************************
    - Method to form the Schedule record details
    - Added by NS on Nov 23 2018
    **********************************************************/
    public static ScheduleDomain.SheduleDetailInfo scheduleDetailsFormation(List<OpportunityLineItem> opliRecords,List<AcctSeed__Project_Task__c> taskRecords,Id oppId,Id projectId,List<String> timeList,List<Schedule__c> scheduleRecord,String parentRTName,String scheduleType,Map<Id,Decimal> opliTaskIdAlottedHrs,Date stDt,Date endDt,String priorSchId,String parentSchId,List<Holiday> holidayList,Map<Id,Decimal> totalPlannedHrsMap,List<Schedule__c> existingSchedules,String defaultCR) {
        
        ScheduleDomain.SheduleDetailInfo schDetailInfo = new ScheduleDomain.SheduleDetailInfo();
        schDetailInfo.timeValues = timeList;
        schDetailInfo.opliRecords = opliRecords;
        schDetailInfo.projectTaskRecords = taskRecords;
        schDetailInfo.opliTaskIdAlottedHrs = opliTaskIdAlottedHrs;
        schDetailInfo.schDetail = scheduleInstanceFormation(scheduleRecord,oppId,projectId,parentRTName,scheduleType,stDt,endDt,priorSchId,parentSchId);
        schDetailInfo.stDate = stDt;
        schDetailInfo.endDate = endDt;
        schDetailInfo.parentRTName = parentRTName;
        schDetailInfo.totalPlannedHrsMap = totalPlannedHrsMap;
        schDetailInfo.exisitngSchedules = existingScheduleFormation(existingSchedules);
        //Added By Dhinesh - W-006013 - Zoom Integration - to set Room as Zoom - Online when Move Online is clicked in the schedule related tab in Project detail page
        if(String.isNotEmpty(priorSchId) && scheduleType == 'Move Online' && schDetailInfo.exisitngSchedules != null && schDetailInfo.exisitngSchedules.get(priorSchId) != null){
            Id onlineRoomId = ZoomUtil.getOnlineRoomId();
            
            if(onlineRoomId != null){
                schDetailInfo.exisitngSchedules.get(priorSchId).roomName = 'Zoom - Online';
                schDetailInfo.exisitngSchedules.get(priorSchId).roomId = onlineRoomId;
            }
        }
        schDetailInfo.defaultCRRateType = defaultCR;
        schDetailInfo.scheduleType = scheduleType;        
        
        List<ScheduleDomain.TotalOffs> offList = new List<ScheduleDomain.TotalOffs>();
        
        for(Holiday hol : holidayList){
            offList.add(new ScheduleDomain.TotalOffs(hol.Name, hol.ActivityDate, 'HOLIDAY'));
        }
        schDetailInfo.holidays = offList;
        
        return schDetailInfo;
        
    }
    
    /***************************************************************
    - Method to form the schedule details to wrapper format
    - Added by NS on Nov 23 2018
    ***************************************************************/
    public static ScheduleDomain.ScheduleDetail scheduleInstanceFormation(List<Schedule__c> schRecord,Id oppId,Id projectId,String parentRTName,String scheduleType,Date stDate,Date endDate,String priorSchId,String parentSchId){
        ScheduleDomain.ScheduleDetail newSchedule = new ScheduleDomain.ScheduleDetail();
        
        EventHandler eveHandler = new EventHandler();
        
        ScheduleDomain.Days dayVal = new ScheduleDomain.Days();
        
        //system.debug('::::::::::::schRecord:::::::'+schRecord);
        
        if(schRecord.size() > 0){
            newSchedule = scheduleWrapperFormation(schRecord[0]);            
        }else {
            newSchedule.startDate = stDate;
            newSchedule.endDate = endDate;
            newSchedule.timezone = UserInfo.getTimeZone().getID();
            newSchedule.variedTime = false;
            newSchedule.variedDay = false;
            newSchedule.status = 'Drafted';
            newSchedule.scheduleType = scheduleType;
            newSchedule.projectId = projectId;
            newSchedule.oppId = oppId;
            newSchedule.isTravelRequired = false;
            newSchedule.excludeFederalHoliday = true;
            newSchedule.priorScheduleId = priorSchId;
            newSchedule.parentScheduleId = parentSchId;
            newSchedule.isNew = true;
            newSchedule.isUpdate = false;
            newSchedule.isChanged = false;
            newSchedule.totalHrsPlanned = 0;
            newSchedule.breakTimeHrs = 0;
            newSchedule.biWeekly = false;
            newSchedule.createZoomMeetings = false;
            
            dayVal.monday = false;
            dayVal.tuesday = false;
            dayVal.wednesday = false;
            dayVal.thursday = false;
            dayVal.friday = false;
            dayVal.saturday = false;
            dayVal.sunday = false;
            
            newSchedule.dayVal = dayVal;
            
        }
        return newSchedule;
    }
    
    public static ScheduleDomain.ScheduleDetail scheduleWrapperFormation(Schedule__c sch){
        ScheduleDomain.ScheduleDetail schRec = new ScheduleDomain.ScheduleDetail();
        EventHandler eveHandler = new EventHandler();
        ScheduleDomain.Days dayVal = new ScheduleDomain.Days();
        
        schRec.scheduleId = sch.Id;
        schRec.scheduleName = sch.Name;
        schRec.startDate = sch.Start_Date__c;
        schRec.endDate = sch.End_Date__c;
        schRec.startTime = sch.Start_Time__c;
        schRec.endTime = sch.End_Time__c;
        schRec.startTimeMinutes = eveHandler.convertToMinutes(sch.Start_Time__c);
        schRec.endTimeMinutes = eveHandler.convertToMinutes(sch.End_Time__c);
        schRec.hoursPlanned = sch.Hours_Planned__c;
        schRec.timezone = sch.Timezone__c;
        schRec.variedTime = sch.Varied_Time__c;
        schRec.variedDay = sch.Varied_Day__c;
        schRec.status = sch.Status__c;
        schRec.scheduleType = sch.Schedule_Type__c;
        schRec.projectId = sch.Project__c;
        schRec.oppId = sch.Opportunity__c;
        schRec.opliId = sch.Opportunity_Product_Id__c;
        schRec.projectTaskId = sch.Project_Task__c;
        schRec.instructorId = sch.Instructor__c;
        schRec.roomId = sch.Room__c;
        schRec.travelInDate = sch.Travel_In__c;
        schRec.travelOutDate = sch.Travel_Out__c;
        schRec.isTravelRequired = sch.Travel_Required__c;
        schRec.excludeFederalHoliday = sch.Exclude_Federal_Holidays__c;
        schRec.breakTimeHrs = sch.Break_Time_Hours__c != null ? sch.Break_Time_Hours__c : 0;
        schRec.totalHrsPerSession = sch.Total_Hours_per_Session__c;
        schRec.parentScheduleId = sch.Parent_Schedule__c;
        schRec.priorScheduleId = sch.Prior_Schedule__c;
        schRec.totalHrsPlanned = sch.Total_Hours__c;
        schRec.cancellationReason = sch.Cancellation_Reason__c;
        schRec.instructorName = sch.Instructor__r.Name;
        schRec.roomName = sch.Room__r.Name;
        schRec.isNew = false;
        schRec.isUpdate = true;
        schRec.isChanged = false;
        schRec.biWeekly = sch.Bi_Weekly__c;
        schRec.createZoomMeetings = sch.Create_Zoom_Meetings__c;
        
        
        dayVal.monday = sch.Monday__c;
        dayVal.tuesday = sch.Tuesday__c;
        dayVal.wednesday = sch.Wednesday__c;
        dayVal.thursday = sch.Thursday__c;
        dayVal.friday = sch.Friday__c;
        dayVal.saturday = sch.Saturday__c;
        dayVal.sunday = sch.Sunday__c;
        
        schRec.dayVal = dayVal;
        
        return schRec;
    }
    
    /**********************************************************************************
    - Existing scheudle records formation as wrapper class
    - Added by NS on Nov 28 2018
    ***********************************************************************************/
    public static Map<Id,ScheduleDomain.ScheduleDetail> existingScheduleFormation(List<Schedule__c> scheduleRecords){
        
        Map<Id,ScheduleDomain.ScheduleDetail> schIdScheduleRecMap = new Map<Id,ScheduleDomain.ScheduleDetail>();
        
        for(Schedule__c sch : scheduleRecords){
            ScheduleDomain.ScheduleDetail schRec = scheduleWrapperFormation(sch);
            schIdScheduleRecMap.put(sch.Id,schRec);
        }
        
        return schIdScheduleRecMap;
    }
    
    /*************************************************
    - Method to convert to wrapper to original schedule record
    *************************************************/
    public static Schedule__c OriginalScheduleRecordFormation(ScheduleDomain.ScheduleDetail schRec){
        Schedule__c schInstance = new Schedule__c();
        
        schInstance.Id = String.isNotBlank(schRec.scheduleId) ? schRec.scheduleId : null ;
        schInstance.Name = schRec.scheduleName;
        schInstance.Start_Date__c = schRec.startDate;
        schInstance.End_Date__c = schRec.endDate;
        schInstance.Start_Time__c = schRec.startTime;
        schInstance.End_Time__c = schRec.endTime;
        schInstance.Hours_Planned__c = schRec.hoursPlanned;
        schInstance.Timezone__c = schRec.timezone;
        schInstance.Varied_Time__c = schRec.variedTime;
        schInstance.Varied_Day__c = schRec.variedDay;
        schInstance.Status__c = schRec.status;
        schInstance.Schedule_Type__c = schRec.scheduleType;
        schInstance.Project__c = schRec.projectId;
        schInstance.Opportunity__c = schRec.oppId;
        schInstance.Opportunity_Product_Id__c = String.isNotBlank(schRec.opliId) ? schRec.opliId : null;
        schInstance.Project_Task__c = String.isNotBlank(schRec.projectTaskId) ? schRec.projectTaskId : null ;
        schInstance.Instructor__c = String.isNotBlank(schRec.instructorId) ? schRec.instructorId : null;
        schInstance.Room__c = schRec.roomId;
        schInstance.Travel_In__c = schRec.travelInDate;
        schInstance.Travel_Out__c = schRec.travelOutDate;
        schInstance.Travel_Required__c = schRec.isTravelRequired;
        schInstance.Exclude_Federal_Holidays__c = schRec.excludeFederalHoliday;
        schInstance.Break_Time_Hours__c = schRec.breakTimeHrs;
        schInstance.Total_Hours_per_Session__c = schRec.totalHrsPerSession;
        
        schInstance.Parent_Schedule__c = String.isNotBlank(schRec.parentScheduleId) ? schRec.parentScheduleId : null;
        schInstance.Prior_Schedule__c = String.isNotBlank(schRec.priorScheduleId) ? schRec.priorScheduleId : null;
        schInstance.Total_Hours__c = schRec.totalHrsPlanned;
        schInstance.Cancellation_Reason__c = schRec.cancellationReason;
        schInstance.Bi_Weekly__c = schRec.biWeekly;
        schInstance.Create_Zoom_Meetings__c = schRec.createZoomMeetings;
        
        ScheduleDomain.Days dayVal = schRec.dayVal;
        
        schInstance.Monday__c = dayVal.monday;
        schInstance.Tuesday__c = dayVal.tuesday;
        schInstance.Wednesday__c = dayVal.wednesday;
        schInstance.Thursday__c = dayVal.thursday;
        schInstance.Friday__c = dayVal.friday;
        schInstance.Saturday__c = dayVal.saturday;
        schInstance.Sunday__c = dayVal.sunday;
        
        return schInstance;
        
    }
    
     /*************************************************************************************************
    
    - Method to form the wrapper for Instructor & Student Community list view
    - Added by Mohana on Mar 28 2019
    *************************************************************************************************/
    public static List<ScheduleDomain.ScheduleInfo> scheduleRecordsFormation(List<Schedule__c> schedules){
        
        List<ScheduleDomain.ScheduleInfo> scheduleRecords = new List<ScheduleDomain.ScheduleInfo>();
        TimezoneUtilClass utilCls = new TimezoneUtilClass();
        
        for(Schedule__c schedule : schedules) {
            
            ScheduleDomain.ScheduleInfo scheduleWrap = new ScheduleDomain.ScheduleInfo();
            scheduleWrap.scheduleId = schedule.Id;
            scheduleWrap.name = schedule.Name;
            scheduleWrap.days = schedule.Days__c;
            scheduleWrap.dlsClass = schedule.DLS_Ref__c;
            if(schedule.Start_Date__c != null) {
                scheduleWrap.startDate = schedule.Start_Date__c.month()+'/'+schedule.Start_Date__c.day()+'/'+schedule.Start_Date__c.year();
            }
            if(schedule.End_Date__c != null) {
                scheduleWrap.endDate = schedule.End_Date__c.month()+'/'+schedule.End_Date__c.day()+'/'+schedule.End_Date__c.year();
            }
            DateTime stDateTime = utilCls.getUserTimeZoneDateTime(utilCls.getDateTimeInGMT(schedule.Timezone__c, schedule.Start_Date__c, schedule.Start_Time__c, false));
            DateTime endDateTime = utilCls.getUserTimeZoneDateTime(utilCls.getDateTimeInGMT(schedule.Timezone__c, schedule.Start_Date__c, schedule.End_Time__c, true));
            scheduleWrap.stDate = schedule.Start_Date__c;
            scheduleWrap.edDate = schedule.End_Date__c;
            scheduleWrap.startTime = stDateTime.format('hh:mm a');//schedule.Start_Time__c;
            scheduleWrap.endTime = endDateTime.format('hh:mm a');//schedule.End_Time__c;
            scheduleWrap.status = schedule.Status__c;
            scheduleWrap.projectTask = schedule.Project_Task__r.Name;
            scheduleWrap.projectTaskType = schedule.Project_Task__r.Project_Task_Type__c;
            scheduleWrap.instructor= schedule.Instructor__r.Name;
            scheduleWrap.room = schedule.Room__r.Name;
            scheduleWrap.totalHoursPerSession = schedule.Total_Hours_per_Session__c;
            scheduleWrap.totalHours = schedule.Total_Hours__c;
            scheduleWrap.unit = schedule.Project_Task__r.Unit__c;
            scheduleWrap.timezone = schedule.Timezone__c;
            
            scheduleRecords.add(scheduleWrap ); 
        }
        return scheduleRecords ;
    
    }
    
    /*************************************************
    - Method to convert to wrapper to List of original schedule record
    *************************************************/
    public static List<Schedule__c> OriginalScheduleRecFormationList(List<ScheduleDomain.ScheduleDetail> schRecList){
        List<Schedule__c> schInstanceList = new List<Schedule__c>();
        
        for(ScheduleDomain.ScheduleDetail schRec : schRecList){
            Schedule__c schInstance = new Schedule__c();
            
            schInstance.Id = String.isNotBlank(schRec.scheduleId) ? schRec.scheduleId : null ;
            schInstance.Name = schRec.scheduleName;
            schInstance.Start_Date__c = schRec.startDate;
            schInstance.End_Date__c = schRec.endDate;
            schInstance.Start_Time__c = schRec.startTime;
            schInstance.End_Time__c = schRec.endTime;
            schInstance.Hours_Planned__c = schRec.hoursPlanned;
            schInstance.Timezone__c = schRec.timezone;
            schInstance.Varied_Time__c = schRec.variedTime;
            schInstance.Varied_Day__c = schRec.variedDay;
            schInstance.Status__c = schRec.status;
            schInstance.Schedule_Type__c = schRec.scheduleType;
            schInstance.Project__c = schRec.projectId;
            schInstance.Opportunity__c = schRec.oppId;
            schInstance.Opportunity_Product_Id__c = String.isNotBlank(schRec.opliId) ? schRec.opliId : null;
            schInstance.Project_Task__c = String.isNotBlank(schRec.projectTaskId) ? schRec.projectTaskId : null ;
            schInstance.Instructor__c = String.isNotBlank(schRec.instructorId) ? schRec.instructorId : null;
            schInstance.Room__c = schRec.roomId;
            schInstance.Travel_In__c = schRec.travelInDate;
            schInstance.Travel_Out__c = schRec.travelOutDate;
            schInstance.Travel_Required__c = schRec.isTravelRequired;
            schInstance.Exclude_Federal_Holidays__c = schRec.excludeFederalHoliday;
            schInstance.Break_Time_Hours__c = schRec.breakTimeHrs;
            schInstance.Total_Hours_per_Session__c = schRec.totalHrsPerSession;
            
            schInstance.Parent_Schedule__c = String.isNotBlank(schRec.parentScheduleId) ? schRec.parentScheduleId : null;
            schInstance.Prior_Schedule__c = String.isNotBlank(schRec.priorScheduleId) ? schRec.priorScheduleId : null;
            schInstance.Total_Hours__c = schRec.totalHrsPlanned;
            schInstance.Cancellation_Reason__c = schRec.cancellationReason;
            schInstance.Bi_Weekly__c = schRec.biWeekly;
            schInstance.Create_Zoom_Meetings__c = schRec.createZoomMeetings;
            
            ScheduleDomain.Days dayVal = schRec.dayVal;
            
            schInstance.Monday__c = dayVal.monday;
            schInstance.Tuesday__c = dayVal.tuesday;
            schInstance.Wednesday__c = dayVal.wednesday;
            schInstance.Thursday__c = dayVal.thursday;
            schInstance.Friday__c = dayVal.friday;
            schInstance.Saturday__c = dayVal.saturday;
            schInstance.Sunday__c = dayVal.sunday;
            
            schInstanceList.add(schInstance);
        }
        return schInstanceList;
    }
    
}