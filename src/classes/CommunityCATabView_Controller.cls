public without sharing class CommunityCATabView_Controller {
    @AuraEnabled
    public static String getCARecord(String projectId) {
        
        System.debug('<<<<<<projectId::::>>>>>' + projectId);
        Boolean showStudentTab = true;
        Boolean showInstructorTab = true; 
        String studentTablabel = 'Student';
        String instructorTabLabel = 'Instructor';
        String staffTabLabel = 'Supervisor/LTS';    
        List<string> defaultStatusSet = new List<String>{ 'All', 'Active','Planned','Ended', 'On Hold' };
            List<String> statusList = new List<String>();
        
        List<Contact_Assignments__c> CAList = [SELECT 
                                               Id, End_Date__c, Start_Date__c, Record_Type_Developer_Name__c, Assignment_Position__c, Status__c, candidate_name__r.name,candidate_name__r.firstname,candidate_name__r.lastname, RecordType.DeveloperName  
                                               FROM Contact_Assignments__c 
                                               WHERE Project__c = :projectId and RecordType.DeveloperName IN ('Student','Instructor','Staff') ORDER BY candidate_name__r.firstname ASC];
        
        List<AcctSeed__Project__c> project = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :projectId];
        
        /*List<CAListWrapper> CAListWrapper = new List<CAListWrapper>();
        
        for(Contact_Assignments__c c: CAList) {
            CAListWrapper ca = new CAListWrapper();
            ca.contactId = c.Candidate_Name__r.Id;
            if(c.Record_Type_Developer_Name__c == 'Student') {
                ca.contactName = c.Candidate_Name__r.firstname+' '+c.Candidate_Name__r.lastname.substring(0,1);
            } else {
                ca.contactName = c.Candidate_Name__r.name;
            }
            ca.caId = c.Id;
            ca.projectId = projectId;
            ca.startDate = c.Start_Date__c;
            ca.endDate = c.End_Date__c;
            ca.status = c.Status__c;
            ca.position = c.Assignment_Position__c;
            ca.recordTypeName = c.Record_Type_Developer_Name__c;  
            CAListWrapper.add(ca);
        }*/
        
        String community = TimeActivityController.getCommunityPathPrefix();
        String currentContact = TimeActivityController.getLoggedUserContactId();
        
        List<ContactAssignmentDomain.CAListWrapper> CAListWrapper = contactAssignmentTranslator.getCAListView(CAList, projectId,community,currentContact);
        
        System.debug('<<<<CAListWrapper>' + CAListWrapper);
        String projectRT;              
        
        if(project.size() > 0){
            projectRT = project[0].RecordType.DeveloperName;
        }
        System.debug('<<<<RecordType.DeveloperName>' + projectRT);
        List<String> CATabList = new List<String>();
        
        if(projectRT == 'CD_Projects' || projectRT == 'Translation_Projects' || projectRT == 'Linguist_Support_Projects' || projectRT == 'Admin_Projects') {
            instructorTabLabel = 'Direct Labor';
            staffTabLabel = 'Overhead';
            showStudentTab = false;
        }
        
        if(projectRT == 'Admin_Projects') {
            staffTabLabel = 'Staff';
            showInstructorTab = false;
        } 
        if(showStudentTab) {
            CATabList.add(studentTablabel);            
        }
        if(showInstructorTab) {
            CATabList.add(instructorTabLabel);            
        }
        CATabList.add(staffTabLabel); 
        
        //Sttaus filter condition
        if(projectRT == 'Translation_Projects' || projectRT == 'Interpretation_Projects'){
            statusList.addAll(defaultStatusSet);
        }
        
        else if (projectRT == 'MTT_Projects') {
            statusList.addAll(defaultStatusSet);
            statusList.add('Proposed');
        } else {
            statusList.addAll(defaultStatusSet);
        }
        
        
        ContactAssignmentWrapper CAWrapper = new ContactAssignmentWrapper();
        CAWrapper.CATabList = CATabList;
        CAWrapper.CAList = CAList;
        CAWrapper.CAListWrapper = CAListWrapper;
        CAWrapper.statusList = statusList;
        //CAListWrapper.statusList = statusList;
        System.debug('CAWrapper::::' + CAWrapper);
        return JSON.serialize(CAWrapper);
    }
    
    @AuraEnabled
    public static String getCARecordByStatus(String projectId, String status) {
        List<Contact_Assignments__c> CAList = new List<Contact_Assignments__c>();
        if(status != null){
            CAList = [SELECT 
                           Id, End_Date__c, Start_Date__c, Record_Type_Developer_Name__c, Assignment_Position__c, Status__c, candidate_name__r.name,candidate_name__r.firstname,candidate_name__r.lastname, RecordType.DeveloperName  
                           FROM Contact_Assignments__c 
                           WHERE Project__c = :projectId and RecordType.DeveloperName IN ('Student','Instructor','Staff') and Status__c = :status ORDER BY candidate_name__r.firstname ASC];        
        }else {
             CAList = [SELECT 
                       Id, End_Date__c, Start_Date__c, Record_Type_Developer_Name__c, Assignment_Position__c, Status__c, candidate_name__r.name,candidate_name__r.firstname,candidate_name__r.lastname, RecordType.DeveloperName  
                       FROM Contact_Assignments__c 
                       WHERE Project__c = :projectId and RecordType.DeveloperName IN ('Student','Instructor','Staff') and Status__c != null ORDER BY candidate_name__r.firstname ASC];        
        }
        
        String community = TimeActivityController.getCommunityPathPrefix();
        String currentContact = TimeActivityController.getLoggedUserContactId();
        
        List<ContactAssignmentDomain.CAListWrapper> CAListWrapper = contactAssignmentTranslator.getCAListView(CAList, projectId,community,currentContact);
        return JSON.serialize(CAListWrapper);
    }
    
    public class ContactAssignmentWrapper {
        public List<String> CATabList;
        public List<Contact_Assignments__c> CAList;
        public List<ContactAssignmentDomain.CAListWrapper> CAListWrapper;
        public List<String> statusList;
    }
    
    public class CAListWrapper {
        public String contactId;
        public String contactName;
        public String caId;
        public String projectId;
        public Date startDate;
        public Date endDate;
        public String status;
        public String position;
        public String recordTypeName;
    }
    
}