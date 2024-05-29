/***********************************************************************************
        - Contact Rollup Batch class to rollup following fields 
            1) of_Class_Projects_Taught__c - no of language projects under the contact
            2) of_Students_Taught__c    - no of students under the contact
            3) of_Tests_Perfomed__c    - no of testing projects under the contact
        - Work Item : W-001299
        - This batch class runs daily basis 
        - This batch called from 
        - Created by HL on Mar 26 2019
    *****************************************************************************************/
    
global class ContactRollupHelperBatch implements Database.batchable<sObject>,Database.Stateful {     
    
    global Database.QueryLocator start(Database.BatchableContext info){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        
        String fieldAPINames = 'Id, Name, Email, MobilePhone, Mailingstreet, Mailingcity, Mailingstate, Mailingpostalcode, Mailingcountry, Language_1__c, DLS_Candidate_Rating__c';
            fieldAPINames += ', Highest_Degree__c, Citizenship__c, Country_of_Citizenship__c, City_and_Country_of_Birth__c, Experience_with_DLI_Students__c, Average_Get_Feedback_Rating__c';
            fieldAPINames += ', Other_Relevant_Experience__c, of_Known_Languages__c, of_related_Education__c, of_related_Skills__c, of_related_Work_Experiences__c';
            fieldAPINames += ', of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c, Candidate_Profile_Complete__c, Evaluate_Candidate_Profile_Rating__c, Candidate_Hiring_Stage__c, Original_Hire_Date__c, RecordType.DeveloperName';
                              
        String conQuery = 'SELECT ';
            conQuery += fieldAPINames;
            conQuery += ' FROM Contact';
            conQuery += ' WHERE RecordType.DeveloperName IN : conRTNames';
            if(Test.isRunningTest()){
                conQuery += ' LIMIT 1';
            }
        
        return Database.getQueryLocator(conQuery);
    }
    
    global void execute(Database.BatchableContext info, List<Contact> contacts){
    
        Set<String> caStatus = new Set<String>{'Active', 'Ended'};
        Set<String> projRTNames = new Set<String>{'Language_Training_Projects', 'DODA_Projects', 'DLI_W_LT_Projects', 'MTT_Projects', 'ESL_LT_Projects', 'EFL_Projects', 'Partner_School_LT_Projects', 'Testing_Projects'};
        Set<String> ltProjRTNames = new Set<String>{'Language_Training_Projects', 'DODA_Projects', 'DLI_W_LT_Projects', 'MTT_Projects', 'ESL_LT_Projects', 'EFL_Projects', 'Partner_School_LT_Projects'};
        Set<Id> stdProjIds = new Set<Id>();
        
        Set<String> projIdAndConId = new Set<String>();
        Map<Id, Contact> toUpdateContacts = new Map<Id, Contact>();
        Map<Id, Integer> conIdAndNumofClassProj = new Map<Id, Integer>();
        Map<Id, Integer> conIdAndNumofTestProj = new Map<Id, Integer>();
        Map<Id, Integer> conIdAndNumofStudents = new Map<Id, Integer>();
        
        Map<Id, Set<Id>> projIdAndInsIds = new Map<Id, Set<Id>>();
        Map<Id, Integer> projIdAndNumofStudents = new Map<Id, Integer>();
                    
        // variables for populating Candidate_Profile_Complete__c field
        Map<Id, Decimal> conIdAndCPW = new Map<Id, Decimal>();
        
        // All fields need to check for population of Candidate_Profile_Complete__c
        Set<String> allfieldAPINames = new Set<String>{'Email', 'MobilePhone', 'Mailingstreet', 'Mailingcity', 'Mailingstate', 'Mailingpostalcode', 'Mailingcountry', 
            'Language_1__c', 'DLS_Candidate_Rating__c', 'Highest_Degree__c', 'Citizenship__c', 'Country_of_Citizenship__c', 'City_and_Country_of_Birth__c', 'Experience_with_DLI_Students__c',
            'Other_Relevant_Experience__c', 'of_Known_Languages__c', 'of_related_Education__c', 'of_related_Skills__c', 'of_related_Work_Experiences__c'}; 
        
        // if these fields have not balnk values then add 5%
        Set<String> addFivePercentFields = new Set<String>{'Email', 'MobilePhone', 'Mailingstreet', 'Mailingcity', 'Mailingstate', 'Mailingpostalcode', 'Mailingcountry',
            'Highest_Degree__c', 'Citizenship__c', 'Country_of_Citizenship__c', 'City_and_Country_of_Birth__c', 'Other_Relevant_Experience__c'};
            
        // if these fields value greater than 0, then add 5%
        Set<String> checkGreaterZeroFields = new Set<String>{'of_Known_Languages__c', 'of_related_Education__c', 'of_related_Skills__c', 'of_related_Work_Experiences__c'};
        
        // if these fields have not balnk values then add 7.5%
        Set<String> addSevenPercentFields = new Set<String>{'Language_1__c', 'DLS_Candidate_Rating__c'};
        
        // if this field value is TRUE, then add 5%
        Set<String> booleanField = new Set<String>{'Experience_with_DLI_Students__c'};
        
        // variables to update Average_Get_Feedback_Rating__c field
        //Map<Id, Decimal> insIdAndAvgRating = new Map<Id, Decimal>(); commented since this has Rollup Helper for new records
        
        Date hireDate = Date.Today().addMonths(-6);
        
        for(Contact_Assignments__c ca : [
            SELECT Id, Project__r.RecordType.DeveloperName, Candidate_Name__c, Project__c, name 
            FROM Contact_Assignments__c 
            WHERE Candidate_Name__c IN  :contacts AND RecordType.DeveloperName = 'Instructor' AND Assignment_Position__c IN ('Instructor', 'Substitute Instructor') AND 
                Status__c IN :caStatus AND Project__c != NULL AND Project__r.RecordType.DeveloperName IN :projRTNames
        ]){
            
            if(ltProjRTNames.contains(ca.Project__r.RecordType.DeveloperName)){
            
                String projIdConId = ca.Project__c+'-'+ca.Candidate_Name__c;
                if(!projIdAndConId.contains(projIdConId)){
                    if(!conIdAndNumofClassProj.containsKey(ca.Candidate_Name__c)){
                        conIdAndNumofClassProj.put(ca.Candidate_Name__c, 1);                   
                    }else{
                        conIdAndNumofClassProj.put(ca.Candidate_Name__c, conIdAndNumofClassProj.get(ca.Candidate_Name__c)+1);
                    }
                }
                stdProjIds.add(ca.Project__c);
                if(!projIdAndInsIds.containsKey(ca.Project__c)){
                    projIdAndInsIds.put(ca.Project__c, new Set<Id>());
                }
                projIdAndInsIds.get(ca.Project__c).add(ca.Candidate_Name__c);
                projIdAndConId.add(projIdConId);
            }
            
            if(ca.Project__r.RecordType.DeveloperName == 'Testing_Projects'){
            
                String projIdConId = ca.Project__c+'-'+ca.Candidate_Name__c;
                if(!projIdAndConId.contains(projIdConId)){
                
                    if(!conIdAndNumofTestProj.containsKey(ca.Candidate_Name__c)){
                        conIdAndNumofTestProj.put(ca.Candidate_Name__c, 1);                   
                    }else{
                        conIdAndNumofTestProj.put(ca.Candidate_Name__c, conIdAndNumofTestProj.get(ca.Candidate_Name__c)+1);
                    }
                }
                projIdAndConId.add(projIdConId);
            }
        }
        
        if(projIdAndInsIds.size() > 0){
        
            for(Contact_Assignments__c ca : [
                SELECT Id, Candidate_Name__c, Project__c 
                FROM Contact_Assignments__c 
                WHERE Project__c IN  :projIdAndInsIds.keySet() AND RecordType.DeveloperName = 'Student' AND Candidate_Name__c != NULL AND Status__c IN :caStatus
            ]){
                
                if(!projIdAndNumofStudents.containsKey(ca.Project__c)){
                    projIdAndNumofStudents.put(ca.Project__c, 1);                   
                }else{
                    projIdAndNumofStudents.put(ca.Project__c, projIdAndNumofStudents.get(ca.Project__c)+1);
                }
            }
        }
        
        if(projIdAndNumofStudents.size() > 0){
        
            for(Id projId : projIdAndInsIds.keySet()){
            
                for(Id insId : projIdAndInsIds.get(projId)){
                
                    if(projIdAndNumofStudents.containsKey(projId)){
                    
                        if(!conIdAndNumofStudents.containsKey(insId)){
                            
                            conIdAndNumofStudents.put(insId, projIdAndNumofStudents.get(projId));
                        }else{
                            
                            conIdAndNumofStudents.put(insId, conIdAndNumofStudents.get(insId)+projIdAndNumofStudents.get(projId));
                        }
                    }
                }
            }
        }
                
        for(Contact con : contacts){
        
            if(!con.Evaluate_Candidate_Profile_Rating__c){
            
                Decimal cpw = 0;
                
                for(String field : allfieldAPINames){
                
                    if(addFivePercentFields.contains(field)){
                    
                        if(con.get(field) != NULL && con.get(field) != ''){
                            cpw += 5;
                        }
                    }
                    
                    if(addSevenPercentFields.contains(field)){
                    
                        if(con.get(field) != NULL && con.get(field) != ''){
                            cpw += 7.5;
                        }
                    }
                    
                    if(checkGreaterZeroFields.contains(field)){
                    
                        if(Integer.valueOf(con.get(field)) > 0){
                            cpw += 5;
                        }
                    }
                    
                    if(booleanField.contains(field)){
                    
                        if(con.get(field) == TRUE){
                            cpw += 5;
                        }
                    }
                }
                conIdAndCPW.put(con.Id, cpw);
            }
        }        
        
        /*for(AggregateResult a : [
            SELECT AVG(Over_all_Instructor_rating__c) rating, Instructor__c ins
            FROM Get_Feedback__c 
            WHERE Instructor__c IN :contacts AND RecordType.DeveloperName = 'Ending_Feedback' AND Over_all_Instructor_rating__c != NULL AND Over_all_Instructor_rating__c != 0 
                GROUP BY Instructor__c
        ]){
            insIdAndAvgRating.put((Id)a.get('ins'), (Decimal)a.get('rating'));
        }
        System.debug('insIdAndAvgRating=========='+insIdAndAvgRating);
        */
        
        for(Contact c : contacts){
        
            if(conIdAndNumofClassProj.containsKey(c.Id)){
            
                if(c.of_Class_Projects_Taught__c == NULL || (c.of_Class_Projects_Taught__c != NULL && c.of_Class_Projects_Taught__c != conIdAndNumofClassProj.get(c.Id))){
                
                    c.of_Class_Projects_Taught__c = conIdAndNumofClassProj.get(c.Id);
                    toUpdateContacts.put(c.Id, c);
                }
            }
            
            if(conIdAndNumofTestProj.containsKey(c.Id)){
            
                if(c.of_Tests_Perfomed__c == NULL || (c.of_Tests_Perfomed__c != NULL && c.of_Tests_Perfomed__c != conIdAndNumofTestProj.get(c.Id))){
                
                    c.of_Tests_Perfomed__c = conIdAndNumofTestProj.get(c.Id);
                    toUpdateContacts.put(c.Id, c);
                }
            }
            
            if(conIdAndNumofStudents.containsKey(c.Id)){
            
                if(c.of_Students_Taught__c == NULL || (c.of_Students_Taught__c != NULL && c.of_Students_Taught__c != conIdAndNumofStudents.get(c.Id))){
                
                    c.of_Students_Taught__c = conIdAndNumofStudents.get(c.Id);
                    toUpdateContacts.put(c.Id, c);
                }
            }
            
            if(conIdAndCPW.containsKey(c.Id)){
            
                if(c.Candidate_Profile_Complete__c == NULL || (c.Candidate_Profile_Complete__c != NULL && c.Candidate_Profile_Complete__c != conIdAndCPW.get(c.Id))){
                
                    c.Candidate_Profile_Complete__c = conIdAndCPW.get(c.Id);
                    c.Evaluate_Candidate_Profile_Rating__c = TRUE;
                    toUpdateContacts.put(c.Id, c);
                }
            }
            
            /*if(insIdAndAvgRating.containsKey(c.Id)){
            
                if(c.Average_Get_Feedback_Rating__c == NULL || (c.Average_Get_Feedback_Rating__c != NULL && c.Average_Get_Feedback_Rating__c != insIdAndAvgRating.get(c.Id))){
                    System.debug('RATING TEST======');
                    c.Average_Get_Feedback_Rating__c = insIdAndAvgRating.get(c.Id);
                    toUpdateContacts.put(c.Id, c);
                }
            }*/
            
            // Added on Feb 2024
            // W-007989 : Automation needed for new "Candidate Hiring Stage" field for "Hired" value
            if(c.RecordType.DeveloperName == 'Candidate' && String.isNotBlank(c.Candidate_Hiring_Stage__c) && c.Candidate_Hiring_Stage__c == 'Hired' && c.Original_Hire_Date__c != null && c.Original_Hire_Date__c < hireDate){
                c.Candidate_Hiring_Stage__c = null;
                toUpdateContacts.put(c.Id, c);
            }
        }
        
        if(toUpdateContacts.size() > 0){
        
            update toUpdateContacts.values();
        }
    }
    
    global void finish(Database.BatchableContext info){
               
    }
}