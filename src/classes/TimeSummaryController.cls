public without sharing class TimeSummaryController {

    @AuraEnabled
    public static String getWeekSummaryDetails(String projectId) {
        
        Boolean isInstructorContact = false;
        String userId = UserInfo.getUserId();
        List<User> user = [SELECT Id, contactId, Profile.Name From User Where id =: userId];
        System.debug('user::::::>'+ user);
        System.debug('projectId::::::>'+ projectId);
        
        if(user.size() > 0 && user[0].Profile.Name == 'Student Community'){
            isInstructorContact = false;
        }
        if(user.size() > 0 && user[0].Profile.Name == 'Instructor Community') {
            isInstructorContact = true;
        }
        
        Set<String> timeCardPeriodId = new Set<String>();
        Set<String> timeCardId = new Set<String>();
        Set<String> timeCardLineId =new Set<String>();
        //Query all the Time card line items based on Project Id
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(isInstructorContact) {
            
            timeCardLineList = [SELECT Id,of_Approved_Hours__c,of_Pending_Time_Logs__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__r.name,AcctSeed__Time_Card__r.Intructor__r.id,
                                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,
                                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c
                                                                FROM AcctSeed__Time_Card_Line__c 
                                                                WHERE AcctSeed__Project__c = :projectId ORDER BY AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c DESC];
        
        }else {
            
            timeCardLineList = [SELECT Id,of_Approved_Hours__c,of_Pending_Time_Logs__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__r.name,AcctSeed__Time_Card__r.Intructor__r.id,
                                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,
                                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c
                                                                FROM AcctSeed__Time_Card_Line__c 
                                                                WHERE AcctSeed__Project__c = :projectId AND AcctSeed__Project_Task__r.Project_Task_Type__c != 'Preparation time' ORDER BY AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c DESC];
        }
          
        //Construct a weeklySummary Wrapper for time summary dispaly. 
        //W-004561 - Student Community, My Projects, Timesheets Showing Inaccurately

        Map<Id,WeeklySummary> tcperiodWithHoursInfo = new Map<Id,WeeklySummary>();
        WeeklySummaryDetails WeeklySummaryDetails = new WeeklySummaryDetails();
        List<WeeklySummary> WeeklySummary = new List<WeeklySummary>();
        
        WeeklySummaryDetails.totalApprovedTime = '0.00';
        WeeklySummaryDetails.totalPendingTime = '0.00';
        
        for(AcctSeed__Time_Card_Line__c tcl: timeCardLineList ) {
            Id tcPeriodId = tcl.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c;
            
            if(!tcperiodWithHoursInfo.containsKey(tcPeriodId)){
                Date stDate = tcl.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c;
                Date edDate = tcl.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c;
                
                WeeklySummary weeklySum = new WeeklySummary();  

                WeeklySum.dateRange = String.valueOf(stDate).split('-')[1]+'/'+String.valueOf(stDate).split('-')[2]+'/'+String.valueOf(stDate).split('-')[0]+' - '+String.valueOf(edDate).split('-')[1]+'/'+String.valueOf(edDate).split('-')[2]+'/'+String.valueOf(edDate).split('-')[0];
                WeeklySum.periodId = tcPeriodId;
                WeeklySum.approvedHours = '0.00';
                WeeklySum.pendingHours = '0.00';
                
                Decimal appHrs = (tcl.of_Approved_Hours__c != null) ? tcl.of_Approved_Hours__c : 0.00;
                Decimal penHrs = (tcl.of_Pending_Time_Logs__c!= null) ? tcl.of_Pending_Time_Logs__c: 0.00;
                
                WeeklySum.approvedHours = CalculateTotal(appHrs, convertStringToDecimal(weeklySum.approvedHours));
                WeeklySum.pendingHours = CalculateTotal(penHrs, convertStringToDecimal(weeklySum.pendingHours));
                tcperiodWithHoursInfo.put(tcPeriodId,weeklySum);  
            }else {
                 WeeklySummary weeklySum = tcperiodWithHoursInfo.get(tcPeriodId); 
                
                Decimal appHours = (tcl.of_Approved_Hours__c != null) ? tcl.of_Approved_Hours__c : 0.00;
                Decimal penHours = (tcl.of_Pending_Time_Logs__c!= null) ? tcl.of_Pending_Time_Logs__c: 0.00;
                
                WeeklySum.approvedHours = CalculateTotal(appHours, convertStringToDecimal(weeklySum.approvedHours));
                WeeklySum.pendingHours = CalculateTotal(penHours, convertStringToDecimal(weeklySum.pendingHours));
                tcperiodWithHoursInfo.put(tcPeriodId,weeklySum);  
            }
        }
        
        List<WeeklySummary> weeklySumList = new List<WeeklySummary>();
        for(Id tcperiodId : tcperiodWithHoursInfo.keySet()){
            WeeklySummary weeklySum = tcperiodWithHoursInfo.get(tcPeriodId); 
            weeklySumList.add(weeklySum);
            
            WeeklySummaryDetails.totalApprovedTime = CalculateTotal(convertStringToDecimal(weeklySum.approvedHours), convertStringToDecimal(WeeklySummaryDetails.totalApprovedTime));
            WeeklySummaryDetails.totalPendingTime = CalculateTotal(convertStringToDecimal(weeklySum.pendingHours), convertStringToDecimal(WeeklySummaryDetails.totalPendingTime));
        }
 
        WeeklySummaryDetails.WeeklySummary = weeklySumList;     
        WeeklySummaryDetails.isInstructor =  isInstructorContact;
        WeeklySummaryDetails.insId = user[0].contactId;
        System.debug('WeeklySummary WeeklySummary' + WeeklySummary);   
        
        return JSON.serialize(WeeklySummaryDetails);
    }
    
    @AuraEnabled
    public static String getInstructorDetails(String projectId, String periodId) {
        
        Set<String> timeCardId = new Set<String>();
        
        String communityName = EventCalendarController.getCommunityPathPrefix();
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        
        if(communityName == 'instructor') {
            
            timeCardLineList = [SELECT Id,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__r.name,AcctSeed__Time_Card__r.Intructor__c,
                                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,of_Pending_Time_Logs__c,of_Approved_Hours__c
                                                                FROM AcctSeed__Time_Card_Line__c 
                                                                WHERE AcctSeed__Project__c = :projectId AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c =: periodId];
        
        }else {
            
            timeCardLineList = [SELECT Id,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__r.name,AcctSeed__Time_Card__r.Intructor__c,
                                                                    AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c,of_Pending_Time_Logs__c,of_Approved_Hours__c
                                                                FROM AcctSeed__Time_Card_Line__c 
                                                                WHERE AcctSeed__Project__c = :projectId AND AcctSeed__Project_Task__r.Project_Task_Type__c != 'Preparation time' 
                                                                    AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c =: periodId];
        }
        
        
        
        Map<Id,InstructorSummary> instructorSummaryMap = new Map<Id,InstructorSummary>();
        
        InstructorSummaryDetails insSumDetails = new InstructorSummaryDetails();
        insSumDetails.totalPendingHours = '0.00';
        insSumDetails.totalApprovedHours = '0.00';
        
        List<InstructorSummary> instructorSummary = new List<InstructorSummary>();     
        
        for(AcctSeed__Time_Card_Line__c tcl: timeCardLineList ) {           
            if(!instructorSummaryMap.containsKey(tcl.AcctSeed__Time_Card__c)){
                
                InstructorSummary insSum = new InstructorSummary();
                insSum.insId = tcl.AcctSeed__Time_Card__r.Intructor__c;
                insSum.insName =  tcl.AcctSeed__Time_Card__r.Intructor__r.name;
                
                Decimal penHrs = (tcl.of_Pending_Time_Logs__c!= null) ? tcl.of_Pending_Time_Logs__c : 0.00;
                Decimal appHrs = (tcl.of_Approved_Hours__c!= null) ? tcl.of_Approved_Hours__c : 0.00;
                
                insSum.pendingHours = convertDecimalToString(penHrs);
                insSum.approvedHours= convertDecimalToString(appHrs);
                insSum.timeCardId = tcl.AcctSeed__Time_Card__c;
                instructorSummaryMap.put(tcl.AcctSeed__Time_Card__c,insSum);
            }else{
                InstructorSummary insSum = instructorSummaryMap.get(tcl.AcctSeed__Time_Card__c);
                
                Decimal penHours = (tcl.of_Pending_Time_Logs__c!= null) ? tcl.of_Pending_Time_Logs__c : 0.00;
                Decimal appHours = (tcl.of_Approved_Hours__c!= null) ? tcl.of_Approved_Hours__c : 0.00;
                
                insSum.pendingHours =  CalculateTotal(penHours,Decimal.valueOf(insSum.pendingHours));
                insSum.approvedHours=  CalculateTotal(appHours,Decimal.valueOf(insSum.approvedHours));
                instructorSummaryMap.put(tcl.AcctSeed__Time_Card__c,insSum);
            }
        }     
        
        
        for(Id tcd : instructorSummaryMap.keySet()) {
            InstructorSummary insSum = instructorSummaryMap.get(tcd);
            insSumDetails.totalPendingHours = CalculateTotal(Decimal.valueOf(insSum.pendingHours),Decimal.valueOf(insSumDetails.totalPendingHours));
            insSumDetails.totalApprovedHours = CalculateTotal(Decimal.valueOf(insSum.approvedHours),Decimal.valueOf(insSumDetails.totalApprovedHours));
            instructorSummary.add(insSum);
        }
        
        insSumDetails.InstructorSummary = instructorSummary;
                
        return JSON.serialize(insSumDetails);
    }
    
    @AuraEnabled
    public static String getDaySummaryDetails(String projectId, String periodId, String timeCardId, String insId) {
        
        List<AcctSeed__Time_Card_Line__c> timeCardLineList;
        List<WeekRangeValues> weekRangeVal = new List<WeekRangeValues>();
        List<DaySummary> daySummary= new List<DaySummary>();
        OverallDaySummary oveDayDetails = new OverallDaySummary();
        columnTotalHours columnTotal = new columnTotalHours();
        columnTotal.monTotal = '0.00';
        columnTotal.tueTotal = '0.00';
        columnTotal.wedTotal = '0.00';
        columnTotal.thuTotal = '0.00';
        columnTotal.friTotal = '0.00';
        columnTotal.satTotal = '0.00';
        columnTotal.sunTotal = '0.00';
        Map<Date, DayInfo> dateMap = new Map<Date, DayInfo>();
        
        List<AcctSeed__Time_Card_Period__c> timeCardPeriod = [SELECT Id, AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c WHERE Id =: periodId];
        
        if(timeCardPeriod.size() > 0) {
        
            Date startDate = timeCardPeriod[0].AcctSeed__Start_Date__c;
            Date endDate = timeCardPeriod[0].AcctSeed__End_Date__c;
            System.debug('startDate::::'+ startDate);
            System.debug('endDate ::::'+ endDate ); 
                       
            while(startDate <= endDate){
                DayInfo dayInformation = new DayInfo();
                dayInformation.hours = '0.00';
                dateMap.put(startDate, dayInformation);
                WeekRangeValues wkVal = new WeekRangeValues();
                wkVal.dateValue = String.valueOf(startDate).split('-')[1]+'/'+String.valueOf(startDate).split('-')[2]+'/'+String.valueOf(startDate).split('-')[0];
                DateTime todayVal = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
                wkVal.dayVal = todayVal.format('EEE').toUppercase();                
                weekRangeVal.add(wkVal);                
                startDate = startDate.addDays(1);
            }
            
        }
        
        System.debug('dateMap ::::'+ dateMap);
        if(insId !=null) {
            //System.debug('ins');
             timeCardLineList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project__r.DLS_Class__c,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Name,Location__c,Location__r.Name,
                                   (SELECT Id, Name, AcctSeed__Date__c, Status__c, Total_Hours_Before_Approved__c, Week_Day__c 
                                        FROM AcctSeed__Time_Card_Days__r
                                        WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c = : periodId ORDER BY AcctSeed__Date__c DESC)
                                FROM AcctSeed__Time_Card_Line__c
                                WHERE AcctSeed__Project__c =: projectId AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c = :periodId AND AcctSeed__Time_Card__r.Intructor__c = :insId ];
                                   
        } else {
             timeCardLineList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project__r.DLS_Class__c,AcctSeed__Project_Task__c,AcctSeed__Project_Task__r.Name,Location__c,Location__r.Name,
                                    (SELECT Id, Name, AcctSeed__Date__c, Status__c, Total_Hours_Before_Approved__c, Week_Day__c 
                                        FROM AcctSeed__Time_Card_Days__r
                                        WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c = : periodId ORDER BY AcctSeed__Date__c DESC)
                                FROM AcctSeed__Time_Card_Line__c
                                WHERE AcctSeed__Project__c =: projectId AND AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c = :periodId AND AcctSeed__Time_Card__c = :timeCardId AND
                                    AcctSeed__Project_Task__r.Project_Task_Type__c != 'Preparation time'];   
        }
        
        
        for(AcctSeed__Time_Card_Line__c timeCard: timeCardLineList){
        
            Map<Date,DayInfo> dayMap = new Map<Date,DayInfo>();                   
            DaySummary daySum = new DaySummary();
            daySum.totalHours = '0.00';
            daySum.dayRecords = new List<DayInfo>(); 
            daySum.chargeCode =  timeCard.AcctSeed__Project__r.DLS_Class__c+' / '+timeCard.AcctSeed__Project_Task__r.Name+' / '+timeCard.Location__r.Name;
            //System.debug('timeCard::::::'+ timeCard);
            //System.debug('timeCard.AcctSeed__Time_Card_Days__r::::::'+ timeCard.AcctSeed__Time_Card_Days__r);
            
            for(AcctSeed__Time_Card_Day__c tcDay: timeCard.AcctSeed__Time_Card_Days__r) {
                daySum.totalHours = calculateTotal((tcDay.Total_Hours_Before_Approved__c!= null) ? tcDay.Total_Hours_Before_Approved__c : 0.00, convertStringToDecimal(daySum.totalHours));
                //System.debug('tcDay::::>>>>' + tcDay);
                DayInfo dInfo = new DayInfo();                
                dInfo.dayDate = tcDay.AcctSeed__Date__c.format();
                dInfo.day = tcDay.Week_Day__c;
                dInfo.timeCardDayId = tcDay.Id;
                dInfo.hours = convertDecimalToString(tcDay.Total_Hours_Before_Approved__c);  
                
                if(!dInfo.hours.contains('.')){
                    //System.debug('Hours:::::');
                    dInfo.hours = dInfo.hours + '0.00';
                }              
                if(!dayMap.containsKey(tcDay.AcctSeed__Date__c)) {
                    dayMap.put(tcDay.AcctSeed__Date__c, dInfo);
                }
            }
            
            Map<Date, DayInfo> tempMap = new Map<Date,DayInfo>();
            tempMap = dateMap.clone();
            tempMap.putAll(dayMap);
            
            for(Date da : tempMap.keySet()){  
                Decimal hrs = ConvertStringToDecimal(tempMap.get(da).hours);
                if(tempMap.get(da).day == 'Monday') {                    
                    columnTotal.monTotal = calculateTotal(hrs, convertStringToDecimal(columnTotal.monTotal));
                }
                if(tempMap.get(da).day == 'Tuesday') {
                    columnTotal.tueTotal = calculateTotal(hrs, convertStringToDecimal(columnTotal.tueTotal));
                
                }
                if(tempMap.get(da).day == 'Wednesday') {
                    columnTotal.wedTotal = calculateTotal(hrs, convertStringToDecimal(columnTotal.wedTotal));

                }
                if(tempMap.get(da).day == 'Thursday') {
                    columnTotal.thuTotal = calculateTotal(hrs, convertStringToDecimal(columnTotal.thuTotal));

                }
                if(tempMap.get(da).day == 'Friday') {
                    columnTotal.friTotal = calculateTotal(hrs, convertStringToDecimal(columnTotal.friTotal));

                }
                if(tempMap.get(da).day == 'Saturday') {
                    columnTotal.sunTotal = calculateTotal(hrs, convertStringToDecimal(columnTotal.sunTotal));

                }
                if(tempMap.get(da).day == 'Sunday') {
                    columnTotal.sunTotal = calculateTotal(hrs, convertStringToDecimal(columnTotal.sunTotal));             
                }
                
                daySum.dayRecords.add(tempMap.get(da));
            } 
                       
            daySummary.add(daySum);
        }
        
        oveDayDetails.weekRangeValues = weekRangeVal;
        oveDayDetails.daySummary = daySummary;
        oveDayDetails.columnTotal = columnTotal;
        oveDayDetails.overallSum  = convertDecimalToString(convertStringtoDecimal(columnTotal.monTotal) + convertStringtoDecimal(columnTotal.tueTotal) + convertStringtoDecimal(columnTotal.wedTotal) + convertStringtoDecimal(columnTotal.thuTotal) + convertStringtoDecimal(columnTotal.friTotal) + convertStringtoDecimal(columnTotal.sunTotal));
        //System.debug('ALLIDSS'+ oveDayDetails);
        
        return JSON.serialize(oveDayDetails);
    }
    
 
   public static String convertDecimalToString(Decimal value) {
       String val;
       if(value !=null){
            val = String.valueOf(value);
       }
       return val;
    }
    
    public static Decimal ConvertStringToDecimal(String value) {
       Decimal val;
       if(value !=null){
            val = Decimal.valueOf(value);
       }
       return val;
    }
    
    public static String CalculateTotal(Decimal hrs, Decimal total) {
        return String.valueOf(hrs + total);
    }
    
    public class WeeklySummary {
        public String dateRange;
        public String approvedHours;
        public String pendingHours;
        public String periodId;
    }
    
    public class WeeklySummaryDetails {
        public List<WeeklySummary> WeeklySummary;
        public String totalApprovedTime;
        public String totalPendingTime;
        public Boolean isInstructor;
        public String insId;
    }
    
    public class InstructorSummary {
        public String insId;
        public String insName;
        public String pendingHours;
        public String approvedHours;
        public String timeCardId;
    }
    
    public class InstructorSummaryDetails {
        public List<InstructorSummary> InstructorSummary;
        public String totalPendingHours;
        public String totalApprovedHours;
    }
    
    public class DayInfo {
        public String dayDate;
        public String hours;
        public String timeCardDayId;
        public String day;
   }
   
   public class DaySummary {
       public List<DayInfo> dayRecords;
       public String totalHours;  
       public String chargeCode;
            
   }
   
   public class OverallDaySummary {
       public List<DaySummary> daySummary;
       public String overallSum;
       public columnTotalHours columnTotal;
       public List<WeekRangeValues> weekRangeValues;
   }
   
   public class columnTotalHours{
       public String monTotal;
       public String tueTotal;
       public String wedTotal;
       public String thuTotal;
       public String friTotal;
       public String satTotal;
       public String sunTotal;                   
   }
   
   public class WeekRangeValues {
        public String dateValue;
        public String dayVal;
   } 
    
}