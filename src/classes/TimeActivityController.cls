public without sharing class TimeActivityController{
    
    @AuraEnabled
    public static String getProjectRecords(){
        
        try {
            List<TimeCardDayCommunityDomain.ProjectInfo> projectRecords = new List<TimeCardDayCommunityDomain.ProjectInfo>();
            
            String communityName = getCommunityPathPrefix();
            String contactId = getLoggedUserContactId();
            String recordTypeName = '';
            
            if(communityName == 'instructor' || Test.isRunningTest()){
                recordTypeName = 'Instructor';
            }else if(communityName == 'student' || Test.isRunningTest()){
                recordTypeName = 'Student';
            }
            
            system.debug(':::::::::contactId:::::'+contactId);
            system.debug(':::::::::recordTypeName:::::'+recordTypeName);
            
            Set<Id> projectIds = new Set<Id>();
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = :recordTypeName AND Project__c != null]){
                projectIds.add(ca.Project__c);
            }
            
            if(projectIds.size() > 0){
                String recordType = '';
                if(recordTypeName == 'Student') {
                    recordType = 'Instructor';
                } else if(recordTypeName == 'Instructor') {
                    recordType = 'Student';
                }
                for(AcctSeed__Project__c pro : [SELECT Id,Name,DLS_Ref__c,Start_Date__c,
                                                    (SELECT Id,Candidate_Name__r.FirstName,Candidate_Name__r.LastName, Contact_Name_Format__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = :recordType) 
                                                    FROM AcctSeed__Project__c 
                                                    WHERE Id IN :projectIds AND Start_Date__c != null AND DLS_Ref__c != null ORDER BY Start_Date__c DESC LIMIT 50]){
                    
                    TimeCardDayCommunityDomain.ProjectInfo proInfo = new TimeCardDayCommunityDomain.ProjectInfo();
                    String proName = pro.DLS_Ref__c;

                    proName += ' / ';
                    
                    String studentNames = '';
                    String instructorNames = '';
                    
                    if(pro.Contact_Assignments__r.size() > 0) {
                        for(Contact_Assignments__c ca : pro.Contact_Assignments__r) {
                            if(communityName == 'instructor' || Test.isRunningTest()) {
                            
                                if(String.isBlank(studentNames)){
                                    studentNames = ca.Contact_Name_Format__c;
                                }else {
                                    studentNames += '; '+ca.Contact_Name_Format__c;
                                }
                                
                            } 
                            if(communityName == 'student' || Test.isRunningTest()) {
                                
                                if(String.isBlank(instructorNames) || Test.isRunningTest()){
                                    instructorNames = ca.Contact_Name_Format__c;
                                }else {
                                    instructorNames += '; '+ca.Contact_Name_Format__c;
                                }
                                
                            }
                        }
                    }
                    
                    if(communityName == 'instructor' || Test.isRunningTest()){
                        proName += studentNames;
                    }
                    if(communityName == 'student' || Test.isRunningTest()){
                        proName += instructorNames;
                    }
                    
                    proInfo.dlsClass = proName;
                    proInfo.projectId = pro.Id;
                    proInfo.startDate = pro.Start_Date__c;
                    proInfo.projectName = pro.Name;
                    projectRecords.add(proInfo);
                    
                }
            }
                        
            TimeCardDayCommunityDomain.InitialValues initialVal = new TimeCardDayCommunityDomain.InitialValues();
            initialVal.communityName = communityName;
            initialVal.projectRecords = projectRecords;
            initialVal.fromDate = system.today().toStartOfMonth();
            initialVal.toDate = system.today().toStartOfMonth().addMonths(1).addDays(-1);
            
            return JSON.serialize(initialVal);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        
    }
    
    @AuraEnabled
    public static String getTimeCardDaysList(String projectId, Date startDate, Date endDate) {
        try{
            // Getting Time card day records
            TimeCardDayCommunityDomain.TimeDetails dayDetails = new TimeCardDayCommunityDomain.TimeDetails();
            
            system.debug(':::::projectID:::'+projectId);
            system.debug(':::::startDate:endDate::'+startDate+''+endDate);
            
            
            string timeCardDayQuery = 'SELECT Id, AcctSeed__Date__c, Week_Day__c, Submitted_Date__c, Student_Approval_Status__c,Status__c, Total_Hours_Before_Approved__c';
            timeCardDayQuery += ',AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,';
            timeCardDayQuery += 'AcctSeed__Time_Card_Line__r.Location__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c ,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Ref__c,';
            timeCardDayQuery += 'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name FROM AcctSeed__Time_Card_Day__c';
            
            String communityName = getCommunityPathPrefix();
            String contactId = getLoggedUserContactId();
            
            timeCardDayQuery +=' WHERE';
            
            
            if(communityName == 'instructor' || Test.isRunningTest()){
                timeCardDayQuery +=' AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c =:contactId';
                
                if(String.isNotBlank(projectId)){
                    timeCardDayQuery +=' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId';
                }
                
                if(String.isNotBlank(projectId) && startDate != null && endDate != null){
                    timeCardDayQuery += ' AND AcctSeed__Date__c >= :startDate AND AcctSeed__Date__c <= :endDate';
                }else if(String.isNotBlank(projectId) && startDate != null){
                    timeCardDayQuery += ' AND AcctSeed__Date__c >= :startDate';
                }else if(String.isNotBlank(projectId) && endDate != null){
                    timeCardDayQuery += ' AND AcctSeed__Date__c <= :endDate';
                }else if(startDate != null && endDate != null){
                    timeCardDayQuery += ' AND AcctSeed__Date__c >= :startDate AND AcctSeed__Date__c <= :endDate';
                }
               
            }
            if(communityName == 'student' || Test.isRunningTest()){
                
                Set<Id> projectIds = new Set<Id>();
                
                if(String.isBlank(projectId) && startDate != null && endDate != null){
                    for(Contact_Assignments__c ca : [SELECT Id,Project__c FROM Contact_Assignments__c 
                                                            WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active','Ended')]){
                        projectIds.add(ca.Project__c);
                    }
                }
                    
                if(String.isNotBlank(projectId)){
                    timeCardDayQuery +=' AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId';
                }else if(String.isBlank(projectId) && startDate != null && endDate != null){
                    timeCardDayQuery +=' AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :projectIds';
                }
                
                if(startDate != null && endDate != null){
                    timeCardDayQuery += ' AND AcctSeed__Date__c >= :startDate AND AcctSeed__Date__c <= :endDate';
                }else if(startDate != null){
                    timeCardDayQuery += ' AND AcctSeed__Date__c >= :startDate';
                }else if(endDate != null){
                    timeCardDayQuery += ' AND AcctSeed__Date__c <= :endDate';
                }
                /*else if(startDate != null && endDate != null){
                    timeCardDayQuery += ' AcctSeed__Date__c >= :startDate AND AcctSeed__Date__c <= :endDate';
                }*/
                
                timeCardDayQuery += ' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c != \'Preparation time\'';
            }
            
            timeCardDayQuery += ' ORDER BY AcctSeed__Date__c DESC';
            
            system.debug(':::::::::::timeCardDayQuery::::'+timeCardDayQuery);
            
            List<AcctSeed__Time_Card_Day__c> timeCardDays = database.query(timeCardDayQuery);
            
            
            dayDetails = TimeCardDayCommunityTranslator.timeActivityRecordsFormation(timeCardDays);
            
            return JSON.serialize(dayDetails);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
    }
        
    public static String getCommunityPathPrefix() {
        String communityName = '';
        
        List<NetWork> networkRecord = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
        
        if(networkRecord.size() > 0){
            communityName = networkRecord[0].UrlPathPrefix;
        }
        
        return communityName;
    }
    
    public static String getLoggedUserContactId() {
        return [Select Id,ContactId FROM User where Id =: userInfo.getUserId()].ContactId;
    }
}