public class AdminTimesheetExport_Ctrl {
    public String instructorId;
    public String projectId;
    public String isBillable;
    public InstructorRowDetails adminTimeInfo {get; set;}
    
    
    public class InstructorRowDetails {
        public List<WeekRangeValues> weekDates {get; set;}
        public List<InstructorDayDetails> entries {get; set;}
        public List<NotesDetails> notes {get; set;}
        public String  instructorName {get; set;}
        public String  dlsClassNo {get; set;}
        public String projectRTName {get; set;}
        public List<StudentTimeDetail> studentEntries {get; set;}
        public TotalHrsDayWrapper totalHrsDayColEntries {get; set;}
    }
    public class WeekRangeValues {
        public String dateValue {get; set;}
        public String dayVal {get; set;}
    } 
    
    //For Student Approval
    public class TotalHrsDayWrapper{
        public String monHrs {get; set;}
        public String tueHrs {get; set;}     
        public String wedHrs {get; set;}
        public String thuHrs {get; set;}
        public String friHrs {get; set;}
        public String satHrs {get; set;}
        public String sunHrs {get; set;}
        public String TotaldayHrs {get; set;}
    }
    //For Student Attendance Time Details
    public class StudentTimeDetail {
        public String studentName{get; set;}
        public List<StudentEntry> entries {get; set;}
        public String totalHours {get; set;}
    }
    
    public class StudentEntry {
        public Date dateVal {get; set;}
        public String attendance {get; set;}
        public String dayValue {get; set;}
        public String hours {get; set;}
        public string studentApprovalStatus {get; set;}
        public String color {get; set;}
        public String displayNotesLink {get; set;}
    }
    public class InstructorDayDetails {
        public String chargeCode1 {get; set;}
        public List<DayEntries> dayEntries {get; set;}
        public String totalHours {get; set;}
        public Integer timeRowCount {get; set;}
        public String taskType {get; set;}
        public Integer sequenceNumber {get; set;}
    }
    
    public class DayEntries {
        public Decimal hours {get; set;}
        public Id dayId {get; set;}
        public String status {get; set;}
        public Date dateVal {get; set;}
        public String studentApprovalStatus {get; set;}
        public String color {get; set;}
        public Boolean lateCancellation {get; set;}
        public String startTime1 {get; set;}
        public String endTime1 {get; set;}
        public String startTime2 {get; set;}
        public String endTime2 {get; set;}
        public String displayDate {get; set;}
        public String dayHours {get; set;}
        public String dayType {get; set;}
    }
    
    public class NotesDetails {
        public String notes {get; set;}
    }
    
    
    public AdminTimesheetExport_Ctrl() {
        
        instructorId = ApexPages.currentPage().getParameters().get('contactId');
        String sDate = ApexPages.currentPage().getParameters().get('dt1');
        String eDate = ApexPages.currentPage().getParameters().get('dt2');
        projectId = ApexPages.currentPage().getParameters().get('projectId'); 
        isBillable = ApexPages.currentPage().getParameters().get('isBillable'); 
        String fileName;
        
        if(isBillable == null){
            isBillable = 'true';
        }
        
        if(instructorId != null && projectId != null && eDate != null && sDate != null){
            adminTimeInfo = getTimeRowsRelatedInformation( Date.ValueOf(sDate), Date.ValueOf(eDate),projectId,instructorId, isBillable);
            System.debug('adminTimeInfo'+adminTimeInfo.weekDates);
            
            list<String> splitStDate = sDate.split('-');
            String startDtStr = (splitStDate[2]+'-'+splitStDate[1]+'-'+splitStDate[0]);
            
            list<String> splitEndDate = eDate.split('-');
            String endDtStr = (splitEndDate[2]+'-'+splitEndDate[1]+'-'+splitEndDate[0]);
            
            fileName = adminTimeInfo.dlsClassNo +' - '+adminTimeInfo.instructorName+' - '+startDtStr+' - '+endDtStr;
            //Download the pdf file
            Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename= '+fileName+'.pdf');
        }
    }
    
