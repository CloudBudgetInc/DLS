/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 05/12/2023
 * @last modified by  : Dhinesh Kumar
**/
public with sharing class StaffTimeEntryDomain {
    public Class Filter{
        public List<ListViewController.PicklistWrap> weekRanges;
        public String selectedWeek;
        public String employeeName;
        public String contactId;        
        public projectAndCAInfo projectAndCA;
        public String supervisorName;
    }

    public Class projectAndCAInfo{
        public List<ListViewController.PicklistWrap> projects;
        public Map<Id, Contact_Assignments__c> projectIdWithCAMap;
    }
}