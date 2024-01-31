//test class for OpportunityBudgetInfoComponent_Ctrl
@isTest
public class OpportunityBudjectInfoController_Test{
    
    @testsetup static void setUp() {    
        List<Schedule__c> scheduleList = TestClassUtil.createTestSchedule();  
        List<Materials_Request__c> matReqList = TestClassUtil.createTestMaterialRequest();
        List<Product2> productList = TestClassUtil.createTestProduct();
        List<Payment_Item__c> paymentList = TestClassUtil.createTestpaymentItems();
        paymentList[0].Product__c = productList[0].Id;
        update paymentList;

    }   
    
    /* testMethod1 is for getMaterialreqName method from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod1() {

        List<RecordType> rtList = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Materials_Request__c'];
        List<OpportunityLineItem> oppLIList1 = [SELECT Id, Name, OpportunityId, Opportunity.recordtypeId, Product2Id 
                                                FROM OpportunityLineItem Limit 3];        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        List<Materials_Request__c> materialReqList = [SELECT Id, Class_Name__c, Project__c, RecordTypeId FROM Materials_Request__c LIMIT 2];
        
        materialReqList[0].RecordTypeId = rtList[0].Id;
        materialReqList[1].RecordTypeId = rtList[1].Id;
        materialReqList[1].Project__c = projTask[0].AcctSeed__Project__c;
        update materialReqList;

        Test.startTest();
            OpportunityBudjectInfoController.getMaterialreqName(Null,'Project_Materials_Request',materialReqList[1].Project__c);
        Test.stopTest();
    }
    
    /* testMethod2 is for getCustomFieldIdmethod from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod2() {
        OpportunityBudjectInfoController.getCustomFieldId();
    }
    
    /* testMethod3 is for getMaterialreqName method from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod3() {
        List<OpportunityLineItem> oppLIList = [SELECT Id, Name, OpportunityId, Opportunity.recordtypeId, Product2Id 
                                               FROM OpportunityLineItem Limit 3];        
        
        OpportunityBudjectInfoController.getWrapperOppBudgetInfo(oppLIList[0].OpportunityId);
    }
    
    /* testMethod4 is for deleteOPLIOrMRmethod from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod4() {
        List<OpportunityLineItem> oppLIList = [SELECT Id, Name, OpportunityId, Opportunity.recordtypeId, Product2Id 
                                               FROM OpportunityLineItem Limit 3];        
        OpportunityBudjectInfoController.deleteOPLIOrMR(oppLIList[2].Id,true);
    }
    
    /* testMethod5 is for productRelatedFundItemmethod from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod5() {
         List<OpportunityLineItem> oppLIList = [SELECT Id, Name, OpportunityId, Opportunity.recordtypeId, Product2Id 
                                                FROM OpportunityLineItem Limit 3];        
         OpportunityBudjectInfoController.productRelatedFundItem(oppLIList[0].Product2Id,oppLIList[0].OpportunityId);
    }
    
    /* testMethod6 is for deleteOPLIOrMRmethod from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod6(){
        List<Materials_Request__c> materialReqList = [SELECT Id, Class_Name__c, Project__c, RecordTypeId FROM Materials_Request__c LIMIT 2];
        List<RecordType> rtList = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Materials_Request__c'];
        materialReqList[0].RecordTypeId = rtList[0].Id;
        update materialReqList;
        
        OpportunityBudjectInfoController.deleteOPLIOrMR(materialReqList[0].Id,false);

    }
    
    /* testMethod7 is for getMaterialreqName method from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod7(){
        List<Materials_Request__c> materialReqList = [SELECT Id, Class_Name__c, Project__c, RecordTypeId FROM Materials_Request__c LIMIT 2];
        List<RecordType> rtList = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Materials_Request__c'];
        materialReqList[0].RecordTypeId = rtList[0].Id;
        update materialReqList;
        
        OpportunityBudjectInfoController.getMaterialreqName(materialReqList[0].Class_Name__c,'Material_Loan_Request',Null); 
    }
    
    /* testMethod8 is for oppRelatedFundItem method from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod8(){
        List<Opportunity> opportunityList = [SELECT Id, Name, StageName, Start_Date__c , End_Date__c , CloseDate , AccountId ,
                                             RecordTypeId, Hours_Week__c, Section__c, Language__c FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oppLIList = [SELECT Id, Name, OpportunityId, Opportunity.recordtypeId, Product2Id 
                                               FROM OpportunityLineItem Limit 3];
        
        OpportunityBudjectInfoController.oppRelatedFundItem(oppLIList[0].Id,opportunityList[0].Id);
    }
    
    /* testMethod9 is for deleteRecordById method from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod9(){
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        OpportunityBudjectInfoController.deleteRecordById(projTask[0].Id);
    }
    
    /* testMethod10 is for proTaskRelatedFundItem method from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod10(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name, AcctSeed__Status__c , RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, 
                                                  Start_Date__c , End_Date__c  FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        OpportunityBudjectInfoController.proTaskRelatedFundItem(projTask[0].Id ,projectList[0].Id);
    }
    
    /* testMethod11 is for getrecordTypeInfomethod from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod11(){
        OpportunityBudjectInfoController.getrecordTypeInfo();
    }
    
    /* testMethod12 is for getWrapperProjectBudgetInfofrom OpportunityBudjectInfoController controller */
    public static testMethod void testMethod12(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name, AcctSeed__Status__c , RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, 
                                                  Start_Date__c , End_Date__c  FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c LIMIT 1];
        String proTaskRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();

