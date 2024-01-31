/*
* This Batch creates OpportunityContactRoles for the existing Opportunities, for the following fields "Student Name","Contracting Officer",
* "Agency Contact", "Instructor Name",
* with role as "Student/COR/Training Officer/Instructor", if and only if already an OCR doesn't exist 
* with this opportunity id and contact(Student Name/Contracting Officer/Agency Contact/Instructor Name) combination.
*/

global class createOpportunityContactRoles_Batch implements Database.Batchable<SObject> {

    global Database.QueryLocator start( Database.BatchableContext BC ) {
    
        String query = 'SELECT Id, Name, Student_Name__c, Contracting_Officer__c, Agency_Contact__c, ' +
                                         + 'InstructorName__c, RecordTypeId, RecordType.DeveloperName, '+
                                         + 'RecordType.isActive, EI_lookup__c, X2nd_Instructor__c, Supervisor__c ' + 
                                      + 'FROM Opportunity ' +
                                      + 'WHERE RecordType.DeveloperName IN (\'New_Classes_Opportunities\', \'AFPAK_Classes\') ' +
                                      + 'AND RecordType.isActive = TRUE ' +
                                      + 'AND (Student_Name__c != NULL ' +
                                      + 'OR Contracting_Officer__c != NULL ' +
                                      + 'OR Agency_Contact__c != NULL ' +
                                      + 'OR InstructorName__c != NULL ' +
                                      + 'OR Supervisor__c != NULL ' +
                                      + 'OR EI_lookup__c != NULL ' +
                                      + 'OR X2nd_Instructor__c != NULL)';
        
        System.debug('query : ' + query);
        return Database.getQueryLocator( query );
    }
    
    global void execute( Database.BatchableContext BC, List<Opportunity> oppList) {
    
        Set<Id> oppIdSet = new Set<Id>();
        
        System.debug('oppList : ' + oppList);
        
        for (Opportunity opp : oppList) {
        
            oppIdSet.add(opp.Id);
        }
        
        System.debug('oppIdSet : ' + oppIdSet);
        
        if (oppIdSet != null && oppIdSet.size() > 0) {
        
            createContactRoles_Util.createContactRoles(oppIdSet, true);
        }      
    
    } // end execute
    
    global void finish(Database.BatchableContext BC) {
    
    }
}