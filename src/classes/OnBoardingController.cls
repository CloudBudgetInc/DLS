/*Developed By Siva Prasanth on 29-08-2019*/
public without sharing class OnBoardingController {
    
    //get Task Records
    @AuraEnabled 
    public static String getToDoItems() {
        Id conId = EventCalendarController.getLoggedUserContactId();
        List<TodoWrap> TodoWrapList = new List<TodoWrap>(); 
        List<Task> toDoItemsList = new List<Task>();
        Map<Id, Contact_Assignments__c> contactAssignmentIdMap = new Map<Id, Contact_Assignments__c>();
        //W-006449 - To exclude specific task for student if thery are not have active moodle user
        //Added by NS on Mar 15 2021
        
        String communityName = ListViewController.getCommunityPathPrefix();
        
        if(communityName == 'instructor'){
            
            toDoItemsList = [SELECT Id,Type,To_Do_Type__c,Status,Subject,WhoId,WhatId 
                                   FROM Task 
                                   WHERE Type = 'To Do' AND Status = 'In Progress' AND WhoId = :conId 
                                   ORDER BY To_Do_Type__c ASC]; 
        
        }else {
        
            List<Contact> conRec = [SELECT Id,Moodle_User_Id__c,Moodle_User_Status__c FROM Contact WHERE Id = :conId];
            contactAssignmentIdMap = new Map<Id, Contact_Assignments__c>([SELECT Id, Project__c, Project__r.DLS_Ref__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :conId]);
            
            if(conRec.size() > 0 && conRec[0].Moodle_User_Id__c != null && conRec[0].Moodle_User_Status__c == 'Active'){
                
                toDoItemsList = [SELECT Id,Type,To_Do_Type__c,Status,Subject,WhoId,WhatId 
                                   FROM Task 
                                   WHERE Type = 'To Do' AND Status = 'In Progress' AND (WhoId = :conId OR WhatId IN :contactAssignmentIdMap.keySet())
                                   ORDER BY To_Do_Type__c ASC]; 
                
            }else {
            
                toDoItemsList = [SELECT Id,Type,To_Do_Type__c,Status,Subject,WhoId,WhatId 
                                   FROM Task 
                                   WHERE Type = 'To Do' AND Status = 'In Progress' AND (WhoId = :conId OR WhatId IN :contactAssignmentIdMap.keySet()) AND To_Do_Type__c != '60 - Check out the Student Language Studies Program'
                                   ORDER BY To_Do_Type__c ASC]; 
            }
        }
        
        for(Task task : toDoItemsList){
            TodoWrap TodoWrapObj = new TodoWrap();
            TodoWrapObj.Id = task.Id;
            TodoWrapObj.todotype = task.To_Do_Type__c;
            TodoWrapObj.Subject = task.WhatId != null && contactAssignmentIdMap.get(task.WhatId) != null ?  'Sign ' + task.Subject + '-' + contactAssignmentIdMap.get(task.WhatId).Project__r.DLS_Ref__c : task.Subject;
            todoWrapObj.Status = task.Status;
            todoWrapObj.WhoId = task.WhoId;
            TodoWrapList.add(TodoWrapObj);
        }
        
        return JSON.serialize(TodoWrapList);
    }
        
    public class TodoWrap{
        public String Subject;
        public String Id;
        public String todotype;
        public String Status;
        public String WhoId;
    }
    
    //update the status of ToDoItem Task Record
    @AuraEnabled 
    public static String updateToDoItem(String toDOId) {
        try{
            if(String.isNotBlank(toDOId)) {
                Task todo = new Task(Id = toDOId,Status = 'Completed');
                update todo;
                return (getToDoItems());
            }
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }
    // get Open and Completed ToDoItems
    @AuraEnabled 
    public static ToDoItems getOpenCompletedToDoItems() {
        Id conId = EventCalendarController.getLoggedUserContactId();
        String openToDo;
        
        ToDoItems todo = new ToDoItems();
        openToDo = getToDoItems();
        
        List<Task> completedToDoItemList = [SELECT Id,Type,To_Do_Type__c,Status,Subject,WhoId,WhatId 
                                           FROM Task 
                                           WHERE Type = 'To Do' AND Status = 'Completed' AND WhoId = :conId 
                                           ORDER BY To_Do_Type__c ASC]; 
        
        List<Task> openToDoItemList = (List<Task>) JSON.deserialize(openToDo,List<Task>.class);
        
        todo.openToDoItems = openToDoItemList;
        todo.completedToDoItems = completedToDoItemList;
        return todo;
    }
    
    @AuraEnabled
    public static String getSummaryDLIAttendanceInfo(){
    
        Id conId = EventCalendarController.getLoggedUserContactId();
        
        String communityName = ListViewController.getCommunityPathPrefix();
        
        Set<Id> studentProIds = new Set<Id>();
        Map<Id,Id> proIdLeaderId = new Map<Id,Id>();
        Set<Id> existingDLIAttendanceEvents = new Set<Id>();
        
        List<summaryAttendanceDetail> summaryDetails = new List<summaryAttendanceDetail>();
        
        Set<Id> existingDLIAttendanceProIds = new Set<Id>();
        
        if(communityName == 'student'|| Test.isRunningTest()){
            
            //Qry existing DLI Attendance to check already entered for all DLI Projects
            //Commented Class_Leader__c for W-005028 - To make Student to place their attendance of their own instead of Class Leader
            for(DLI_Attendance__c atten : [SELECT Id,Date__c,Student__c,Class_Leader__c,Project__c,Event__c FROM DLI_Attendance__c WHERE Student__c = :conId AND Date__c = TODAY]){
                
                if(!existingDLIAttendanceProIds.contains(atten.Project__c)){
                    existingDLIAttendanceProIds.add(atten.Project__c);
                }
                
                existingDLIAttendanceEvents.add(atten.Event__c);
            }
            
            system.debug(':::::::existingDLIAttendanceProIds::::'+existingDLIAttendanceProIds);
            
            //Qry student related CA details which are not in existing DLI Attendance records
            //Added Project__r.DLI_Project_Type__c Filter for W-005028
            for(Contact_Assignments__c ca : [SELECT Id,Candidate_Name__c,Status__c,Project__c FROM Contact_Assignments__c 
                                                WHERE Candidate_Name__c = :conId AND RecordType.DeveloperName = 'Student' AND Assignment_Position__c IN ('Class Leader','Student') 
                                                    AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' AND Project__r.DLI_Project_Type__c != 'EI']){
                
                studentProIds.add(ca.Project__c);
            }
            
            //proIdLeaderId = timeCardRelated_Email_Controller.getProjIdAndLeaderId(studentProIds,new Set<Date>{system.today()},false,null,null,true); 
            
            system.debug('::::::::studentProIds:::::::'+studentProIds);
            system.debug('::::::::::proIdLeaderId:::::::'+proIdLeaderId);
            
            if(studentProIds.size() > 0){
              
                //Qry project related event details
                for(Events__c eve : [SELECT Id,Date__c,Instructor__c,Project__c,Project__r.DLS_Class__c,Instructor__r.Name FROM Events__c 
                                        WHERE Project__c IN :studentProIds AND Date__c = TODAY AND Status__c = 'Scheduled' 
                                            AND Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time']){
                    
                    /*removed condition
                       
                       proIdLeaderId.containsKey(eve.Project__c) && proIdLeaderId.get(eve.Project__c) == conId &&
                        
                       for W-005028 - To make Student to place their attendance of their own instead of Class Leader
                    */
                    
                    if((!existingDLIAttendanceProIds.contains(eve.Project__c) || (existingDLIAttendanceProIds.contains(eve.Project__c) 
                            && !existingDLIAttendanceEvents.contains(eve.Id)))){
                        
                        summaryAttendanceDetail detail = new summaryAttendanceDetail();
                        detail.projectId = eve.Project__c;
                        
                        detail.instructorId = eve.Instructor__c;
                        //Commented classLeaderId for W-005028 - To make Student to place their attendance of their own instead of Class Leader
                        //detail.classLeaderId = proIdLeaderId.containsKey(eve.Project__c) ? proIdLeaderId.get(eve.Project__c) : null;
                        
                        detail.dliAttendanceLink = eve.Project__r.DLS_Class__c+'/'+eve.Instructor__r.Name;
                        
                        summaryDetails.add(detail);
                        
                    }
                }
                
            }
               
        }
        
        
        system.debug(':::::::summaryDetails::::'+summaryDetails);
        
        return JSON.serialize(summaryDetails);
    }
    
    @AuraEnabled
    public static string getDLIAttendanceInfo(string projectId, string instructorId){
        
        
        Id classLeaderId;
        Id classLeaderCAId;
        
        String projectName = '';
        String instructorName = '';
        
        List<AttendanceInfo> studentDetails = new List<AttendanceInfo>();
        Map<Id,Id> proIdLeaderId = new Map<Id,Id>();
        
        //get instructor name
        List<Contact> instructorRec = [SELECT Id,Name FROM Contact WHERE Id = :instructorId];
        Id conId = EventCalendarController.getLoggedUserContactId();
        proIdLeaderId = timeCardRelated_Email_Controller.getProjIdAndLeaderId(new Set<Id>{projectId},new Set<Date>{system.today()},false,null,null,true); 
        
        
        //get project related today event info
        List<Events__c> eventDetails = [SELECT Id,Name,Date__c FROM Events__c 
                                            WHERE Project__c = :projectId AND Instructor__c = :instructorId AND Status__c = 'Scheduled' AND Date__c = TODAY 
                                                AND Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' 
                                                AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time'];
        
        //get project related student information for attendance
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Project__c,Project__r.DLS_Class__c,Assignment_Position__c FROM Contact_Assignments__c 
                                            WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Candidate_Name__c = :conId]){
            
            AttendanceInfo attInfo = new AttendanceInfo();
            attInfo.studentId = ca.Candidate_Name__c;
            attInfo.studentName = ca.Candidate_Name__r.Name;
            attInfo.studentCAId = ca.Id;
            
            //Commented for W-005028 - To make Student to place their attendance of their own instead of Class Leader
            /*if(ca.Assignment_Position__c == 'Class Leader' 
                || (proIdLeaderId.containsKey(ca.Project__c) && proIdLeaderId.get(ca.Project__c) == ca.Candidate_Name__c)){
                
                classLeaderId = ca.Candidate_Name__c;
                classLeaderCAId = ca.Id;
                
                attInfo.classLeaderId = ca.Candidate_Name__c;
                attInfo.classLeaderCAId = ca.Id;
                
            }else {
                
                attInfo.classLeaderId = classLeaderId;
                attInfo.classLeaderCAId = classLeaderCAId;
            }*/
            
            attInfo.projectId = projectId;
            attInfo.eventId = eventDetails.size() > 0 && eventDetails.size() == 1 ? eventDetails[0].Id : null;
            attInfo.studentPresent = '';
            attInfo.attendanceComment = '';
            
            
            projectName = ca.Project__r.DLS_Class__c;
            
            studentDetails.add(attInfo);
        }
        
        summaryAttendanceDetail summaryDetail = new summaryAttendanceDetail();
        summaryDetail.allStudentDetails = studentDetails;
        summaryDetail.projectName = projectName;
        summaryDetail.instructorName = instructorRec.size() > 0 ? instructorRec[0].Name : '';
        summaryDetail.technicalIssue = false;
        summaryDetail.technicalIssueComment = '';
        summaryDetail.academicIssue = false;
        summaryDetail.academicIssueComment = '';
        
        Date dt = system.today();
        summaryDetail.dateVal = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
        
        return JSON.serialize(summaryDetail);
    }
    
    @AuraEnabled
    public static string createDLIAttendance(String inputJSON){
        
        try {
        
            summaryAttendanceDetail summaryDetail = (summaryAttendanceDetail) System.JSON.deserialize(inputJSON, summaryAttendanceDetail.class);
            
            List<DLI_Attendance__c> dliAttendanceList = new List<DLI_Attendance__c>();
            
            for(AttendanceInfo att : summaryDetail.allStudentDetails){
            
                DLI_Attendance__c dliAtt = new DLI_Attendance__c();
                dliAtt.Academic_Issue__c = summaryDetail.academicIssue;
                dliAtt.Academic_Issue_Comment__c = summaryDetail.academicIssueComment;
                
                if(att.studentPresent == 'yes'){
                    dliAtt.Attendance__c = true;
                }
                if(att.studentPresent == 'no'){
                    dliAtt.Attendance__c = false;
                }
                
                dliAtt.Attendance_Comment__c = att.attendanceComment;
                //Commented Class_Leader__c, Class_Leader_Contact_Assignment__c for W-005028 - To make Student to place their attendance of their own instead of Class Leader
                //dliAtt.Class_Leader__c = att.classLeaderId;
                //dliAtt.Class_Leader_Contact_Assignment__c = att.classLeaderCAId;
                dliAtt.Date__c = system.today();
                dliAtt.Event__c = att.eventId;
                dliAtt.Project__c = att.projectId;
                dliAtt.Student__c = att.studentId;
                dliAtt.Student_Contact_Assignment__c = att.studentCAId;
                dliAtt.Technical_Issue__c = summaryDetail.technicalIssue;
                dliAtt.Technical_Issue_Comment__c = summaryDetail.technicalIssueComment;
                
                dliAttendanceList.add(dliAtt);
            }
            
            system.debug(':::::::dliAttendanceList::::::'+dliAttendanceList);
            
            if(dliAttendanceList.size() > 0){
                insert dliAttendanceList;
            }
            
            return 'SUCCESS';
        
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static Integer getPendingAssessmentReportCount(){
        Id conId = EventCalendarController.getLoggedUserContactId();
        String communityName = ListViewController.getCommunityPathPrefix();        
        List<Assessment_Report__c> assessmentReports = new List<Assessment_Report__c>();
        if(communityName == 'instructor'){
            Set<String> pendingAssessmentReportType = new Set<String>{'Language_Training_Progress','DLI_W_Progress','APMO_Progress','DEA_Progress','DLI_W_Progress_2022','DLI_W_Test_Report'};
            assessmentReports= [SELECT Id FROM Assessment_Report__c WHERE Instructor__c = :conId AND Status__c IN ('Scheduled','Submitted to LTS') AND RecordType.DeveloperName IN :pendingAssessmentReportType];
            assessmentReports.addAll([SELECT Id FROM Assessment_Report__c WHERE Tester__c = :conId AND Status__c IN ('Scheduled','Submitted to LTS') AND RecordType.DeveloperName = 'Test_Report']);        
        }else{
            assessmentReports= [SELECT Id FROM Assessment_Report__c WHERE Student__c = :conId AND Status__c IN ('Scheduled') AND RecordType.DeveloperName IN ('DLI_W_Self_Assessment_Test_Report')];
        }
        return assessmentReports.size();
    }

    public class ToDoItems{
        
        @AuraEnabled 
        public List<Task> openToDoItems;
        @AuraEnabled
        public List<task> completedToDoItems;
    } 
    
    public class summaryAttendanceDetail {
    
        public List<AttendanceInfo> allStudentDetails;
        public String dliAttendanceLink;
        public Id projectId;
        public Id instructorId;
        public Id classLeaderId;
        public String projectName;
        public String instructorName;
        public Boolean technicalIssue;
        public string technicalIssueComment;
        public Boolean academicIssue;
        public string academicIssueComment;
        public String dateVal;
    }
    
    public class AttendanceInfo {
    
        public Id studentId;
        public string studentName;
        public string studentPresent;
        public string attendanceComment;
        
        public Id projectId;
        public Id eventId;
        public Id studentCAId;
        public Id classLeaderCAId;
        public Id classLeaderId;
    } 
}