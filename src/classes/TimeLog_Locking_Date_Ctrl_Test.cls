@isTest
public class TimeLog_Locking_Date_Ctrl_Test{
    static testMethod void myTest() {
        System_Values__c sys = new System_Values__c(name='TimeLog_Locking_Date',Value__c = '2014-10-28');
        Insert sys;
        TimeLog_Locking_Date_Ctrl.updateTimeLogLockVal('2015-10-28');
        TimeLog_Locking_Date_Ctrl.queryTimeLogLockVal();
    }
}