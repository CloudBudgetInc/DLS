@isTest
Global class TestLeadMappingTrigger{

    @testSetup static void setup(){
        List<Language__c> languageList = TestClassUtil.createTestLanguages();  
        
    }
    
    public static testmethod void testLeadUpdate1(){
        List<String> StrList = new List<String>();
        List<Database.LeadConvert> ledUpdate = new List<Database.LeadConvert>();
        List<Language__c> lanList = [Select Id, Name From Language__c Limit 2];     
        List<Lead> leadList = new List<Lead>{new Lead (LastName='Sep 28 evening bulk 1',Type__c='Student',Start_Date__c = system.today(), Status='Suspect - Contact',Company='Softsquare',Language_or_Dialect__c = lanList[0].Id, Source_Language__c = lanList[0].Id, Target_Language__c = lanList[0].Id ),
            new Lead (LastName='Sep 28 evening bulk 2',Type__c='Commercial Client',Start_Date__c = system.today(), Status='Suspect - Contact',Company='Softsquare',Lead_Account_Type__c = 'DLS',Lead_Opportunity_Type__c = 'MTT Opportunities',Language_or_Dialect__c = lanList[1].Id, Source_Language__c = lanList[1].Id, Target_Language__c = lanList[1].Id)
        };        
        Insert leadList;  
        
        leadList[0].Source_Language__c = null;
        leadList[0].Target_Language__c = null;
        leadList[0].Language_or_Dialect__c = null;
        update leadList;
             
        for(Lead ldy : leadList ){
            StrList.add(ldy.Type__c);
        }
        List<RecordType> recordTypeList = [
            SELECT Id,DeveloperName,Name,SobjectType 
            FROM RecordType 
            WHERE DeveloperName=:StrList
        ];                                   
        for(Lead lfd : leadList){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lfd.Id);
            lc.setConvertedStatus('Prospect - Commitment');
            ledUpdate.add(lc);    
        }
        List<Database.LeadConvertResult> lcr = Database.convertLead(ledUpdate);
        System.assertEquals(lcr[0].isSuccess(),TRUE);
        system.debug('*****Updates*****'+ledUpdate);                
    }
    
    public static testmethod void testLeadUpdate2(){
    
        Account ac = new Account();
        ac.Name = 'PVT';
        insert ac;
        
        List<String> StrList = new List<String>();
        List<Database.LeadConvert> ledUpdate = new List<Database.LeadConvert>();
        List<Language__c> lanList = [Select Id, Name From Language__c Limit 2];     
        List<Lead> leadList = new List<Lead>{
            new Lead (LastName='PVT Test Con',Type__c='Student',Start_Date__c = system.today(), Status='Suspect - Contact',Company='PVT - Test Lead Conversion',Lead_Account_Type__c = 'Commercial Clients', Language_or_Dialect__c = lanList[0].Id, Source_Language__c = lanList[0].Id, Target_Language__c = lanList[0].Id )
        };        
        Insert leadList;  
        
        leadList[0].Source_Language__c = null;
        leadList[0].Target_Language__c = null;
        leadList[0].Language_or_Dialect__c = null;
        update leadList;
             
        for(Lead ldy : leadList ){
            StrList.add(ldy.Type__c);
        }
        List<RecordType> recordTypeList = [
            SELECT Id,DeveloperName,Name,SobjectType 
            FROM RecordType 
            WHERE DeveloperName=:StrList
        ];                                   
        for(Lead lfd : leadList){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lfd.Id);
            lc.setConvertedStatus('Prospect - Commitment');
            ledUpdate.add(lc);    
        }
        List<Database.LeadConvertResult> lcr = Database.convertLead(ledUpdate);
        System.assertEquals(lcr[0].isSuccess(),TRUE);
        system.debug('*****Updates*****'+ledUpdate);                
    }
}