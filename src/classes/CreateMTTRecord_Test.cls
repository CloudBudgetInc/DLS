@isTest
public class CreateMTTRecord_Test{
    @testsetup static void setup() {
        List<Task_Order__c> toList = TestClassUtil.createTaskOrder();
    } 
    
    static testmethod void mttRec() {
        List<Task_Order__c> toList = [SELECT Id,Name FROM Task_Order__c LIMIT 5];
        if( toList != null && toList.size() > 0 ) {
            createMTTRecord.createMTTRec(toList[0].Id);
        }
    }
}