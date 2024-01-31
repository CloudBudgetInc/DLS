public class LessonPlanCreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Set<Id> eventIds;
    public Map<Id, String> projectIdWithStudentFullNameMap;
    public Map<Id, String> projectIdWithStudentNameMap;
    public Set<String> projectIdsAndInstructorIdToSkipLessonPlanCreation;
    
    public LessonPlanCreationBatch(Set<Id> eventIds){
        
        this.eventIds = eventIds;
        this.projectIdWithStudentFullNameMap =  new Map<Id, String>();
        this.projectIdWithStudentNameMap =  new Map<Id, String>();
        this.projectIdsAndInstructorIdToSkipLessonPlanCreation = new Set<String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
          
        return Database.getQueryLocator('SELECT Id, Duration__c,Date__c, Instructor__c, Project__c, Schedule__r.Prior_Schedule__c,Schedule__r.Schedule_Type__c FROM Events__c WHERE Id IN :eventIds AND Project__r.RecordType.DeveloperName IN (\'Language_Training_Projects\',\'DODA_Projects\') AND Project__r.QB_Classification__c != \'OF0MTT0PS\' AND (Schedule__r.Project_Task__r.Project_Task_Type__c = \'Language Training\' OR Project_Task__r.Project_Task_Type__c = \'Language Training\')');
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> eventList){
        List<Events__c> events = (List<Events__c>)eventList;
        Id ltRTId = Schema.SObjectType.Lesson_Plan__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        Id dliRTId = Schema.SObjectType.Lesson_Plan__c.getRecordTypeInfosByDeveloperName().get('DLI').getRecordTypeId();
        
        Set<Id> projectIds = new Set<Id>();
        Set<Date> subEventDates = new Set<Date>();
        Set<Id> subPriorSchIds = new Set<Id>();
        Set<Id> instructorIds = new Set<Id>();   
        Set<Id> projectIdsToGetInstructorCA = new Set<Id>();
        
        for(Events__c eve: events){
            
            if(!projectIdWithStudentNameMap.containsKey(eve.Project__c)){
                projectIds.add(eve.Project__c);                
            }
            
            if(!projectIdsAndInstructorIdToSkipLessonPlanCreation.contains(eve.Project__c+'~'+eve.Instructor__c)){
                projectIdsToGetInstructorCA.add(eve.Project__c);
                instructorIds.add(eve.Instructor__c);
            }
            
            if(eve.Schedule__c != null && eve.Schedule__r.Prior_Schedule__c != null && eve.Schedule__r.Schedule_Type__c == 'Substitute'){
                subEventDates.add(eve.Date__c);
                subPriorSchIds.add(eve.Schedule__r.Prior_Schedule__c);
            }
        }
        
        if(projectIdsToGetInstructorCA.size() > 0){
            for(Contact_Assignments__c ca : [SELECT Id,Project__c,Candidate_Name__c, Assignment_Position__c
                                                FROM Contact_Assignments__c 
                                                WHERE Status__c != 'Canceled' AND RecordType.DeveloperName = 'Instructor' 
                                                AND  Project__c IN :projectIdsToGetInstructorCA AND Candidate_Name__c IN :instructorIds]){
                 
                // Modified on July 06 2023 - W-007789 : Events Missing Lesson Plans
                // To allow lesson plan creation for an instructor even though who having tester position if same instructor had different positions under a project
                if(!projectIdsAndInstructorIdToSkipLessonPlanCreation.contains(ca.Project__c+'~'+ca.Candidate_Name__c)){
                    if(ca.Assignment_Position__c == 'Tester'){
                        projectIdsAndInstructorIdToSkipLessonPlanCreation.add(ca.Project__c+'~'+ca.Candidate_Name__c);
                    }
                }else{
                    if(ca.Assignment_Position__c != 'Tester'){
                        projectIdsAndInstructorIdToSkipLessonPlanCreation.remove(ca.Project__c+'~'+ca.Candidate_Name__c);
                    }    
                }
            }
        }
        
        if(projectIds.size() > 0){          
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE Status__c != 'Canceled' AND RecordType.DeveloperName = 'Student' AND Project__c = :projectIds]){
                
                String studentNames = projectIdWithStudentNameMap.containsKey(ca.Project__c) ? projectIdWithStudentNameMap.get(ca.Project__c) : '';
                String studentFullNames = projectIdWithStudentFullNameMap.containsKey(ca.Project__c) ? projectIdWithStudentFullNameMap.get(ca.Project__c) : '';
                
                String candidateName = '';
                String candidateFullName = '';
                String stuName = '';
                
                stuName = (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
                candidateName = stuName + (ca.Candidate_Name__r.LastName != null ? ' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.' : '');
                candidateFullName = stuName + (ca.Candidate_Name__r.LastName != null ? ' '+ca.Candidate_Name__r.LastName: '');
                
                if(String.isNotBlank(studentNames)){
                  studentNames += ', ';
                }
                
                if(String.isNotBlank(studentFullNames)){
                  studentFullNames += ', ';
                }
                
                studentNames += candidateName;
                studentFullNames += candidateFullName;
                
                projectIdWithStudentNameMap.put(ca.Project__c, studentNames);
                projectIdWithStudentFullNameMap.put(ca.Project__c, studentFullNames);
            }
        }
        
        Map<String, Lesson_Plan__c> projIdAndDateWithLPMap = new Map<String, Lesson_Plan__c>();
        if(subEventDates.size() > 0){
            for(Lesson_Plan__c lp : [SELECT Id, Project__c, Instructor__c, Date__c FROM Lesson_Plan__c WHERE Event__c IN (SELECT Id FROM Events__c WHERE Schedule__c IN :subPriorSchIds AND Date__c IN :subEventDates)]){
                projIdAndDateWithLPMap.put(lp.Project__c+'~'+lp.Date__c, lp);
            }
        }
        
        
        Map<Id, Lesson_Plan__c> eventIdWithLessonPlanMap = new Map<Id, Lesson_Plan__c>();
        Map<Id, List<Lesson_Plan_Hour__c>> eventIdWithLessonPlanHrsMap = new Map<Id, List<Lesson_Plan_Hour__c>>();
        for(Events__c eve: events){
            if(!projectIdsAndInstructorIdToSkipLessonPlanCreation.contains(eve.Project__c+'~'+eve.Instructor__c)){
                String key = eve.Project__c +'~'+eve.Date__c;
                if(eve.Schedule__c != null && eve.Schedule__r.Prior_Schedule__c != null && eve.Schedule__r.Schedule_Type__c == 'Substitute' && projIdAndDateWithLPMap.containsKey(key)){
                    Lesson_Plan__c lp = projIdAndDateWithLPMap.get(key);
                    lp.Event__c = eve.Id;
                    lp.Instructor__c = eve.Instructor__c;
                    eventIdWithLessonPlanMap.put(eve.Id, lp);
                }else{
                    String studentNames = projectIdWithStudentNameMap.containsKey(eve.Project__c) ? projectIdWithStudentNameMap.get(eve.Project__c) : '';
                    String studentFullNames = projectIdWithStudentFullNameMap.containsKey(eve.Project__c) ? projectIdWithStudentFullNameMap.get(eve.Project__c) : '';
                    
                    Lesson_Plan__c lp = new Lesson_Plan__c(RecordTypeId=ltRTId, Date__c=eve.Date__c,Status__c='Draft',Event__c=eve.Id,Project__c=eve.Project__c, Instructor__c = eve.Instructor__c, Student_Name__c = studentNames, Student_Full_Name_s__c = studentFullNames);
                    eventIdWithLessonPlanMap.put(eve.Id, lp);
                    if(!eventIdWithLessonPlanHrsMap.containsKey(eve.Id)){
                        eventIdWithLessonPlanHrsMap.put(eve.Id, new List<Lesson_Plan_Hour__c>());    
                    }  
                    if(String.isNotBlank(String.valueOf(eve.Duration__c))){
                        Integer duration = eve.Duration__c.intValue();
                        for(Integer hrs = 1; hrs <= duration; hrs++){
                            eventIdWithLessonPlanHrsMap.get(eve.Id).add(new Lesson_Plan_Hour__c(Name='Hour '+hrs));
                        }
                    }
                }
            }
        } 
        
        if(eventIdWithLessonPlanMap.size() > 0){
            upsert eventIdWithLessonPlanMap.values();
            
            List<Lesson_Plan_Hour__c> lphToInsert = new List<Lesson_Plan_Hour__c>();
            for(Id eveId : eventIdWithLessonPlanMap.keySet()){
                if(eventIdWithLessonPlanHrsMap != null && eventIdWithLessonPlanHrsMap.get(eveId) != null){
                    for(Lesson_Plan_Hour__c lsh : eventIdWithLessonPlanHrsMap.get(eveId)){
                        lsh.Lesson_Plan__c = eventIdWithLessonPlanMap.get(eveId).Id;
                        lphToInsert.add(lsh);
                    }
                }
            }
            
            if(lphToInsert.size() > 0){
                insert lphToInsert; 
            }
        }        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}