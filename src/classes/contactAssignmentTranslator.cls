global class contactAssignmentTranslator {

    global static Set<Id> contactAssignmentinfo( List<Contact_Assignments__c> contactAssignmentList ) {
        
        Set<Id> contactIdSet = new Set<Id>();
        
        for(Contact_Assignments__c conAssign : contactAssignmentList){
            contactIdSet.add(conAssign.Candidate_Name__c);
        }
        
        return contactIdSet;
    }
    
    
    /*************************************************************************************************************
    Created by Karthiga on Feb 06, 2017: Translator method used for AssignmentTabComponent inner class formation
    return - instance for InstructorAssignInnerClass - inner class
    **************************************************************************************************************/
    global static List<ContactAssignmentDomain.InstructorAssignInnerClass> insDetailsMethod(List<contact_Assignments__c> caList, Map<Id, List<SelectOption>> conIdCRMap) {
        List<ContactAssignmentDomain.InstructorAssignInnerClass> insList = new List<ContactAssignmentDomain.InstructorAssignInnerClass>();
        
        for(contact_Assignments__c ca : caList) {
            ContactAssignmentDomain.InstructorAssignInnerClass ins = new ContactAssignmentDomain.InstructorAssignInnerClass();
            //ins.isEdit = false;
            //ins.index = insList.size();
            ins.conAssign = ca;
            ins.costRates = ( ( conIdCRMap != null && conIdCRMap.containskey(ca.Candidate_Name__c) ) ? conIdCRMap.get(ca.Candidate_Name__c) : new List<SelectOption>{new SelectOption('','---None---')});
            ins.hasOPLIPT = (ca.Project_Task__c != null || ca.Opportunity_Product_Id__c != null) ? true : false;
            ins.isAwarded = (ca.Status__c == 'Awarded' ? true : false);
            //ins.AssignToActiveSchedules = false;
            insList.add(ins);
        }
        
        return insList;
    }
    
    /*************************************************************************************************************
    Created by Jain S on April 01, 2019: Translator method used for form contact assignment listview records in
    instructor community Project detail view
    **************************************************************************************************************/
    public static List<ContactAssignmentDomain.CAListWrapper> getCAListView(List<contact_Assignments__c> caList, String projectId,String community, String contactId) {
        List<ContactAssignmentDomain.CAListWrapper> caListView = new List<ContactAssignmentDomain.CAListWrapper>();
        String communityName = EventCalendarController.getCommunityPathPrefix();
        
        for(contact_Assignments__c ca : caList) {
            
            ContactAssignmentDomain.CAListWrapper ins = new ContactAssignmentDomain.CAListWrapper();
            ins.contactId = ca.Candidate_Name__r.Id;
            if((communityName == 'student' && (ca.Record_Type_Developer_Name__c == 'Student' || ca.Record_Type_Developer_Name__c == 'Instructor')) || (communityName == 'instructor' && ca.Record_Type_Developer_Name__c == 'Instructor')) {
                ins.contactName = ca.Candidate_Name__r.firstname+' '+ca.Candidate_Name__r.lastname.substring(0,1);
            } else {
                ins.contactName = ca.Candidate_Name__r.name;
            }
            ins.caId = ca.Id;
            ins.projectId = projectId;
            ins.startDate = ca.Start_Date__c;
            ins.endDate = ca.End_Date__c;
            ins.status = ca.Status__c;
            ins.position = ca.Assignment_Position__c;
            ins.recordTypeName = ca.Record_Type_Developer_Name__c;   
            
            if(community == 'instructor' && ((ca.RecordType.DeveloperName == 'Instructor' && ca.Candidate_Name__c == contactId) 
                || ca.RecordType.DeveloperName != 'Instructor')){
            
                caListView.add(ins);
            }else if(community == 'Student'){
                caListView.add(ins);
            }else if(community == 'client'){
                caListView.add(ins);
            }
            
            
        }
        
        return caListView;
    }
}