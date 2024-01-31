@isTest
public  class TestMergeRecordsController {
    @testSetup static void setup() {
        List<Materials_Request__c> matReq = TestClassUtil.createTestMaterialRequest();
    }
    
    public static testmethod void myTest(){
    
        /*Account accountObjOne = new Account();
        Account accountObjTwo = new Account();
        Account accountObjThree = new Account();
        
        accountObjOne.Name = 'test1';
        insert accountObjOne;
        
        accountObjTwo.Name = 'test2';
        insert accountObjTwo;
        
        accountObjThree.Name = 'test3';
        insert accountObjThree;
        
        Contact contactOne = new Contact();
        contactOne.FirstName = 'testcon';
        contactOne.LastName = 'tes';
        contactOne.Email = 'Test@gamil.com';
        contactOne.AccountId = accountObjOne.Id;
        insert contactOne;
        
        Contact contactTwo = new Contact();
        contactTwo.FirstName = 'testcon';
        contactTwo.LastName = 'tes';
        contactTwo.Email = 'Test@gamil.com';
        contactTwo.AccountId = accountObjTwo.Id;
        insert contactTwo;*/

        /*Merge_Sobjects__c mergeObj = new Merge_Sobjects__c();
        mergeObj.Name = 'Merge Records';
        mergeObj.Enable_activities__c = true;
        insert mergeObj;*/
        
        Test.StartTest();
        List<Materials__c> MaList = new List<Materials__c>{
            new Materials__c(Name = 'Test 3',Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish')
        };
      
        insert MaList;
    
        List<Materials__c> MaterialsList = [SELECT Id, Name, OwnerId FROM Materials__c LIMIT 3];
        System.debug('::::MaterialsList:::'+MaterialsList[0].OwnerId);
        List<Materials_Request__c> MatReqList = [SELECT Id, Name, Materials_Name__c FROM Materials_Request__c];
        
        if(MatReqList != Null && MatReqList.size() > 0) {
            MatReqList[0].Materials_Name__c = MaterialsList[2].Id;
            update MatReqList;
        }
        
        Apexpages.currentPage().getParameters().put('RecordOneId',MaterialsList[0].Id);
        Apexpages.currentPage().getParameters().put('RecordTwoId',MaterialsList[1].Id);
        ApexPages.currentPage().getParameters().put('RecordThreeId',MaterialsList[2].Id);
        
        mergerecordscontroller mergecon = new mergerecordscontroller();
        system.debug('::::Mer::::'+mergecon.GeneralInfoList[0]);
        system.debug(':::Mer:::::'+mergecon.GeneralInfoList[1]);
        system.debug('::::Mer::::'+mergecon.GeneralInfoList[0].SelectedValue);
        
        system.debug('::::::::'+mergecon.GeneralInfoList[1].SelectedValue);
        
        List<Materials_Request__c> marReqBeforeReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[1].Id];
        
        //Material Request record size is Zero before Re-Parenting for the Material Record (MaterialsList[1])
        System.assertEquals(0,marReqBeforeReParen.size());
        
        for(Integer i = 0; i < mergecon.GeneralInfoList.size(); i++) {
           
            if(mergecon.GeneralInfoList[i].objFieldName == 'OwnerId' ) {
                mergecon.GeneralInfoList[i].SelectedValue = MaterialsList[1].OwnerId;
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Inactive__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = 'False';
            }
            
        }
        mergecon.GeneralInfoList[0].SelectedValue = MaterialsList[1].Id;
        
        mergecon.enableactivity = true;
        mergecon.mergerecords();
        mergecon.cancel(); 
        
        List<Materials_Request__c> marReqAfterReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[1].Id];
        
        //Material Request record size is two before Re-Parenting for the Material Record (MaterialsList[1])
        System.assertEquals(2,marReqAfterReParen.size());
  
     /*   mergecon.GeneralInfoList[0].SelectedValue = MaterialsList[2].Id;
        mergecon.mergerecords();

        mergecon.GeneralInfoList[1].SelectedValue = MaterialsList[0].Id;
        mergecon.mergerecords();
        
        mergecon.GeneralInfoList[1].SelectedValue = MaterialsList[1].Id;
        //Added
        mergecon.enableactivity = true;
        //Ended
        mergecon.mergerecords(); */

