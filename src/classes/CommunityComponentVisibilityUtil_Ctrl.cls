//Created By Dhinesh - 31/05/2022 - To get Component Visibility by Community Name
public without sharing class CommunityComponentVisibilityUtil_Ctrl {
    @AuraEnabled    
    public static Map<String, Map<String, Boolean>> getComponentVisibilities(){
        String communityName = EventCalendarController.getCommunityPathPrefix().toLowercase(); 
        System.debug('communityName::>'+communityName);
        if(communityName == 'client' || Test.isRunningTest()){
            String contactId = EventCalendarController.getLoggedUserContactId(); 
            System.debug('contactId::>'+contactId);
            List<Contact_Assignments__c> contAssignments = [SELECT Id FROM Contact_Assignments__c 
                                                                                                   WHERE Candidate_Name__r.RecordType.DeveloperName IN ('USG_Client', 'Commercial_Client')
                                                                                                   AND Candidate_Name__c = :contactId AND RecordType.DeveloperName = 'Client_Partner' 
                                                                                                   AND Assignment_Position__c IN ('Coordinator','Client','Training Officer','Billing Contact','Academic Adviser','COR','KO','Contracting POC','Technical POC')
                                                                                                   AND Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects'
                                                                                                 ];
            System.debug('contAssignments::>'+contAssignments);
            if(contAssignments.size() > 0){
                communityName = 'DLI Client';
            }
        }
        System.debug('communityName::>'+communityName);
        Map<String, Map<String, Boolean>> tabNameWithSectionVisibiltyMap = new Map<String, Map<String, Boolean>>();
        for(Community_Component_Visibility__mdt communityCmpVisibility : [SELECT Tab_Name__c, Section_Name__c, Visible__c
                                                                                                                             FROM Community_Component_Visibility__mdt
                                                                                                                             WHERE Community_Type__c = :communityName]){
            String tabName = communityCmpVisibility.Tab_Name__c.replaceAll(' ','_');                                                                                                                            
            if(!tabNameWithSectionVisibiltyMap.containsKey(tabName)){
                tabNameWithSectionVisibiltyMap.put(tabName, new Map<String, Boolean>());                                                                                                                              
            }
            tabNameWithSectionVisibiltyMap.get(tabName).put(communityCmpVisibility.Section_Name__c, communityCmpVisibility.Visible__c);                                                                          
        }
        
        return tabNameWithSectionVisibiltyMap;
    }

}