    public static InstructorRowDetails getTimeRowsRelatedInformation(Date stDate,Date endDate,String projectId,String instructorId, String isBillable){
        
        Set<Id> taskId = new Set<Id>();
        Set<Id> tcdIds = new Set<Id>();
        String filterCondition = '';
        filterCondition += isBillable == 'true' ? ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c = true' : '';
        filterCondition += ' ORDER BY AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c ASC';
        String studentNames = '';
        
        List<Contact> insContact = [SELECT Name FROM Contact WHERE Id = :instructorId];
        List<Contact_Assignments__c> cAStudentList = ContactAssignmentService.getContactassignmentByprojectId(' WHERE Project__c = \''+projectId+'\' AND RecordType.DeveloperName = \'Student\' AND Status__c = \'Active\'',' Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Candidate_Name__r.Name',null,''); //[SELECT Id,Candidate_Name__c,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Candidate_Name__r.Name,Status__c FROM Contact_Assignments__c WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active'];
        List<Accounting_Seed_Time_Snapshot__c> accTimesnapshot = new List<Accounting_Seed_Time_Snapshot__c>();
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Project_Task__c>  proTask = [SELECT Id ,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projectId ORDER BY Project_Task_Type__c DESC ];
        List<AcctSeed__Project__c> projectRecord = [SELECT Id,Name,RecordType.DeveloperName,DLS_Class__c,No_Student_Approval__c FROM AcctSeed__Project__c WHERE Id = :projectId];
        String projectRTName = projectRecord[0].RecordType.DeveloperName;
        
        Date st = stDate;
        Date ed = endDate;        
        List<WeekRangeValues> weekDates = new List<WeekRangeValues>();
        Map<Date,DayEntries> dateEntryMap = new Map<Date,DayEntries>();      
        InstructorRowDetails weekDetails = new InstructorRowDetails();
        
        while(st <= ed){
            WeekRangeValues wkVal = new WeekRangeValues();
            wkVal.dateValue = String.valueOf(st).split('-')[1]+'/'+String.valueOf(st).split('-')[2]+'/'+String.valueOf(st).split('-')[0];
            DateTime todayVal = DateTime.newInstance(st, Time.newInstance(0, 0, 0, 0));
            wkVal.dayVal = todayVal.format('EEE').toUppercase();
            weekDates.add(wkVal);
            
            
            DayEntries day = new DayEntries();
            
            day.dayHours = '';
            day.dateVal = st;
            day.lateCancellation = false;
            day.status = '';
            day.displayDate = wkVal.dateValue;
            dateEntryMap.put(st,day);
            
            //W-005862 - Timesheet PDF issue - Modified by Dhinesh
            st = st.addDays(1);
        }
        
        for(Contact_Assignments__c stu : cAStudentList){
            studentNames += stu.Candidate_Name__r.FirstName+'.'+stu.Candidate_Name__r.LastName.subString(0,1)+'/ ';
        }
        
        for(AcctSeed__Project_Task__c proTsk : proTask){
            taskId.add(proTsk.Id);
        }
        
        // Get Time Card Line with Days records
        if(projectRecord.size() > 0) {
            weekDetails.dlsClassNo = projectRecord[0].DLS_Class__c;
            timeCardLineList = TimeCardLineService.getTCL_dayRecords(filterCondition,new Set<Id>{projectId},taskId,stDate,endDate,instructorId);
        }
        
        for(AcctSeed__Time_Card_Line__c timeLine : timeCardLineList) {
            if(timeLine.AcctSeed__Time_Card_Days__r.size() > 0){
                for(AcctSeed__Time_Card_Day__c tcd : timeLine.AcctSeed__Time_Card_Days__r){
                    tcdIds.add(tcd.Id);
                }
            }
        }
        
        if(tcdIds.size() > 0){
            // Get notes information
            accTimesnapshot = TimeSnapshotService.getSnpshotWithDaysIds(tcdIds);
        }
        
        //Qry attendace information for all tcds
        Set<Id> studentIds = new Set<Id>();
        
        if(projectRTName == 'DLI_W_LT_Projects' || projectRTName == 'DODA_Projects' || (projectRTName == 'Language_Training_Projects')){
            for(Contact_Assignments__c ca : cAStudentList){
                studentIds.add(ca.Candidate_Name__c);
            }
        }
        
        List<Attendance__c> stuAttendanceList = [SELECT Id,Name,Student__c,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c,
                                                 Event__c,Time_Card_Day__c,Rejection_Reason__c,Time_Card_Day__r.Status__c,Recall_Reason__c,Comments__c,
                                                 Student__r.Name,Time_Card_Day__r.Total_Hours_Before_Approved__c,Time_Card_Day__r.Late_Cancellation__c,Event__r.No_Student_Approval__c, Attendance__c FROM Attendance__c 
                                                 WHERE Student__c IN :studentIds AND (Date__c >= :stDate AND Date__c <= :endDate) AND Instructor__c = :instructorId
                                                 AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId 
                                                 AND Time_Card_Day__c IN :tcdIds ORDER BY Student__r.Name ASC];
        
        TotalHrsDayWrapper TotalHrsDayColumn = new TotalHrsDayWrapper();  
        TotalHrsDayColumn.monHrs = '0.00';
        TotalHrsDayColumn.tueHrs = '0.00';
        TotalHrsDayColumn.wedHrs = '0.00';
        TotalHrsDayColumn.thuHrs = '0.00';
        TotalHrsDayColumn.friHrs = '0.00';
        TotalHrsDayColumn.satHrs = '0.00';
        TotalHrsDayColumn.sunHrs = '0.00';
        TotalHrsDayColumn.TotaldayHrs = '0.00';
        
        if(insContact.size() > 0){
            weekDetails.instructorName = insContact[0].Name;
        }
        
        List<InstructorDayDetails> dayDetailEntryLst = new List<InstructorDayDetails>();
        List<InstructorDayDetails> dayDetailInfoList = new List<InstructorDayDetails>();
        Map<Integer,InstructorDayDetails> seqNum_DetailsMap = new Map<Integer,InstructorDayDetails>();
        List<Integer> seqNumbers = new List<Integer>();
        
        Set<Id> timeLineIdSet = new Set<Id>();
        
        //Query Existing TimeCardLine records 
        if(projectRecord.size() > 0) {
            if(timeCardLineList.size() > 0) {
                for(AcctSeed__Time_Card_Line__c  line: timeCardLineList){
                    
                    Decimal totalHrs = 0.00;
                    Integer timeRowCount = 1;
                    Date stDt = stDate;
                    Date endDt = endDate;
                    
                    Date sDate = stDate;
                    Date eDate = endDate;
                    
                    InstructorDayDetails dayDetails  = new InstructorDayDetails();
                    Map<Date,DayEntries> dayMap = new Map<Date,DayEntries>();
                    List<DayEntries> dayDetailsList = new List<DayEntries>();
                    List<DayEntries> dayInfoList = new List<DayEntries>();
                    dayDetails.chargeCode1 = projectRecord[0].DLS_Class__c+'/<b>'+line.AcctSeed__Project_Task__r.Name+'</b>/<br/>'+studentNames+line.Location__r.Name;
                    dayDetails.taskType = line.AcctSeed__Project_Task__r.Project_Task_Type__c;
                    timeLineIdSet.add(line.Id);
                    
                    if(dayDetails.taskType == 'Language Training'){
                        dayDetails.sequenceNumber = 1;  
                    }else if(dayDetails.taskType == 'Preparation time'){
                        dayDetails.sequenceNumber = 2; 
                    }  
                    if(line.AcctSeed__Time_Card_Days__r.size() > 0) {
                        for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                            if(day.Status__c != 'Unposted' && ((dayDetails.taskType == 'Preparation time') || (dayDetails.taskType == 'Language Training'))){
                                
                                DayEntries dayRec = new DayEntries();
                                dayRec.dayHours = ''+day.Total_Hours_Before_Approved__c;
                                dayRec.dayId = day.Id;
                                dayRec.dayType = day.Week_Day__c;      
                                dayRec.studentApprovalStatus = day.Student_Approval_Status__c;
                                dayRec.endTime1 = day.End_Time1__c;
                                dayRec.startTime1 =  day.Start_Time1__c;
                                dayRec.lateCancellation = day.Late_Cancellation__c;
                                totalHrs = totalHrs+day.Total_Hours_Before_Approved__c;
                                
                                if(line.AcctSeed__Project_Task__r.Name == 'Language Training- Preparation' && dayDetails.taskType == 'Preparation time') {
                                    dayRec.startTime2 = day.Start_Time2__c;
                                    dayRec.endTime2 = day.End_Time2__c;
                                }
                                
                                if(!dayMap.containsKey(day.AcctSeed__Date__c)) {
                                    dayMap.put(day.AcctSeed__Date__c,dayRec);
                                }
                                system.debug(dayMap);
                            }
                        }
                        dayDetails.timeRowCount = timeRowCount;
                        dayDetails.totalHours = String.valueOf(totalHrs);                        
                        dayDetailEntryLst.add(dayDetails);
                        Map<Date,DayEntries> tempMap = new Map<Date,DayEntries>();
                        tempMap = dateEntryMap.clone();
                        tempMap.putAll(dayMap);
                        while(sDate <= eDate){
                            if(tempMap.containsKey(sDate)){
                                dayDetailsList.add(tempMap.get(sDate));  
                            }
                            sDate = sDate.addDays(1);   
                        }
                        
                        dayDetails.dayEntries = dayDetailsList;
                    }
                } 
                //To display the row details in order 
                for(InstructorDayDetails detail : dayDetailEntryLst){
                    if(!seqNum_DetailsMap.containsKey(detail.sequenceNumber)){
                        seqNum_DetailsMap.put(detail.sequenceNumber,detail);
                    }
                    seqNumbers.add(detail.sequenceNumber);
                }
                
                seqNumbers.sort();
                for(Integer num : seqNumbers){
                    if(seqNum_DetailsMap.containsKey(num)){
                        dayDetailInfoList.add(seqNum_DetailsMap.get(num));
                    }
                }
                
                weekDetails.entries = dayDetailInfoList;
            }
            
            system.debug(dayDetailEntryLst);
            // get column  Total hours values
            for(InstructorDayDetails tcl : dayDetailEntryLst){
                for(DayEntries tcd : tcl.dayEntries) {
                    if(tcd.dayHours != ''){
                        if(tcd.dayType == 'Monday'){
                            TotalHrsDayColumn.monHrs =  String.valueOf(Decimal.valueOf(TotalHrsDayColumn.monHrs) + Decimal.valueOf(tcd.dayHours));
                        }else if(tcd.dayType == 'Tuesday'){
                            TotalHrsDayColumn.tueHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.tueHrs) + Decimal.valueOf(tcd.dayHours));
                        }else if(tcd.dayType == 'Wednesday'){
                            TotalHrsDayColumn.wedHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.wedHrs) + Decimal.valueOf(tcd.dayHours));
                        }else if(tcd.dayType == 'Thursday'){
                            TotalHrsDayColumn.thuHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.thuHrs) + Decimal.valueOf(tcd.dayHours));
                        }else if(tcd.dayType == 'Friday'){
                            TotalHrsDayColumn.friHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.friHrs) + Decimal.valueOf(tcd.dayHours));
                        }else if(tcd.dayType == 'Saturday'){
                            TotalHrsDayColumn.satHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.satHrs) + Decimal.valueOf(tcd.dayHours));
                        }else if(tcd.dayType == 'Sunday'){
                            TotalHrsDayColumn.sunHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.sunHrs) + Decimal.valueOf(tcd.dayHours));
                        }
                        TotalHrsDayColumn.TotaldayHrs = String.valueOf(Decimal.valueOf(TotalHrsDayColumn.TotaldayHrs) + Decimal.valueOf(tcd.dayHours));
                    }
                }
            }
            
            weekDetails.TotalHrsDayColEntries = TotalHrsDayColumn; 
        }
        
        // Get Student Attendance Records
        if(stuAttendanceList.size() > 0){
            
            // Student Attendance Records Formation
            Map<Id,List<Attendance__c>> studentIdAttendanceList = new Map<Id,List<Attendance__c>>();
            if(studentIds.size() > 0){
                for(Attendance__c att : stuAttendanceList){
                    
                    if(!studentIdAttendanceList.containsKey(att.Student__c)){
                        studentIdAttendanceList.put(att.Student__c,new List<Attendance__c>{att});
                    }else {
                        studentIdAttendanceList.get(att.Student__c).add(att);
                    }
                }
            }
            String stuTime =  JSON.serialize(TimeCardDayCommunityTranslator.studentTimeEntriesFormation(cAStudentList,stDate,endDate,studentIdAttendanceList,false,false));
            List<StudentTimeDetail> stuTimeEntries = (List<StudentTimeDetail>) JSON.deserialize(stuTime, List<StudentTimeDetail>.class);
            weekDetails.studentEntries = stuTimeEntries; 
        }
        
        // Get Notes Information
        if(accTimesnapshot.size() > 0){
            String notes = JSON.serialize(TimeCardDayCommunityTranslator.notesFormation(accTimesnapshot));
            weekDetails.notes = (List<NotesDetails>) JSON.deserialize(notes, List<NotesDetails>.Class);
        }
        weekDetails.weekDates = weekDates;
        weekDetails.projectRTName = projectRTName;
        
        return weekDetails;
    }
}