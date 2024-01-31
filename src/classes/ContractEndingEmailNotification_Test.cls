@isTest
private class ContractEndingEmailNotification_Test{

    @testSetup static void setupMethod(){
    
        List<Contract> contracts = TestClassUtil.createTestContracts();
    }
    
    private static testMethod void myTest(){
    
        List<Contract> contracts = [SELECT Id, Name, ContractNumber,EndDate  FROM Contract];
        contracts[0].EndDate = Date.Today();
        contracts[0].Name = 'Test Contract';
        contracts[1].EndDate = Date.Today();
        update contracts;
        
        Test.startTest();
        
            try{
                 // Schedule coverage
                String CRON_EXP = '0 0 14 * * ?';
                ContractEndingEmailNotification sch = new ContractEndingEmailNotification();
                system.schedule('Contract Ending Email Notification', CRON_EXP, sch);
                
            }Catch(Exception e){
                system.debug('Exception:'+e+e.getLineNumber());
            }
            
        Test.stopTest();
    }
}