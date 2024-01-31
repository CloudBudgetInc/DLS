@isTest
private class InvokeSubflowFromParentFlow_Test{
        
    @testSetup static void setupMethod(){
        List<AcctSeed__Project__c> projects = TestClassUtil.createTestProject();
    }
    
    private static testMethod void myTest(){
        
        List<AcctSeed__Project__c> projectRec = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        APXT_CongaSign__Transaction__c cst = new APXT_CongaSign__Transaction__c();
        cst.Parent_a48__c = projectRec[0].Id;
        cst.APXT_CongaSign__Status__c = 'DRAFT';
        insert cst;
        
        List<APXT_CongaSign__Transaction__c> cstUpdation = [SELECT Id, APXT_CongaSign__Status__c FROM APXT_CongaSign__Transaction__c WHERE Id =:cst.Id];
        cstUpdation[0].APXT_CongaSign__Status__c ='SENT';
        update cstUpdation;
        
        List<InvokeSubflowFromParentFlow.CallSubflow_Params> subflowParamsList = new List<InvokeSubflowFromParentFlow.CallSubflow_Params>();
        InvokeSubflowFromParentFlow.CallSubflow_Params sub_Flow_Wrap = new InvokeSubflowFromParentFlow.CallSubflow_Params();
        sub_Flow_Wrap.sObjectRecordFromParentFlow = cst;
        sub_Flow_Wrap.subflowAPIName = 'Update_Project_CA_Rec_From_Parent_Flow';
        subflowParamsList.add(sub_Flow_Wrap);
        
        InvokeSubflowFromParentFlow.invokeSubflow(subflowParamsList);
    }
}