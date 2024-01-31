@isTest
private class TestUpdateMaterialRequestName_Trigger {
    
    @testSetup static void setup(){
        
         List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
         
        Test.startTest();
            List<AcctSeed__Project_Task__c> taskList = TestClassUtil.createTestProjectTask();
            List<Materials_Stock__c> matStockList = TestClassUtil.createMaterialsStock();
        Test.stopTest();
        
    }
    
    // To update the material name based on the record type
    private static testMethod void testMethod1() {
        
        Test.startTest();
        
        List<Materials_Request__c> matReqList = insertMatReq();
        
        if(matReqList.size() > 0) {
            
            List<Materials_Request__c> matReqUp = [SELECT Id, Name,DLS_Class_Number__c, Project__r.DLS_Ref__c, Date_Returned__c FROM Materials_Request__c WHERE Project__c != null AND RecordType.DeveloperName = 'Project_Materials_Request'];                 
            if(matReqUp.size() > 0) {
                System.debug('matReqUp[0].Name:::'+matReqUp[0]);
                System.assert(matReqUp[0].Name.contains(matReqUp[0].DLS_Class_Number__c+'-MR'));
            }
                       
            matReqList[0].DLS_Sales_Tax_Applicable__c = true;
            matReqList[0].Request_Status__c = 'Canceled';
            matReqList[1].Request_Status__c = 'Returned';
            update matReqList;
            
            Test.stopTest(); 
               
            List<Materials_Request__c> matReq = [SELECT Id, Name, Project__c, Date_Returned__c FROM Materials_Request__c WHERE Id = :matReqList[1].Id];  
           
            if(matReq.size() > 0) {
                System.assertEquals(System.today(), matReq[0].Date_Returned__c);
            } 
        }
    } 
    
    // To update the material name based on the record type
    private static testMethod void testMethod2() {
                
        List<Materials_Request__c> matReqList = insertMatReq();
        List<RecordType> rType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType IN ('Materials_Request__c', 'AcctSeed__Project__c') AND DeveloperName IN ('Material_Transfer', 'Project_Materials_Request', 'Facilities_Project')];
        
