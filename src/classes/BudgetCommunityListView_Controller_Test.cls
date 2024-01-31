@isTest
public class BudgetCommunityListView_Controller_Test {

    @testsetup static void setup() {
    
        List<Contact_Assignments__c> cALst = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<Materials_Request__c> matReqList = TestClassUtil.createTestMaterialRequest();
            List<AcctSeed__Project_Task__c> projTask  = TestClassUtil.createTestProjectTask();
        Test.stopTest();
    } 
    
    // if login as Instructor Community User
    private static testMethod void testMethod1() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Instructor Community'];
        List<Contact_Assignments__c> cAList = [SELECT Id,Candidate_name__c FROM Contact_Assignments__c LIMIT 1];
        
        if(profileLst.size() > 0 && conList.size() > 0){
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conList[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            String cAStuRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId(); 
            
            for(Contact_Assignments__c ca : cAList){
                ca.RecordTypeId = cAStuRT;
                ca.Candidate_name__c = user.ContactId;
            }
            
            Test.startTest();
            
                update cAList;
                            
                List<AcctSeed__Project__c> projList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 1];  
                String proTaskRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
                String proTaskMatRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Material_Budget').getRecordTypeId();
                String matReqRT = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
                String matLoanRT = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
                List<Materials_Request__c> matReqlist = [SELECT Id,Name,Request_Status__c,Date_Delivered__c,Materials_Name__r.Name,DLS_Sales_Tax_Formula__c,Qty__c,DLS_Total__c FROM Materials_Request__c LIMIT 2];
                        
                if(projList.size() > 0 ){
                
                    List<AcctSeed__Project_Task__c> projTaskList = [SELECT Id, Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projList[0].Id]; 
                    
                    if(projTaskList.size() > 0){
                        
                        projTaskList[0].RecordTypeId = proTaskRT;
                        projTaskList[0].Total_Qty_Planned__c = 12.00;
                        projTaskList[0].Project_Task_Type__c = 'Language Training';
                        projTaskList[0].Unit__c = 'Hrs';
                        projTaskList[0].Total_Hours__c = 10;
                                            
                        update projTaskList;
                                               
                        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c LIMIT 1];
                        
                        List<Acctseed__Project_Task__c> proTaskList = new List<Acctseed__Project_Task__c> {
                            new Acctseed__Project_Task__c(RecordTypeId = proTaskRT,AcctSeed__Project__c = projList[0].Id,Parent_Project_Task__c = projTaskList[0].Id,Total_Qty_Planned__c = 8.00,Project_Task_Type__c = 'Preparation time',Unit__c = 'Hrs',Total_Hours__c = 5,AcctSeed__Labor_GL_Account__c = glAccList[0].Id) ,
                            new Acctseed__Project_Task__c(RecordTypeId = proTaskMatRT,AcctSeed__Project__c = projList[0].Id,Total_Amount_Paid__c = 7.00,Total_Qty_Planned__c = 15.00,Rate__c = 5.00,Project_Task_Type__c = 'Material budget',Unit__c = 'Hrs',Total_Hours__c = 5,AcctSeed__Labor_GL_Account__c = glAccList[0].Id )
                        };
                        insert proTaskList;
                        
                        matReqlist[0].Project__c = projList[0].Id;
                        matReqlist[0].RecordTypeId = matReqRT;
                        
                        matReqlist[1].Project__c = projList[0].Id;
                        matReqlist[1].RecordTypeId = matLoanRT;
                        update matReqlist;
                            
                        system.runas(user){
                          String BudgetInfo =  BudgetCommunityListView_Controller.getInitialBudgetRecords(projList[0].Id);
                            ProjectTaskDomain.BudgetInformation budgetInformation = (ProjectTaskDomain.BudgetInformation) JSON.deserialize(BudgetInfo,ProjectTaskDomain.BudgetInformation.class);
                            List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projList[0].Id AND RecordType.DeveloperName = 'Language_Training' AND Project_Task_Type__c IN ('Language Training','Preparation time')];    
                            System.assertEquals(3,budgetInformation.serviceSectionInfo.size());
                        }
                    }
                }
            Test.stopTest();
        }
    }
    
    // if login as Student Community User
    private static testMethod void testMethod2() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Instructor Community'];
        List<Contact_Assignments__c> cAList = [SELECT Id,Candidate_name__c FROM Contact_Assignments__c LIMIT 1];
        String matReqRT = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
        String matLoanRT = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
        List<Materials_Request__c> matReqlist = [SELECT Id,Name,Request_Status__c,Date_Delivered__c,Materials_Name__r.Name,DLS_Sales_Tax_Formula__c,Qty__c,DLS_Total__c FROM Materials_Request__c LIMIT 2];
        
        if(profileLst.size() > 0 && conList.size() > 0){
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conList[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            String cAStuRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId(); 
            
            for(Contact_Assignments__c ca : cAList){
                ca.RecordTypeId = cAStuRT;
                ca.Candidate_name__c = user.ContactId;
            }
            
            Test.startTest();
                  
                update cAList;
            
                List<AcctSeed__Project__c> projList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 1];  
                String proTaskRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
                String proTaskMatRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Material_Budget').getRecordTypeId();
                        
                if(projList.size() > 0 ){
                            
                    List<AcctSeed__Project_Task__c> projTaskList = [SELECT Id, Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projList[0].Id];  
                        
                    if(projTaskList.size () > 0) {
                    
                        projTaskList[0].RecordTypeId = proTaskRT;
                        projTaskList[0].Total_Qty_Planned__c = 12.00;
                        projTaskList[0].Project_Task_Type__c = 'Language Training';
                        projTaskList[0].Unit__c = 'Hrs';
                        projTaskList[0].Total_Hours__c = 0;
                                                
                        update projTaskList;
                        
                        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c LIMIT 1];
                        
                        List<Acctseed__Project_Task__c> proTaskList = new List<Acctseed__Project_Task__c> {
                            new Acctseed__Project_Task__c(RecordTypeId = proTaskMatRT,AcctSeed__Project__c = projList[0].Id,Total_Amount_Paid__c = 7.00,Total_Qty_Planned__c = 25.00,Rate__c = 5.00,Project_Task_Type__c = 'Material budget',Unit__c = 'Hrs',Total_Hours__c = 15,AcctSeed__Labor_GL_Account__c = glAccList[0].Id),
                            new Acctseed__Project_Task__c(RecordTypeId = proTaskMatRT,AcctSeed__Project__c = projList[0].Id,Total_Amount_Paid__c = 7.00,Total_Qty_Planned__c = 15.00,Rate__c = 5.00,Project_Task_Type__c = 'Material budget',Unit__c = 'Hrs',Total_Hours__c = 0,AcctSeed__Labor_GL_Account__c = glAccList[0].Id)
                        };
                        insert proTaskList;
                        
                        matReqlist[0].Project__c = projList[0].Id;
                        matReqlist[0].RecordTypeId = matReqRT;
                        
                        matReqlist[1].Project__c = projList[0].Id;
                        matReqlist[1].RecordTypeId = matReqRT;
                        update matReqlist;
                            
                        system.runas(user){
                            String BudgetInfo =  BudgetCommunityListView_Controller.getInitialBudgetRecords(projList[0].Id);
                            ProjectTaskDomain.BudgetInformation budgetInformation = (ProjectTaskDomain.BudgetInformation) JSON.deserialize(BudgetInfo,ProjectTaskDomain.BudgetInformation.class);
                            List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projList[0].Id AND RecordType.DeveloperName = 'Material_Budget']; 
                            System.debug('projectTaskList==='+projectTaskList.size());   
                            //System.assertEquals(projectTaskList.Size()+1,budgetInformation.materialSectionInfo.size());
                        }
                    }
                }
            Test.stopTest();
        }
    }
}