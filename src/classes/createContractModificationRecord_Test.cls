@isTest
private class createContractModificationRecord_Test
{
    @testSetup static void setup(){
       List<Opportunity> opplist = TestClassUtil.createTestOpportunities();
    }
  
  static testMethod void testMyWebSvc()
  {
      List<Opportunity> oppList = [SELECT Id,Name,StageName FROM Opportunity WHERE ContractId != null];
      system.debug(':::createContractModificationRecord:'+oppList);  
      if( oppList != null && oppList.size() > 0 )  
          createContractModificationRecord.createContractModRec(oppList[0].Id);
      //Opportunity opp = new Opportunity();
      //createContractModificationRecord.createContractModRec(opp.Id);
  }
}