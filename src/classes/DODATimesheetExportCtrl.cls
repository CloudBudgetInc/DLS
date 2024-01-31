public Class DODATimesheetExportCtrl {

    public Id acctId;
    public List<InstructorHoursWrapper> insHoursTable {get; set;}
    public Integer totalCnt {get; set;}
    public String recObjAPIName {get; set;}
    
    public class InstructorHoursWrapper {
    
        public String projName {get; set;}
        public String dlsClass {get; set;}
        public String studNames {get; set;}
        public List<InsHoursList> insHours {get; set;} 
        public List<String> headerStuNames {get; set;}
        public Decimal insHrsTotal {get; set;}
        public Decimal prepHrsTotal {get; set;}
        public List<Decimal> studentHrsTotal {get; set;}
        public Map<String,Decimal> tempStudentHrsTotal {get; set;}
    }
    
    public class InsHoursList {
    
        public string insName {get; set;}
        public date insDate {get; set;}
        public Decimal insHours {get; set;}
        public Decimal prepHours {get; set;}
        public List<StudentHrs> studentDetails {get; set;}
        public List<String> comments {get; set;}
    }
    
    public class StudentHrs {
    
        public string studentName {get; set;}
        public string studentId {get; set;}
        public Decimal hours {get; set;}
        public string comments {get; set;}
        public string attendance {get; set;}
    }
     
    public DODATimesheetExportCtrl() {
    
        acctId = ApexPages.currentPage().getParameters().get('accountId');
        Date sDate = Date.ValueOf(ApexPages.currentPage().getParameters().get('dt1'));
        Date eDate = Date.ValueOf(ApexPages.currentPage().getParameters().get('dt2'));
        recObjAPIName = acctId.getSObjectType().getDescribe().getName();
        String fileName = 'DODA Timesheet.pdf';        
        
        if(recObjAPIName == 'Contact'){
            String studentName = [SELECT Id, Name FROM Contact WHERE Id = :acctId LIMIT 1].Name;
            Datetime dtStartDateTime = datetime.newInstance(sDate.year(), sDate.month(),sDate.day());
            Datetime dtEndDateTime = datetime.newInstance(eDate.year(), eDate.month(),eDate.day());
            fileName = 'Timesheet - '+ studentName +' - '+dtStartDateTime.format('MM.dd.yyyy')+' - '+dtEndDateTime.format('MM.dd.yyyy')+'.pdf';       
        }
          
        //generate the contents
        insHoursTable = constructInsHoursTable(acctId, sDate ,eDate);
        System.debug('insHoursTable::::'+insHoursTable);
        System.debug('startDate::::'+sDate );
        System.debug('endDate::::'+eDate );
        
        //Download the pdf file
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+fileName);
    }
    
    public List<InstructorHoursWrapper> constructInsHoursTable (Id accId, Date startDate, Date endDate) {
        
        List<InstructorHoursWrapper> tempInsList = new List<InstructorHoursWrapper>();
        Set<Id> dodaProjIds = new Set<Id>();
        Map<String, List<InsHoursList>> projNameInsHoursListMap = new Map<String, List<InsHoursList>>();
        Map<String, String> projNamestudentNameMap = new Map<String, String>();         
        Map<String, Decimal> projKeyAndPrepHoursMap = new Map<String, Decimal>();
        
        Set<Id> tcdIds = new Set<Id>();
        Map<Id,List<StudentHrs>> tcdIdAttendanceList = new Map<Id,List<StudentHrs>>();
        Map<Id,StudentHrs> stuIdDetailMap = new Map<Id,StudentHrs>();
        Map<Id,List<String>> proIdstudentNames = new Map<Id,List<String>>();
        
        Map<String,Map<Id,StudentHrs>> proIdTCDIdStuIdRecMap = new Map<String,Map<Id,StudentHrs>>();
        Map<String,String> proNameIdMap = new Map<String,String>();
        Map<Id,Set<Id>> proIdStudentIds = new Map<Id,Set<Id>>();
        Map<Id,List<String>> tcdIdComments = new Map<Id,List<String>>();
        
        Set<Id> projectIds = new Set<Id>();
        Map<String,String> proNameClassNoMap = new Map<String,String>();
        Set<Id> projectIdsRelatedToCon = new Set<Id>();
        
        if(recObjAPIName == 'Contact'){
        
            for(Contact_Assignments__c con : [SELECT Id, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :accId AND RecordType.DeveloperName = 'Student']){
                projectIdsRelatedToCon.add(con.Project__c);
            }         
            
            for(AcctSeed__Time_Card_Day__c tcd : [SELECT Id,Name,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,
                                                        AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,
                                                        Total_Hours_Before_Approved__c
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                        WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != null AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :projectIdsRelatedToCon
                                                         AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Billable__c = TRUE                                                      
                                                         AND AcctSeed__Date__c >=: startDate AND AcctSeed__Date__c <=: endDate AND Project_Task_Type__c = 'preparation time' 
                                                            Order By AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Date__c ASC]) {
                
                String mapKey = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name + 
                                tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name +
                                    tcd.AcctSeed__Date__c;
                                    
                projKeyAndPrepHoursMap.put(mapKey,tcd.Total_Hours_Before_Approved__c);
            }
        }
        
        if(recObjAPIName == 'Account'){
            for(AcctSeed__Time_Card_Day__c tcd : [SELECT Id,Name,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,
                                                        AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Hours__c,
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Students__c,Project_Task_Type__c,
                                                        Total_Hours_Before_Approved__c,Cancellation_Reason__c 
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                        WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != null AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__c = :accId 
                                                            AND AcctSeed__Date__c >=: startDate AND AcctSeed__Date__c <=: endDate AND Project_Task_Type__c = 'preparation time' 
                                                           Order By AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Date__c ASC]) {
                
                String mapKey = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name + 
                                tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name +
                                    tcd.AcctSeed__Date__c;
                                    
                projKeyAndPrepHoursMap.put(mapKey,tcd.Total_Hours_Before_Approved__c);
                
                if(!proNameIdMap.containsKey(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name)){
                    proNameIdMap.put(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
                }
                
                projectIds.add(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
            }
        }
        
        string tcdQryStr = 'SELECT Id,Name,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,'
                           +'AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name,AcctSeed__Hours__c ,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Students__c,'
                           +'Project_Task_Type__c,Total_Hours_Before_Approved__c,Cancellation_Reason__c '
                           +' FROM AcctSeed__Time_Card_Day__c' 
                           +' WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != null AND AcctSeed__Date__c >=: startDate AND AcctSeed__Date__c <=: endDate AND '
                           +' Project_Task_Type__c != \'preparation time\' ';
                           
        if(recObjAPIName == 'Contact'){
            tcdQryStr +=  ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectIdsRelatedToCon ';
        }else{
            tcdQryStr += ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.AcctSeed__Account__c = :accId '
                            +'AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != \'Testing_Projects\' ';
        }
                           
                           
        tcdQryStr += 'Order By AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,AcctSeed__Date__c ASC';
        
        List<AcctSeed__Time_Card_Day__c> tcdList = database.query(tcdQryStr);
        
        
        for(AcctSeed__Time_Card_Day__c tcd : tcdList){
        
            tcdIds.add(tcd.Id);
            
            if(!proNameIdMap.containsKey(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name)){
                proNameIdMap.put(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
            }
            
            projectIds.add(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);
        }
        
        system.debug('::::::tcdIds::::::'+tcdIds);
        system.debug('::::::::::proNameIdMap:::'+proNameIdMap);
        system.debug(':::::::::projectIdsRelatedToCon'+projectIdsRelatedToCon);
        
        //Qry project for sorting order
        for(AcctSeed__Project__c pro : [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c 
                                        WHERE Id IN :projectIds ORDER BY Project_Type__c DESC,Language__r.Name ASC]){
            
            if(!projNameInsHoursListMap.containsKey(pro.Name)){
                projNameInsHoursListMap.put(pro.Name,new List<InsHoursList>());
            }
            
            if(!proNameClassNoMap.containsKey(pro.Name)){
                proNameClassNoMap.put(pro.Name,pro.DLS_Class__c);
            }
        }
        
        //Qry attendace information for all tcds
        List<Attendance__c> attendanceList = [SELECT Id,Name,Date__c,Instructor__c,Instructor__r.Name,Student__c,Comments__c,
                                                    Student__r.Name,Time_Card_Day__c,Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,
                                                    Student_Name__c,Duration__c, Attendance__c 
                                                FROM Attendance__c 
                                                WHERE Time_Card_Day__c IN :tcdIds ORDER BY Student__r.Name ASC];
                                    
        
        Set<String> studentIds = new Set<String>();  
              
        for(Attendance__c att : attendanceList){
        
            if(!stuIdDetailMap.containsKey(att.Student__c)){
            
                StudentHrs stuHrs = new StudentHrs();
                stuHrs.studentName = att.Student_Name__c;
                stuHrs.studentId = att.Student__c;
                stuHrs.hours = 0.00;
                stuHrs.comments = '';
                stuHrs.attendance = att.Attendance__c;
                
                stuIdDetailMap.put(att.Student__c,stuHrs);
            }
            
            Id proId = att.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            
            if(!proIdstudentNames.containsKey(proId)){
                proIdstudentNames.put(proId,new List<String>{att.Student_Name__c});
                
            }else if(!studentIds.contains(proId+'-'+att.Student__c)){
                proIdstudentNames.get(proId).add(att.Student_Name__c);
            }
            
            studentIds.add(proId+'-'+att.Student__c);
            
            if(!proIdStudentIds.containsKey(proId)){
                proIdStudentIds.put(proId,new Set<Id>{att.Student__c});
                
            }else {
                proIdStudentIds.get(proId).add(att.Student__c);
            }
        }
        
        system.debug('::::::::::proIdstudentNames:::'+proIdstudentNames);
        system.debug(':::::::::::proIdStudentIds:::'+proIdStudentIds);
        
        for(Attendance__c att : attendanceList){
            
            String key = att.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c+'~'+att.Time_Card_Day__c;
            
            if(!proIdTCDIdStuIdRecMap.containsKey(key)){
            
                StudentHrs stuHrs = new StudentHrs();
                stuHrs.studentName = att.Student_Name__c;
                stuHrs.studentId = att.Student__c;
                stuHrs.hours = att.Duration__c;
                stuHrs.comments = att.Comments__c;
                stuHrs.attendance = att.Attendance__c;
                
                proIdTCDIdStuIdRecMap.put(key,new Map<Id,StudentHrs>{att.Student__c => stuHrs});
            }else {
            
                StudentHrs stuHrs = new StudentHrs();
                stuHrs.studentName = att.Student_Name__c;
                stuHrs.studentId = att.Student__c;
                stuHrs.hours = att.Duration__c;
                stuHrs.comments = att.Comments__c;
                stuHrs.attendance = att.Attendance__c;
                
                proIdTCDIdStuIdRecMap.get(key).put(att.Student__c,stuHrs);
            }
            
            if(!tcdIdComments.containsKey(att.Time_Card_Day__c) && att.Comments__c != null) {
            
                tcdIdComments.put(att.Time_Card_Day__c,new List<String>{att.Comments__c});
                
            }else if(att.Comments__c != null){
                
                tcdIdComments.get(att.Time_Card_Day__c).add(att.Comments__c);
            }
            
        }
        
        system.debug(':::::::proIdTCDIdStuIdRecMap:::'+proIdTCDIdStuIdRecMap);
        system.debug('::::::::tcdIdComments:::::'+tcdIdComments);
        
        for(Id stuId : stuIdDetailMap.keySet()){
        
            for(String key : proIdTCDIdStuIdRecMap.keySet()){
                
                Id proId = (Id) key.split('~')[0];
                Id tcdId = (Id) key.split('~')[1];
                
                if(proIdTCDIdStuIdRecMap.get(key).containsKey(stuId)){
                
                    if(!tcdIdAttendanceList.containsKey(tcdId)) {
                    
                        tcdIdAttendanceList.put(tcdId,new List<StudentHrs>{proIdTCDIdStuIdRecMap.get(key).get(stuId)});
                        
                    }else {
                        tcdIdAttendanceList.get(tcdId).add(proIdTCDIdStuIdRecMap.get(key).get(stuId));
                    }
                    
                }else if(proIdStudentIds.containsKey(proId) && proIdStudentIds.get(proId).contains(stuId)){
                
                    if(!tcdIdAttendanceList.containsKey(tcdId)) {
                    
                        tcdIdAttendanceList.put(tcdId,new List<StudentHrs>{stuIdDetailMap.get(stuId)});
                        
                    }else {
                        tcdIdAttendanceList.get(tcdId).add(stuIdDetailMap.get(stuId));
                    }
                }
            }
        }
        
        system.debug(':::::::::tcdIdAttendanceList::::'+tcdIdAttendanceList);
        system.debug(':::::::::projKeyAndPrepHoursMap::::'+projKeyAndPrepHoursMap);

        
        for (AcctSeed__Time_Card_Day__c tcd : tcdList) {
            
            String mKey = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name + 
                            tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name +
                                tcd.AcctSeed__Date__c;
                                
            if(!projNameInsHoursListMap.containskey(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name) ) {
                
                
                InsHoursList ins = new InsHoursList();
                ins.insName = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
                ins.insDate = tcd.AcctSeed__Date__c;
                ins.insHours = tcd.Total_Hours_Before_Approved__c;
                ins.prepHours = projKeyAndPrepHoursMap.containskey(mkey) ? projKeyAndPrepHoursMap.get(mKey) : 0.00; 
                
                
                if(tcdIdAttendanceList.containsKey(tcd.Id)){
                
                    ins.studentDetails = tcdIdAttendanceList.get(tcd.Id);
                }else {
                    Id proId = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                    
                    if(proIdStudentIds.containsKey(proId)){
                        Integer total = proIdStudentIds.get(proId).size();
                        
                        ins.studentDetails = new List<StudentHrs>();
                        
                        for(Integer i = 0; i < total;i++){
                            StudentHrs stuHrs = new StudentHrs();
                            stuHrs.studentName = '';
                            stuHrs.studentId = '';
                            stuHrs.hours = 0.00;
                            stuHrs.comments = '';
                            stuHrs.attendance = '';
                            
                            ins.studentDetails.add(stuHrs);
                        }
                    }
                }
                
                if(tcd.Cancellation_Reason__c != null){
                    ins.comments = new List<String>{tcd.Cancellation_Reason__c};
                }else {
                    ins.comments = new List<String>();    
                }
                
                if(tcdIdComments.containsKey(tcd.Id)){
                    ins.comments.addAll(tcdIdComments.get(tcd.Id));
                }
                
                projNameInsHoursListMap.put(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name, new List<InsHoursList>{ins});
                projNamestudentNameMap.put(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Students__c);
                
            } else {
                
                InsHoursList ins = new InsHoursList();
                ins.insName = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
                ins.insDate = tcd.AcctSeed__Date__c;
                ins.insHours = tcd.Total_Hours_Before_Approved__c;
                
                if(tcdIdAttendanceList.containsKey(tcd.Id)){
                    
                    ins.studentDetails = tcdIdAttendanceList.get(tcd.Id);
                }else {
                    Id proId = tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                    
                    
                    if(proIdStudentIds.containsKey(proId)){
                        Integer total = proIdStudentIds.get(proId).size();
                        
                        ins.studentDetails = new List<StudentHrs>();
                        
                        for(Integer i = 0; i < total;i++){
                            StudentHrs stuHrs = new StudentHrs();
                            stuHrs.studentName = '';
                            stuHrs.studentId = '';
                            stuHrs.hours = 0.00;
                            stuHrs.comments = '';
                            stuHrs.attendance = '';
                            
                            ins.studentDetails.add(stuHrs);
                        }
                    }
                }
                
                if(tcd.Cancellation_Reason__c != null){
                    ins.comments = new List<String>{tcd.Cancellation_Reason__c};
                }else {
                    ins.comments = new List<String>();    
                }
                
                if(tcdIdComments.containsKey(tcd.Id)){
                    ins.comments.addAll(tcdIdComments.get(tcd.Id));
                }
                
                ins.prepHours = projKeyAndPrepHoursMap.containskey(mkey) ? projKeyAndPrepHoursMap.get(mKey) : 0.00;
                projNameInsHoursListMap.get(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name).add(ins);
                
            }
            
        }
        
        for(String proName : projNameInsHoursListMap.keySet()) {
            
            system.debug(':::::::proName:::'+proName);
            
            InstructorHoursWrapper ihw = new InstructorHoursWrapper();
            ihw.projName = proName;
            ihw.dlsClass = proNameClassNoMap.containsKey(proName) ? proNameClassNoMap.get(proName) : '';
            ihw.studNames = projNamestudentNameMap.containskey(proName) ? projNamestudentNameMap.get(proName) : '';
            ihw.insHours = projNameInsHoursListMap.get(proName);
            
            
            if(proNameIdMap.containsKey(proName)){
                string proId = proNameIdMap.get(proName);
                ihw.headerStuNames = proIdstudentNames.containskey(proId) ? proIdstudentNames.get(proId) : new List<String>{};
            }
            
            //Calculate totalhours
            
            ihw.insHrsTotal = 0.00;
            ihw.prepHrsTotal = 0.00;
            ihw.tempStudentHrsTotal = new Map<String,Decimal>();
            ihw.studentHrsTotal = new List<Decimal>();
            
            //For Instructor & Preparation Hrs total
            for(InsHoursList ins : ihw.insHours){
                ihw.insHrsTotal += ins.insHours;
                ihw.prepHrsTotal += ins.prepHours;
                
                //For student Hrs
                
                Map<String,Decimal> tempStudentHrsTotal = new Map<String,Decimal>();
                
                if(ins.studentDetails != null && ins.studentDetails.size() > 0) {
                        
                    for(StudentHrs stuHrs : ins.studentDetails){
                        
                        if(String.isNotBlank(stuHrs.studentId)) {
                                                        
                            if(!ihw.tempStudentHrsTotal.containsKey(stuHrs.studentId)){
                            
                                ihw.tempStudentHrsTotal.put(stuHrs.studentId,stuHrs.hours);
                                
                            }else {
                            
                                Decimal hrs = ihw.tempStudentHrsTotal.get(stuHrs.studentId) + stuHrs.hours;
                                ihw.tempStudentHrsTotal.put(stuHrs.studentId,hrs);
                            }
                        }
                    }
                }
            }
            
            for(String key : ihw.tempStudentHrsTotal.keySet()){
                ihw.studentHrsTotal.add(ihw.tempStudentHrsTotal.get(key));
            }
            
            tempInsList.add(ihw);
        }
        
        system.debug('::::::tempInsList::::'+tempInsList);
        
        totalCnt = tempInsList.size();
        
        return tempInsList;
    }
    
    @AuraEnabled
    public static string getInitialDate(){
        
        Date currWkSt = system.today().toStartofWeek().addDays(1);
        Date currWkEnd = currWkSt.addDays(6);
        
        Date stDt = currWkSt.addDays(-7);
        Date edDt = stDt.addDays(6);
        
        string dt1 = string.valueOf(stDt).split(' ')[0];
        string dt2 = string.valueOf(edDt).split(' ')[0];
        
        
        //string result = dt1.split('-')[1]+'/'+dt1.split('-')[2]+'/'+dt1.split('-')[0]+'-'+dt2.split('-')[1]+'/'+dt2.split('-')[2]+'/'+dt2.split('-')[0];
        
        string result = dt1+'/'+dt2;
        system.debug(':::::::result:::'+result);
        return result;
    }
}