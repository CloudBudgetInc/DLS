@isTest
public class GenSendDocusign_Test {
    
    @testsetup static void setup() {
        List<AcctSeed__Cost_Rates__c> costRate = TestClassUtil.createTestCostRates();
        Test.StartTest();
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment(); 
        Test.StopTest();
    }
    
    public static testMethod void testMethod1() {
       
        List<AcctSeed__Cost_Rates__c> crList = new List<AcctSeed__Cost_Rates__c>();

        AcctSeed__Cost_Rates__c cr = [SELECT Id,Name, Contact__c, Contact__r.Supervisor_Name__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != 'DLI-21 SCA MTT' LIMIT 1];
        
        for(AcctSeed__Cost_Rates__c costRate : [SELECT Id, Name, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Id != :cr.Id LIMIT 1]) {
            costRate.Contact__c = cr.Contact__c;
            crList.add(costRate);
        }
        update crList;
     
        String rUrl = GenSendDocusign.returnsTheUrl(cr.Id, 'APXTConga4 Name 1','','','','','');
        if(cr != null && cr.Contact__r.Supervisor_Name__c == null) {
            String retUrl = GenSendDocusign.returnsUrlToGenForm(cr.Id, 'Pay Rate Addendum','','');
            System.assert(rUrl.contains('Please fill the Contact\'s Supervisor Name'));
        }
        
        List<User> usrList = [SELECT Id,Name FROM User WHERE Email='test@gmail.com'];
        if(usrList.size() > 0){
            List<Contact> conLst = [SELECT Id,Supervisor_Name__c FROM Contact WHERE Id = :cr.Contact__c];
            conLst[0].Supervisor_Name__c = usrList[0].Id;
            conLst[0].DLS_User__c = usrList[0].Id;
            update conLst;
        }
        
        AcctSeed__Cost_Rates__c crLst = [SELECT Id,Name, Contact__c, Contact__r.Supervisor_Name__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != 'DLI-21 SCA MTT' LIMIT 1];

        if(crLst != null && crLst.Contact__r.Supervisor_Name__c != null) {
            // Checks whether the proper URL is Return
            AcctSeed__Cost_Rates__c cosrate = [SELECT Id,Name, Contact__c, Contact__r.Supervisor_Name__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != 'DLI-21 SCA MTT' LIMIT 1];
            List<User> signer1List = [SELECT Id,Name FROM User WHERE isPortalEnabled = false];
            String signer1 = '';
            
            if(signer1List.size() > 0){
                signer1 = signer1List[0].Id;
            }
            
            String reUrl = GenSendDocusign.returnsTheUrl(cosrate.Id, 'Offer Letter - Instructors LT','','',usrList[0].Id,usrList[0].Id,'');
    
            AcctSeed__Cost_Rates__c coRa = [SELECT Id,Name,Contact__c,Contact__r.Supervisor_Name__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != Null LIMIT 1];
            coRa.Rate_Type__c = 'DLI-21 SCA LT';
            coRa.Gen_Email_Doc_Conga_Workflow_Template__c = 'Test';
            update coRa;
            
            List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
                new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Contact Assignment Query - Pay Rate Addendum')};
            insert congaQuery;
            
            List<Contact_Assignments__c> conAss = [SELECT Id FROM Contact_Assignments__c LIMIT 1];
            
            String cAId;
            if(conAss.size() > 0){
                cAId = conAss[0].Id;
                conAss[0].Drafted_Labor_Cost_rate__c = coRa.Id;
                update conAss;
            }
            
            String returnUrl = GenSendDocusign.returnsTheUrl(coRa.Id, 'Offer Letter - Instructors LT','','','','','');
            
            // Checks whether the proper URL is Return
            //System.assert(returnUrl.contains('DocuSignR1ID='+coRa.Contact__r.Supervisor_Name__c), returnUrl);
            
            String retUrl = GenSendDocusign.returnsUrlToGenForm(coRa.Id, 'Pay Rate Addendum',cAId,null);
            
            // Checks whether the proper URL is Return
            System.assertEquals(true,retUrl.contains(',[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAId));
            Test.startTest();
            GenSendDocusign.returnsTheUrl(crLst.Id, 'Pay Rate Addendum',cAId,signer1,null,null,null);
            
            crLst.Gen_Email_Doc_Conga_Workflow_Template__c = 'Test';
            update crLst;
            
            GenSendDocusign.returnsTheUrl(cr.Id, 'Change of Status Form',cAId,signer1,usrList[0].Id,usrList[0].Id,null);
            
            coRa.Gen_Email_Doc_Conga_Workflow_Template__c = '';
            update coRa;
            
            GenSendDocusign.returnsTheUrl(coRa.Id, 'Pay Rate Addendum',cAId,signer1,null,null,null);
            List<User> userList = [SELECT Id,Name FROM User LIMIT 1];
            if(userList.size() > 0){
                List<Contact> conList = [SELECT Id,Supervisor_Name__c FROM Contact WHERE Id = :coRa.Contact__c];
                conList[0].Supervisor_Name__c = usrList[0].Id;
                update conList;
            }
            GenSendDocusign.returnsUrlToGenForm(coRa.Id, 'Pay Rate Modification','','');
            Test.stopTest();
        }
        
    }
    
    public static testMethod void testMethod2() {
        
        List<APXTConga4__Conga_Template__c> conTemp = new List<APXTConga4__Conga_Template__c> {
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'APXTConga4 Name 1'),
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'APXTConga4 Name 2')
                                                      };
        insert conTemp;
        
        Contact_Assignments__c conAss = [SELECT Id, Name, Candidate_Name__c FROM Contact_Assignments__c LIMIT 1];
        String retStr = GenSendDocusign.returnsUrlToSendDocusign(conAss.Id);
        
        // Contact Assignment Rate_Card_Rate__c or Drafted_Labor_Cost_Rate__c is equal to null
        System.assert(retStr.contains('Rate Card rate for this Instructor'),retStr);
        
        AcctSeed__Cost_Rates__c cr = [SELECT Id,Name, Contact__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' AND Contact__c != Null LIMIT 1];
        conAss.Rate_Card_Rate__c = cr.Id;
        conAss.Candidate_Name__c = cr.Contact__c;
        update conAss;
        
        String returnStr = GenSendDocusign.returnsUrlToSendDocusign(conAss.Id);
        
        // Contact Assignment Rate_Card_Rate__c or Drafted_Labor_Cost_Rate__c is not equal to null
        System.assert(returnStr.contains('DocuSignR1ID='+conAss.Candidate_Name__c),returnStr);
        GenSendDocusign.returnsUrlToSendDocusign(null);
    } 
    
    public static testMethod void testMethod3() {
        
        List<AcctSeed__Cost_Rates__c> crList = new List<AcctSeed__Cost_Rates__c>();
        
        AcctSeed__Cost_Rates__c cr = [SELECT Id,Name, Contact__c, Contact__r.Supervisor_Name__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != 'DLI-21 SCA MTT' LIMIT 1];
        
        for(AcctSeed__Cost_Rates__c costRate : [SELECT Id, Name, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Id != :cr.Id LIMIT 1]) {
            costRate.Contact__c = cr.Contact__c;
            crList.add(costRate);
        }
        update crList;
        
        String rUrl = GenSendDocusign.returnsTheUrl(cr.Id, 'APXTConga4 Name 1','','','','',null);
        if(cr != null && cr.Contact__r.Supervisor_Name__c == null) {
            String retUrl = GenSendDocusign.returnsUrlToGenForm(cr.Id, 'Pay Rate Addendum','','');
            System.assert(rUrl.contains('Please fill the Contact\'s Supervisor Name'));
        }
        
        AcctSeed__Cost_Rates__c crLst = [SELECT Id,Name, Contact__c, Contact__r.Supervisor_Name__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != 'DLI-21 SCA MTT' LIMIT 1];
        
        if(crLst != null && crLst.Contact__r.Supervisor_Name__c != null) {
            // Checks whether the proper URL is Return
            AcctSeed__Cost_Rates__c cosrate = [SELECT Id,Name, Contact__c, Contact__r.Supervisor_Name__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != 'DLI-21 SCA MTT' LIMIT 1];
            List<User> signer1List = [SELECT Id,Name FROM User WHERE isPortalEnabled = false];
            String signer1 = '';
            
            if(signer1List.size() > 0){
                signer1 = signer1List[0].Id;
            }
            
            GenSendDocusign.returnsTheUrl(cr.Id, 'Change of Status Form','',signer1,'','','');
        }
        
    }
    
    public static testMethod void testMethod5() {
        
        List<AcctSeed__Cost_Rates__c> crList = new List<AcctSeed__Cost_Rates__c>();
        List<Contact_Assignments__c> conAss = [SELECT Id,Project__c,Status__c FROM Contact_Assignments__c WHERE Project__c != null AND Status__c IN ('Active','Planned') AND RecordType.DeveloperName = 'Instructor' LIMIT 1 ];
                                
        for(AcctSeed__Cost_Rates__c costRate : [SELECT Id, Name, Contact__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1]) {
            costRate.Rate_Type__c = 'FSI';
            costRate.Status__c = 'Approved';
            crList.add(costRate);
        }
        update crList;
        
        if(conAss.size() > 0 && crList.size() > 0){
            Test.startTest();
                conAss[0].Rate_Card_Rate__c = crList[0].Id;
                conAss[0].Candidate_Name__c = crList[0].Contact__c;
                update conAss;
                GenSendDocusign.returnsTheUrl(crList[0].Id, 'FSI Offer Letter','','','','',conAss[0].Project__c);
            Test.stopTest();
        }
    }
    
    public static testMethod void testMethod6() {
        
        List<AcctSeed__Cost_Rates__c> crList = new List<AcctSeed__Cost_Rates__c>();
        List<Contact_Assignments__c> conAss = [SELECT Id,Project__c,Status__c FROM Contact_Assignments__c WHERE Project__c != null AND Status__c IN ('Active','Planned') AND RecordType.DeveloperName = 'Instructor' LIMIT 1 ];
        
        for(AcctSeed__Cost_Rates__c costRate : [SELECT Id, Name, Contact__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1]) {
            costRate.Rate_Type__c = 'FSI';
            costRate.Status__c = 'Approved';
            crList.add(costRate);
        }
        update crList;
        
        if(conAss.size() > 0 && crList.size() > 0){
            Test.startTest();
            conAss[0].Rate_Card_Rate__c = crList[0].Id;
            conAss[0].Candidate_Name__c = crList[0].Contact__c;
            update conAss;
            GenSendDocusign.returnsTheUrl(crList[0].Id, 'FSI Letter of Intent','','','','',conAss[0].Project__c);
            Test.stopTest();
        }
    }
}