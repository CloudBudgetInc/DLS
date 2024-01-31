@isTest
public class FindPartnerSchool_Compo_Ctrl_Test {
     
     @testSetup static void setup(){
         List<MTT_Location__c> locList = TestClassUtil.createTestLocations();         
     }
     
     public static testMethod void myTest() {
         
         List<MTT_Location__c> locationList = [Select Id, Name From MTT_Location__c Limit 3];
         
         FindPartnerSchool_Compo_Ctrl.getlatitudeRec('68','97');
         FindPartnerSchool_Compo_Ctrl.getUserRelatedContactdetail();
         FindPartnerSchool_Compo_Ctrl.geoCodeFinder('KK street','TMW','Test','XXX','12345');
         FindPartnerSchool_Compo_Ctrl.getMttLocationRec(new List<Id>{locationList[0].Id});
         FindPartnerSchool_Compo_Ctrl.getSchooldetailRec('US','Test State');
         FindPartnerSchool_Compo_Ctrl.getSchooldetailRec('AA','Test State');
     }
}