        if(matReqList.size() > 0 && rType.size() > 0) {
            
            List<Materials_Request__c> matReqUp = [SELECT Id, Name, Project__r.DLS_Ref__c, Date_Returned__c FROM Materials_Request__c WHERE Project__c != null AND RecordType.DeveloperName = 'Material_Loan_Request'];                 
            if(matReqUp.size() > 0) {
                System.assert(matReqUp[0].Name.contains(matReqUp[0].Project__r.DLS_Ref__c+'-ML'));
            }
          
            String matReqRtId, proRtId, proMatReqRtId;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'Material_Transfer')
                    matReqRtId = rt.Id;
                else if(rt.DeveloperName == 'Facilities_Project')
                    proRtId = rt.Id;
                else if(rt.DeveloperName == 'Project_Materials_Request')
                    proMatReqRtId = rt.Id;
            }
            Test.startTest();
            
            List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c WHERE Id != :matReqList[0].Target_Location__c LIMIT 2];
                        
            String projId;
            
            for(Materials_Request__c matReq : matReqList) {
                if(matReq.Project__c != null && matReq.RecordTypeId == proMatReqRtId){
                    projId = matReq.Project__c;
                    
                    matReq.Request_Status__c = 'Delivered'; 
                    matReq.Date_Delivered__c = System.today().addDays(5);
                    matReq.Materials_Source__c = 'Vendor Purchase';
                    matReq.Request_type__c = 'Library';
                    if(locList.size() > 0) {
                        matReq.Target_Location__c = locList[0].Id;
                    } 
                    
                } else {
                    matReq.RecordTypeId = matReqRtId;
                    if(locList.size() > 0) {
                        matReq.Target_Location__c = locList[0].Id;
                    }
                }
            
                List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id = :projId];
                if(proList.size() > 0) {
                    proList[0].RecordTypeId = proRtId;
                    update proList;
                }
                update matReqList;
            }
            Test.stopTest();
        }
    } 
    
    // To update the material name based on the record type
    private static testMethod void testMethod3() {
        
        Test.startTest(); 
        
        List<Materials_Request__c> matReqList = insertMatReq();
        List<Materials_Stock__c> msListDel = [SELECT Id, Name FROM Materials_Stock__c];
        if(msListDel.size() > 0) {
            delete msListDel;
        }
        
        if(matReqList.size() > 0) {
            
            List<Materials_Request__c> matReqUp = [SELECT Id, Name, Class_Name__r.DLS_Ref__c, Date_Returned__c FROM Materials_Request__c WHERE Class_Name__c != null AND RecordType.DeveloperName = 'Material_Loan_Request'];                 
            if(matReqUp.size() > 0) {
                System.debug('matReqUp[0].Name:::'+matReqUp[0].Name);
                System.assert(matReqUp[0].Name.contains(matReqUp[0].Class_Name__r.DLS_Ref__c+'-ML'));
            }
            
            List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c WHERE Id != :matReqList[0].Target_Location__c LIMIT 2];
            List<RecordType> rType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Materials_Request__c' AND DeveloperName IN ('Material_Transfer', 'Material_Disposal')];
            
            if(locList.size() > 0 && rType.size() > 0) { 
                
                string matTransRtId, matDisRtId;
                
                for(RecordType rt : rType) {
                    if(rt.DeveloperName == 'Material_Transfer')
                        matTransRtId = rt.Id;
                    else if(rt.DeveloperName == 'Material_Disposal')
                        matDisRtId = rt.Id;
                }
                
                List<Materials_Stock__c> msList = new List<Materials_Stock__c> {
                    new Materials_Stock__c( Materials__c = matReqList[0].Materials_Name__c, Location__c = locList[0].Id),
                    new Materials_Stock__c( Materials__c = matReqList[1].Materials_Name__c, Location__c = locList[0].Id)
                };
                insert msList;
                
                matReqList[0].Materials_Stock__c = msList[0].Id;
                matReqList[1].Materials_Stock__c = msList[0].Id;
                matReqList[0].RecordTYpeId = matTransRtId;
                update matReqList;
                
                Test.stopTest(); 
                
                matReqList[0].Location__c = locList[0].Id;
                matReqList[1].Location__c = locList[0].Id;
                matReqList[1].RecordTYpeId = matDisRtId;
                update matReqList;
            }
        }
    } 
    
    // To insert the material request records
    private static List<Materials_Request__c> insertMatReq() {
        
         List<RecordType> matReqRT = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Materials_Request__c' AND DeveloperName IN ('Project_Materials_Request', 'Material_Loan_Request')];
         List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Client_Contact__c,AcctSeed__Project__c,Project_Task_Type__c,AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c != null LIMIT 2];
         List<Account> accList = [SELECT Id,Name FROM Account LIMIT 1];
         List<Materials__c> materialList = [ SELECT Id FROM Materials__c LIMIT 2 ];
         List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c LIMIT 2];
         List<Materials_Request__c> materialReq = new List<Materials_Request__c>();
         List<Opportunity> oppList = [SELECT Id,Name,StageName FROM Opportunity LIMIT 2];
         
         if(matReqRT.size() > 0 && projectTaskList.size() > 0 && accList.size() > 0 && materialList.size() > 0 && locList.size() > 0) {
            
            String proMatReqRtId, matLoanReqRtId;
            
            for(RecordType rt : matReqRT) {
                if(rt.DeveloperName == 'Project_Materials_Request')
                    proMatReqRtId = rt.Id;
                else if(rt.DeveloperName == 'Material_Loan_Request')
                    matLoanReqRtId = rt.Id;
            }
            
            materialReq = new List<Materials_Request__c> {
                new Materials_Request__c(Name = 'Test 1', RecordTypeId = proMatReqRtId, Project_Task__c = projectTaskList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = materialList[0].Id, Location__c  = locList[0].Id, Target_Location__c  = locList[0].Id, Skip_Paid_Remaining_Check__c = true),
                new Materials_Request__c(Name = 'Test 2', RecordTypeId = proMatReqRtId, Project_Task__c = projectTaskList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = materialList[0].Id, Location__c  = locList[0].Id, Target_Location__c  = locList[0].Id, Skip_Paid_Remaining_Check__c = true),
                new Materials_Request__c(Name = 'Test 3', RecordTypeId = proMatReqRtId, Class_Name__c = oppList[0].Id, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = materialList[0].Id, Location__c  = locList[0].Id, Target_Location__c  = locList[0].Id, Skip_Paid_Remaining_Check__c = true),
                new Materials_Request__c(Name = 'Test 4', RecordTypeId = matLoanReqRtId, Project_Task__c = projectTaskList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = materialList[0].Id, Location__c  = locList[0].Id, Target_Location__c  = locList[0].Id, Skip_Paid_Remaining_Check__c = true),
                new Materials_Request__c(Name = 'Test 5', RecordTypeId = matLoanReqRtId, Class_Name__c = oppList[0].Id, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = materialList[0].Id, Location__c  = locList[0].Id, Target_Location__c  = locList[0].Id, Skip_Paid_Remaining_Check__c = true)
            };
            insert materialReq;
        }
        
        return materialReq;
    }  
    
    private static testMethod void testMethod4(){
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Client_Contact__c,AcctSeed__Project__c,Project_Task_Type__c,AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c != null LIMIT 2];
        List<Account> accList = [SELECT Id,Name FROM Account LIMIT 1];
        List<Materials__c> materialList = [ SELECT Id FROM Materials__c LIMIT 2 ];
        List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c LIMIT 2];
        List<Opportunity> oppList = [SELECT Id,Name,StageName FROM Opportunity LIMIT 2];
        
        Test.startTest();
            Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
            AcctSeed__Project__c proj = new AcctSeed__Project__c();
            proj.Id = projectTaskList[0].AcctSeed__Project__c;
            proj.RecordTypeId = dodaRTId;
            update proj;
            
            Id proMatReqRtId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
            List<Materials_Request__c> materialReqs = new List<Materials_Request__c> {
                new Materials_Request__c(Name = 'Test 1', RecordTypeId = proMatReqRtId, Project_Task__c = projectTaskList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = materialList[0].Id, Location__c  = locList[0].Id, Target_Location__c  = locList[0].Id, Skip_Paid_Remaining_Check__c = true),
                new Materials_Request__c(Name = 'Test 2', RecordTypeId = proMatReqRtId, Project_Task__c = projectTaskList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = materialList[0].Id, Location__c  = locList[0].Id, Target_Location__c  = locList[0].Id, Skip_Paid_Remaining_Check__c = true)
            
            };
            insert materialReqs;
            
            List<Materials_Request__c> matReqs = [SELECT Id, GSA_Fee_Applicable__c, GSA_Fee_Percentage__c FROM Materials_Request__c WHERE Id IN : materialReqs];
            System.assertEquals(True, matReqs[0].GSA_Fee_Applicable__c);
            System.assertEquals(.75, matReqs[0].GSA_Fee_Percentage__c);
            
        Test.stopTest();
    }   
    
    // To cover sendLMSEnrollmentEmail() method in MaterialsRequestTrigger_Handler
    private static testMethod void testMethod5(){
        
        List<Account> accList = [SELECT Id,Name FROM Account LIMIT 1];
        Id proMatReqRtId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Project_Materials_Request').getRecordTypeId();
        List<MTT_Location__c> locList = [SELECT Id, Name, State__c FROM MTT_Location__c LIMIT 1];
        
        Materials__c lmsFreeMaterial = new Materials__c(Name = 'Student LMS Enrollment (Free)',Cost__c = 100);
        insert lmsFreeMaterial;
                
        List<Contact_Assignments__c> cas = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Instructor', 'Student') AND Status__c = 'Active'];
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c,Project_Task_Type__c,AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:cas[0].Project__c LIMIT 1];
        
        Test.startTest();
        
            List<Materials_Request__c> materialReqs = new List<Materials_Request__c> {
                new Materials_Request__c(Name = 'Test Materials Request 1', RecordTypeId = proMatReqRtId, Project_Task__c = projectTaskList[0].Id, Project__c = projectTaskList[0].AcctSeed__Project__c, Request_Status__c = 'Requested by LTS',Vendor_Name__c = accList[0].Id,Vendor_Total__c=100, Materials_Name__c = lmsFreeMaterial.Id, Location__c  = locList[0].Id)
            
            };
            insert materialReqs;
            
            List<Materials_Request__c> matReqs = [SELECT Id, Request_Status__c, Date_Delivered__c FROM Materials_Request__c WHERE Id IN : materialReqs];
            matReqs[0].Request_Status__c = 'Delivered';
            matReqs[0].Date_Delivered__c = Date.Today();
            update matReqs[0];
            
        Test.stopTest();
    }
}