        Test.stopTest();
    }
    
    public static testmethod void myTest1(){

        Test.StartTest();
        List<Materials__c> MaList = new List<Materials__c>{
            new Materials__c(Name = 'Test 3',Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish')
        };
      
        insert MaList;
    
        List<Materials__c> MaterialsList = [SELECT Id, Name, OwnerId, Number_of_Requests__c, Cost__c, Last_Ordered__c FROM Materials__c LIMIT 3];

        List<Materials_Request__c> MatReqList = [SELECT Id, Name, Materials_Name__c FROM Materials_Request__c];
        
        if(MatReqList != Null && MatReqList.size() > 0) {
            MatReqList[0].Materials_Name__c = MaterialsList[2].Id;
            update MatReqList;
        }
        
        Apexpages.currentPage().getParameters().put('RecordOneId',MaterialsList[0].Id);
        Apexpages.currentPage().getParameters().put('RecordTwoId',MaterialsList[1].Id);
        ApexPages.currentPage().getParameters().put('RecordThreeId',MaterialsList[2].Id);
        
        mergerecordscontroller mergecon = new mergerecordscontroller();
       
        List<Materials_Request__c> marReqBeforeReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[0].Id];
        
        //Material Request record size is Zero before Re-Parenting for the Material Record (MaterialsList[0])
        System.assertEquals(1,marReqBeforeReParen.size());
        
        for(Integer i = 0; i < mergecon.GeneralInfoList.size(); i++) {
           
            if(mergecon.GeneralInfoList[i].objFieldName == 'OwnerId' ) {
                mergecon.GeneralInfoList[i].SelectedValue = MaterialsList[0].OwnerId;
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Inactive__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = 'False';
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Number_of_Requests__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = String.valueOf(MaterialsList[0].Number_of_Requests__c);
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Cost__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = String.valueOf(MaterialsList[0].Cost__c); 
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Last_Ordered__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = String.valueOf(MaterialsList[0].Last_Ordered__c); 
            }
           
        }
        mergecon.GeneralInfoList[0].SelectedValue = MaterialsList[0].Id;
        
        mergecon.enableactivity = true;
        mergecon.mergerecords();
        
        List<Materials_Request__c> marReqAfterReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[0].Id];
        
        //Material Request record size is two before Re-Parenting for the Material Record (MaterialsList[0])
        System.assertEquals(2,marReqAfterReParen.size());
        
        Test.stopTest();
    }
    
    public static testmethod void myTest2(){

        Test.StartTest();
        List<Materials__c> MaList = new List<Materials__c>{
            new Materials__c(Name = 'Test 3',Book_Series__c = 'SN0012', Cost__c = 40,Author__c = 'Harry Potter',ISBN__c = '76542965',Language__c = 'Danish')
        };
      
        insert MaList;
    
        List<Materials__c> MaterialsList = [SELECT Id, Name, OwnerId FROM Materials__c LIMIT 3];

        List<Materials_Request__c> MatReqList = [SELECT Id, Name, Materials_Name__c FROM Materials_Request__c];
        
        if(MatReqList != Null && MatReqList.size() > 0) {
            MatReqList[0].Materials_Name__c = MaterialsList[2].Id;
            update MatReqList;
        }
        
        Apexpages.currentPage().getParameters().put('RecordOneId',MaterialsList[0].Id);
        Apexpages.currentPage().getParameters().put('RecordTwoId',MaterialsList[1].Id);
        ApexPages.currentPage().getParameters().put('RecordThreeId',MaterialsList[2].Id);
        
        mergerecordscontroller mergecon = new mergerecordscontroller();
       
        List<Materials_Request__c> marReqBeforeReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[2].Id];
        
        //Material Request record size is Zero before Re-Parenting for the Material Record (MaterialsList[2])
        System.assertEquals(1,marReqBeforeReParen.size());
        
        for(Integer i = 0; i < mergecon.GeneralInfoList.size(); i++) {
           
            if(mergecon.GeneralInfoList[i].objFieldName == 'OwnerId' ) {
                mergecon.GeneralInfoList[i].SelectedValue = MaterialsList[1].OwnerId;
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Inactive__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = 'False';
            }
            
        }
        mergecon.GeneralInfoList[0].SelectedValue = MaterialsList[2].Id;
        
        mergecon.enableactivity = true;
        mergecon.mergerecords();
        
        List<Materials_Request__c> marReqAfterReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[2].Id];
        
        //Material Request record size is two before Re-Parenting for the Material Record (MaterialsList[2])
        System.assertEquals(2,marReqAfterReParen.size());
        
        Test.stopTest();
    }
     
    public static testmethod void myTest3(){
  
        Test.StartTest();
       
        List<Materials__c> MaterialsList = [SELECT Id, Name, OwnerId FROM Materials__c LIMIT 2];

        List<Materials_Request__c> MatReqList = [SELECT Id, Name, Materials_Name__c FROM Materials_Request__c];
        
        if(MatReqList != Null && MatReqList.size() > 0) {
            MatReqList[0].Materials_Name__c = MaterialsList[1].Id;
            update MatReqList;
        }
        
        Apexpages.currentPage().getParameters().put('RecordOneId',MaterialsList[0].Id);
        Apexpages.currentPage().getParameters().put('RecordTwoId',MaterialsList[1].Id);
        
        mergerecordscontroller mergecon = new mergerecordscontroller();
               
        List<Materials_Request__c> marReqBeforeReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[1].Id];
        
        //Material Request record size is Zero before Re-Parenting for the Material Record (MaterialsList[1])
        System.assertEquals(1,marReqBeforeReParen.size());
        
        for(Integer i = 0; i < mergecon.GeneralInfoList.size(); i++) {
           
            if(mergecon.GeneralInfoList[i].objFieldName == 'OwnerId' ) {
                mergecon.GeneralInfoList[i].SelectedValue = MaterialsList[1].OwnerId;
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Inactive__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = 'False';
            }
            
        }
        mergecon.GeneralInfoList[0].SelectedValue = MaterialsList[1].Id;
       
        mergecon.enableactivity = true;
        mergecon.mergerecords();
        mergecon.cancel(); 
        
        List<Materials_Request__c> marReqAfterReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[1].Id];
        
        //Material Request record size is two before Re-Parenting for the Material Record (MaterialsList[1])
        System.assertEquals(2,marReqAfterReParen.size());

        Test.stopTest();
    }
    
    public static testmethod void myTest4(){
  
        Test.StartTest();
       
        List<Materials__c> MaterialsList = [SELECT Id, Name, OwnerId FROM Materials__c LIMIT 2];

        List<Materials_Request__c> MatReqList = [SELECT Id, Name, Materials_Name__c FROM Materials_Request__c];
        
        if(MatReqList != Null && MatReqList.size() > 0) {
            MatReqList[0].Materials_Name__c = MaterialsList[1].Id;
            update MatReqList;
        }
        
        Apexpages.currentPage().getParameters().put('RecordOneId',MaterialsList[0].Id);
        Apexpages.currentPage().getParameters().put('RecordTwoId',MaterialsList[1].Id);
        
        mergerecordscontroller mergecon = new mergerecordscontroller();
               
        List<Materials_Request__c> marReqBeforeReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[0].Id];
        
        //Material Request record size is Zero before Re-Parenting for the Material Record (MaterialsList[0])
        System.assertEquals(1,marReqBeforeReParen.size());
        
        for(Integer i = 0; i < mergecon.GeneralInfoList.size(); i++) {
           
            if(mergecon.GeneralInfoList[i].objFieldName == 'OwnerId' ) {
                mergecon.GeneralInfoList[i].SelectedValue = MaterialsList[0].OwnerId;
            } else if(mergecon.GeneralInfoList[i].objFieldName == 'Inactive__c' ) {
                mergecon.GeneralInfoList[i].SelectedValue = 'False';
            }
            
        }
        mergecon.GeneralInfoList[0].SelectedValue = MaterialsList[0].Id;
       
        mergecon.enableactivity = true;
        mergecon.mergerecords();
        mergecon.cancel(); 
        
        List<Materials_Request__c> marReqAfterReParen = [SELECT Id, Name FROM Materials_Request__c WHERE Materials_Name__r.Id = :MaterialsList[0].Id];
        
        //Material Request record size is two before Re-Parenting for the Material Record (MaterialsList[0])
        System.assertEquals(2,marReqAfterReParen.size());

        Test.stopTest();
    }
}