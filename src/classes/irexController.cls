public with sharing class irexController{
    
    public transient List<Opportunity> currentOpp {get; set;}
    public Date firstDay {get; set;}
    public Date lastDay {get; set;}
    public irexController(){
            Date currentDate = date.today();
            firstDay = currentDate.toStartofWeek();
            lastDay = firstDay.addDays(7);
            currentOpp = [SELECT English_Exam_Date_Time__c,
             Candidate_Name__r.Name, IREX_Number__c, English_Oral_Exam_Speaking__c, English_Oral_Exam_Listening__c,
              English_Oral_Exam_Reading__c, English_Exam_Writing__c 
                                     FROM Opportunity WHERE Recordtype.Name='IREX Testing' 
                                     AND English_Exam_Date_Time__c >= :firstDay 
                                     AND English_Exam_Date_Time__c <= :lastDay];
        }
    
@isTest
    static public void testirexController() {
//load data
Recordtype rt = [Select ID from RecordType where name ='Candidate' and SobjectType = 'Contact'];
    Account Acc2 = new Account();
    Acc2.Name = 'ESTest Account';
    Database.insert(Acc2);
    Contact testee1 = new Contact(RecordTypeId=rt.id, AccountId = Acc2.Id, FirstName = 'John', LastName = 'Smith');
    Contact testee2 = new Contact(RecordTypeId=rt.id, AccountId = Acc2.Id, FirstName = 'Hideo', LastName = 'Suzuki');
        insert new Contact[]{testee1, testee2};
    Opportunity opp1 = new Opportunity(RecordTypeId='01260000000LxYq',
    Name='Test1', StageName = 'Active', CloseDate = date.today(), English_Exam_Date_Time__c=date.today(), AccountId = Acc2.Id,
    Candidate_Name__c=testee1.Name, IREX_Number__c=1,
    English_Oral_Exam_Speaking__c='1', English_Oral_Exam_Listening__c='2',
    English_Oral_Exam_Reading__c='2', English_Exam_Writing__c='1+');
    Opportunity opp2 = new Opportunity(RecordTypeId='01260000000LxYq',
    Name='Test2', StageName = 'Closed Won', CloseDate = date.today(), English_Exam_Date_Time__c=date.today(), AccountId = Acc2.Id,
    Candidate_Name__c=testee2.Name, English_Oral_Exam_Speaking__c='1', 
    English_Oral_Exam_Listening__c='2', English_Oral_Exam_Reading__c='2', IREX_Number__c=2,
     English_Exam_Writing__c='1+');
    //insert new Opportunity[]{opp1,opp2};
    //run logic
    Test.setCurrentPage(Page.irextesting);
    irexController cvsc = new irexController();
    //assertion: merchandise is not empty
    //System.assertNotEquals(cvsc.currentOpp.size(),0);
    ApexPages.currentPage().getParameters().put('random', 'true');
}

}