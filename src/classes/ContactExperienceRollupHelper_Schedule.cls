/**********
    - This scheduler runs every sunday @ 2.30 AM
    - Cron Expression for this scheduler:
        String CRON_EXP = '0 30 2 ? * SUN';
        ContactExperienceRollupHelper_Schedule sch = new ContactExperienceRollupHelper_Schedule();
        system.schedule('Contact Experience Rollup Helper Schedule @Every Sunday 2.30 AM', CRON_EXP, sch);
    *********/
    
global class ContactExperienceRollupHelper_Schedule implements Schedulable, Database.Batchable<Contact>{

    global void execute(SchedulableContext sc){
        Database.executebatch(new ContactExperienceRollupHelper_Schedule(), 100);
    }
    
    global Iterable<Contact> start(Database.BatchableContext info){ 
    
        String conQuery = '';
        conQuery += 'SELECT Id, Teaching_Experience__c, Work_Experience__c, Total_Experience_in_Months__c, RecordType.DeveloperName, (SELECT Id, Is_LT_Service__c, Intensive_Proficiency_Oriented_Experienc__c, Experience_in_Months__c, contact__c, RecordType.DeveloperName FROM Experiences__r WHERE RecordType.DeveloperName = \'Professional_Work_Experience\' AND Experience_in_Months__c > 0) FROM Contact ';
        conQuery += 'WHERE Id IN (SELECT Contact__c FROM Experience__c WHERE End_Date__c = null AND RecordType.DeveloperName = \'Professional_Work_Experience\' AND Experience_in_Months__c > 0) AND RecordType.DeveloperName IN (\'Candidate\', \'DLS_Employee\') LIMIT 5000';
        
        System.debug('::::conQuery::::'+conQuery);
        
        List<Contact> contacts = Database.Query(conQuery);
        return contacts;
    }
    
    global void execute(Database.BatchableContext BC, List<Contact > contacts){
        
        Map<Id, Contact> updateContacts = new Map<Id, Contact>();
        
        System.debug(':contacts::'+contacts);
        System.debug(':contacts::'+contacts.size());
        
        for(Contact con : contacts){
            
            Decimal teachingExp = 0;
            Decimal workExp = 0;
            Decimal totalExp = 0;
            
            System.debug('::::con.Experiences__r::::'+con.Experiences__r);
            System.debug('::::con.Experiences__r::::'+con.Experiences__r.size());
            
            for(Experience__c exp : con.Experiences__r){
                                
                // Calculate Teaching_Experience__c
                if(exp.Is_LT_Service__c){
                    teachingExp += exp.experience_in_months__c;
                }
                // Calculate Work_Experience__c
                if(con.RecordType.DeveloperName == 'Candidate'){
                    workExp += exp.experience_in_months__c;
                }
                // Calculate Total_Experience_in_Months__c
                if(exp.Intensive_Proficiency_Oriented_Experienc__c){
                    totalExp += exp.experience_in_months__c;
                }
            }
            
            // Do we need to update 0 for teaching Exp in contact if teachingExp value as 0
            if(teachingExp > 0 && con.Teaching_Experience__c != teachingExp){
                con.Teaching_Experience__c = teachingExp;
                updateContacts.put(con.Id, con);
            }
            if(workExp > 0 && con.Work_Experience__c != workExp){
                con.Work_Experience__c = workExp;
                updateContacts.put(con.Id, con);
            }
            if(totalExp > 0 && con.Total_Experience_in_Months__c != totalExp){
                con.Total_Experience_in_Months__c = totalExp;
                updateContacts.put(con.Id, con);
            }
        }
        System.debug(':::::updateContacts::::'+updateContacts.size());
        if(updateContacts.size() > 0){
            update updateContacts.values();
        }    
    }
    
    public void finish(Database.BatchableContext info){
        
    }
}