        List<Acctseed__Project_Task__c> proTaskList = new List<Acctseed__Project_Task__c> {
            new Acctseed__Project_Task__c(RecordTypeId = proTaskRT, Name = 'Language Training -  Each Additional Student',AcctSeed__Project__c = projectList[0].Id,Total_Qty_Planned__c = 8.00,Project_Task_Type__c = 'Language Training',Unit__c = 'Hrs',Total_Hours__c = 5,AcctSeed__Labor_GL_Account__c = glAccList[0].Id) 
        };
        insert proTaskList;
        Test.startTest();
        List<Materials_Request__c> materialReqList = [SELECT Id, Class_Name__c, Project__c, RecordTypeId FROM Materials_Request__c LIMIT 2];
        materialReqList[0].Project__c = projectList[0].Id;
        update materialReqList;
        
        OpportunityBudjectInfoController.getWrapperProjectBudgetInfo('AcctSeed__Project__c',projectList[0].Id);
        Test.stopTest();
    }
    
     /* testMethod13 is for getWrapperProjectBudgetInfo from OpportunityBudjectInfoController controller */
    public static testMethod void testMethod13(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name, AcctSeed__Status__c , RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, 
                                                  Start_Date__c , End_Date__c  FROM AcctSeed__Project__c LIMIT 1];
       
        List<RecordType> recTypeList = [SELECT Id, Name, RecordType.DeveloperName FROM RecordType WHERE RecordType.DeveloperName = 'Material_Loan_Request'];
        
        List<Materials_Request__c> materialReqList = [SELECT Id, Class_Name__c, Project__c, RecordTypeId FROM Materials_Request__c LIMIT 2];
        materialReqList[1].RecordTypeId = recTypeList[0].Id;
        materialReqList[1].Project__c = projectList[0].Id;
        update materialReqList;
        
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,Parent_Project_Task__c,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        projTask[0].Parent_Project_Task__c = projTask[1].Id;
        update projTask;
        
        OpportunityBudjectInfoController.getWrapperProjectBudgetInfo('AcctSeed__Project__c',projectList[0].Id);
    }
    
     /* testMethod14 is for getWrapperProjectBudgetInfofrom OpportunityBudjectInfoController controller */
    public static testMethod void testMethod14(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name, AcctSeed__Status__c , RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, 
                                                  Start_Date__c , End_Date__c  FROM AcctSeed__Project__c LIMIT 1];
        List<RecordType> recTypeList = [SELECT Id, Name, RecordType.DeveloperName FROM RecordType WHERE RecordType.DeveloperName = 'Material_Loan_Request'];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        projTask[0].Project_Task_Type__c = 'Material Budget';
        update projTask;
        
        OpportunityBudjectInfoController.getWrapperProjectBudgetInfo('AcctSeed__Project__c',projectList[0].Id);
    }
    
    public static testMethod void testMethod15(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name, AcctSeed__Status__c , RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, 
                                                  Start_Date__c , End_Date__c  FROM AcctSeed__Project__c LIMIT 1];
        List<RecordType> recTypeList = [SELECT Id, Name, RecordType.DeveloperName FROM RecordType WHERE RecordType.DeveloperName = 'Material_Loan_Request'];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        projTask[0].Project_Task_Type__c = 'ODC';
        update projTask;
        
        OpportunityBudjectInfoController.getWrapperProjectBudgetInfo('AcctSeed__Project__c',projectList[0].Id);
    }
    
    public static testMethod void testMethod16(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name, AcctSeed__Status__c , RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, 
                                                  Start_Date__c , End_Date__c  FROM AcctSeed__Project__c LIMIT 1];
        List<RecordType> recTypeList = [SELECT Id, Name, RecordType.DeveloperName FROM RecordType WHERE RecordType.DeveloperName = 'Cost'];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        projTask[0].Project_Task_Type__c = 'ADMINISTRATIVE';
        projTask[0].RecordTypeId = recTypeList[0].Id;
        update projTask;
        
        OpportunityBudjectInfoController.getWrapperProjectBudgetInfo('AcctSeed__Project__c',projectList[0].Id);
    }
    
    public static testMethod void testMethod17(){
        List<AcctSeed__Project__c> projectList = [SELECT Id, Name, AcctSeed__Status__c , RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, 
                                                  Start_Date__c , End_Date__c  FROM AcctSeed__Project__c LIMIT 1];
        List<RecordType> recTypeList = [SELECT Id, Name, RecordType.DeveloperName FROM RecordType WHERE RecordType.DeveloperName = 'Cost'];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.RecordTypeId,
                                                    AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, 
                                                    AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        projTask[0].Project_Task_Type__c = 'Location';
        projTask[0].RecordTypeId = recTypeList[0].Id;
        update projTask;
        
        OpportunityBudjectInfoController.getWrapperProjectBudgetInfo('AcctSeed__Project__c',projectList[0].Id);
    }
}