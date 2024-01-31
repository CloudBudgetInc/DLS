@isTest
private Class ResumeUploadRchilliClass_Test{
    
    @testsetup static void setup() {
        List<Known_Language__c> langList = TestClassUtil.createTestKnownLanguages();
        List<Experience__c> expList = TestClassUtil.createTestExperience();
        List<Skill__c> skList = TestClassUtil.createTestSkill();
    } 
    
    // For Searching Match Contact
    private static testMethod void testMethod1() {
        
        List<system_Values__c> sysVal = new List<system_Values__c>{ 
            new System_Values__c(Name = 'Rchilli_Userkey', Value__c = 'FI17YQZ25UW'),
            new System_Values__c(Name = 'Rchilli_Version', Value__c = '7.0.0'),
            new System_Values__c(Name = 'Rchilli_subUserId', Value__c = 'dlsdc7'),
            new System_Values__c(Name = 'RchilliEndPoint_URL', Value__c = 'http://dlsdc7.rchilli.com/RChilliParser/Rchilli/parseResumeBinary')
        };
        insert sysVal;
        
        List<Contact> conList = [SELECT Id, Name, EMail FROM Contact LIMIT 2];
        
        if(conList.size() > 0) {
            
            conList[0].EMail = 'karthiga@softsquare.biz';
            update conList;
            
            Map<String,String> tempMap = new Map<String,String>{'Test' => 'Test'};
            ResumeUploadRchilliClass ru = new ResumeUploadRchilliClass();
            List<Object> conRet = ResumeUploadRchilliClass.searchMatchedContact(tempMap);
            
            if(conRet.size() > 0) {
                List<Contact> conListUp = (List<Contact>)conRet;
                System.assertEquals(conListUp[0].Id,conList[0].Id);
            }
        }
    } 
    
    //For parsing of json response
    private static testMethod void testMethod2() {
        
        
        List<Known_Language__c> knownLangList = [SELECT Id, Name, Contact__c FROM Known_Language__c LIMIT 2];
        List<Language__c> langList = [SELECT Id, Name FROM Language__c WHERE Name = 'English'];  
        Map<String,String> tempMap = new Map<String,String>{'Test' => 'Test'};
        
        if(knownLangList.size() > 0 && langList.size() > 0) {
           
            Set<Id> conId = new Set<Id>();
            conId.add(knownLangList[0].Contact__c);
            conId.add(knownLangList[1].Contact__c);
            
            List<Contact> conList = [SELECT Id,Name,AccountId FROM Contact WHERE Id IN :conId];
            
            if(conList.size() > 0) {
                List<Account> accList = [SELECT Id, Name FROM Account WHERE Id != :conList[0].AccountId];
                
                if(accList.size() > 0) {
                    List<system_Values__c> sysVal = new List<system_Values__c>{ 
                        new System_Values__c(Name = 'Rchilli_Contact_AccountId', Value__c = accList[0].Id), //conList[0].AccountId), 
                        new System_Values__c(Name = 'Rchilli_Userkey', Value__c = 'FI17YQZ25UW'),
                        new System_Values__c(Name = 'Rchilli_Version', Value__c = '7.0.0'),
                        new System_Values__c(Name = 'Rchilli_subUserId', Value__c = 'dlsdc7'),
                        new System_Values__c(Name = 'RchilliEndPoint_URL', Value__c = 'http://dlsdc7.rchilli.com/RChilliParser/Rchilli/parseResumeBinary')
                    };
                    insert sysVal;
                    
                    List<Experience__c> expList = [SELECT Id, Name, RecordType.DeveloperName FROM Experience__c WHERE RecordType.DeveloperName IN ('Education_Experience','Professional_Work_Experience')];
                                    
                    if(expList.size() > 0) {
                        for(Experience__c ex : expList) {
                            ex.Contact__c = conList[0].Id;
                            if(ex.RecordType.DeveloperName == 'Education_Experience') {
                                ex.Degree__c = 'Test Degree';
                                ex.College_School__c = 'Test College';
                            } else {
                                ex.Name_of_Company__c = 'Test Company';
                                ex.Role_Title__c = 'Test Role';
                            }
                        }
                        update expList;
                    }
                    
                    List<Skill__c> skList = [SELECT Id, Name FROM Skill__c LIMIT 2];
                    if(skList.size() > 0) {
                        skList[0].Contact__c = conList[0].Id;
                        skList[0].Skill__c = 'Curriculum Development';
                        skList[0].To_Language_LU__c = langList[0].Id;
                        update skList;
                    }
                    
                    ResumeUploadRchilliClass.jsonResume(conList[0].Id,tempMap,'Edit');
                    
                    if(expList.size() > 0) {
                        for(Experience__c ex : expList) {
                            ex.Contact__c = conList[0].Id;
                            if(ex.RecordType.DeveloperName == 'Education_Experience') {
                                ex.Degree__c = 'value from resume';
                                ex.College_School__c = 'value from resume';
                            } else {
                                ex.Name_of_Company__c = 'Test Company 1';
                                ex.Role_Title__c = 'value from resume';
                            }
                        }
                        update expList;
                    }
                    
                    conList[0].Non_US_Passport_Country__c = 'Test US';
                    update conList[0];
                    
                    String resultJson = ResumeUploadRchilliClass.jsonResume(conList[0].Id,tempMap,'Upload');
                    /*Map<String,Object> resRet = (Map<String,Object>) JSON.deserializeUntyped(resultJson);
                    Object skillUp = resRet.get('SkillInfoList');
                    System.assertEquals(1, skillUp.size());*/
                }
            }
        }
    } 
    
    //For Saving new record
    private static testMethod void testMethod3() {
       
        String con = 'NoContact';
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        List<RecordType> expRT = [SELECT Id, Name, RecordType.DeveloperName FROM RecordType WHERE SobjectType = 'Experience__c' AND DeveloperName IN ('Education_Experience', 'Professional_Work_Experience')];
        List<Language__c> langList = [SELECT Id, Name FROM Language__c LIMIT 2];
        List<Skill__c> skList = [SELECT Id, Name FROM Skill__c LIMIT 2];
        
        if(conList.size() > 0 && expRT.size() > 0 && langList.size() > 0 && skList.size() > 0) {
            Id eduRt, workRT;
            for(RecordType rt : expRT) {
                if(rt.DeveloperName == 'Education_Experience') 
                    eduRt = rt.Id;
                else 
                    workRT = rt.Id;
            }
            
            String contInfo = '[{"choice1":"FirstName","conFieldLabel":"First Name","conFieldValue":"Test Contact 2 on Aug 17","optionName":"First Name","resumeFieldValue":"Claudia","SelectedValue":"Test Contact 2 on Aug 17","$$hashKey":"object:29"},'+
                    '{"choice1":"MiddleName","conFieldLabel":"Middle Name","optionName":"Middle Name","resumeFieldValue":"","$$hashKey":"object:30"},{"choice1":"LastName","conFieldLabel":"Last Name","conFieldValue":"Caicedo","optionName":"Last Name",'+
                    '"resumeFieldValue":"Caicedo","SelectedValue":"Caicedo","$$hashKey":"object:31"},{"choice1":"Email",'+
                    '"conFieldLabel":"Email","conFieldValue":"test2178@gmail.com","optionName":"Email","resumeFieldValue":"ClaudiaJCaicedo@comcast.net","SelectedValue":"test2178@gmail.com","$$hashKey":"object:37"},{"choice1":"Phone","conFieldLabel":"Phone","optionName":"Phone",'+
                    '"resumeFieldValue":"","$$hashKey":"object:38"},{"choice1":"Mobile","conFieldLabel":"Mobile","optionName":"Mobile","resumeFieldValue":"","$$hashKey":"object:39"},{"choice1":"Address","conFieldLabel":"Address","conFieldValue":"20050320 4000 Tunlaw Rd NW, Apt. 527",'+
                    '"optionName":"Address","resumeFieldValue":"20050320 4000 Tunlaw Rd NW, Apt. 527","SelectedValue":"20050320 4000 Tunlaw Rd NW, Apt. 527","$$hashKey":"object:40"},{"choice1":"City","conFieldLabel":"City","conFieldValue":"Washington","optionName":"City","resumeFieldValue"'+
                    ':"Washington","SelectedValue":"Washington","$$hashKey":"object:41"},{"choice1":"State","conFieldLabel":"State","conFieldValue":"DC","optionName":"State","resumeFieldValue":"DC","SelectedValue":"DC","$$hashKey":"object:42"},{"choice1":"Country","conFieldLabel":"Country",'+
                    '"optionName":"Country","resumeFieldValue":"","$$hashKey":"object:43"},{"choice1":"ZipCode","conFieldLabel":"ZipCode","optionName":"ZipCode","resumeFieldValue":"","$$hashKey":"object:44"}]';
            
            String Persinfo = '[{"choice1":"DateOfBirth","conFieldLabel":"Date Of Birth","optionName":"Date Of Birth","resumeFieldValue":"","$$hashKey":"object:32"},{"choice1":"Gender"'+
                    ',"conFieldLabel":"Gender","optionName":"Gender","resumeFieldValue":"","$$hashKey":"object:33"},{"choice1":"LicenseNo","conFieldLabel":"License No","optionName":"License No","resumeFieldValue":"","$$hashKey":"object:34"},{"choice1":"PassportNo",'+
                    '"conFieldLabel":"Passport No","optionName":"Passport No","resumeFieldValue":"","$$hashKey":"object:35"},{"choice1":"VisaStatus","conFieldLabel":"Visa Status","optionName":"Visa Status","resumeFieldValue":"","$$hashKey":"object:36"}]';
            
    
            String Qinfo = '[{"exp":{"Name":"Exp-032","College_School__c":"Georgetown University","Degree__c":"Master Of Arts","Contact__c":"'+conList[0].Id+
                '","End_Date__c":"2011-01-01","City__c":"Washington","State__c":"District of Columbia","Country__c":"United States","Non_US_Degree__c":false,"RecordTypeId":"'+eduRt+
                '"},"isNew":false,"isSelected":true,"$$hashKey":"object:61","hasSchoolError":"","hasDegreeError":""}]';

            String Qinfo1 = '[{"exp":{"Name":"Exp-032","College_School__c":"Georgetown University","Degree__c":"Master Of Arts","Contact__c":"'+conList[0].Id+
                '","End_Date__c":"2011-01-01","City__c":"Washington","State__c":"District of Columbia","Country__c":"United States","Non_US_Degree__c":false},'+
                '"isNew":false,"isSelected":true,"$$hashKey":"object:61","hasSchoolError":"","hasDegreeError":""}]';
            
            String today = String.valueOf(System.today());
            
            String ExInfo = '[{"exp":{"Name":"Exp-032","College_School__c":"Georgetown University","Degree__c":"Master Of Arts","Contact__c":"'+conList[0].Id+'","End_Date__c":"'+today+'","City__c":"Washington","State__c":"District of Columbia","Country__c":"United States","Non_US_Degree__c":false,"RecordTypeId":"'+workRT+'"},"isNew":false,"isSelected":true,"$$hashKey":"object:61","hasSchoolError":"","hasDegreeError":""}]';
            String ExInfo1 = '[{"exp":{"Name":"Exp-032","College_School__c":"Georgetown University","Degree__c":"Master Of Arts","Contact__c":"'+conList[0].Id+'","End_Date__c":"2011-01-01","City__c":"Washington","State__c":"District of Columbia","Country__c":"United States","Non_US_Degree__c":false},"isNew":false,"isSelected":true,"$$hashKey":"object:61","hasSchoolError":"","hasDegreeError":""}]';
            
            String lang = '[{"Contact__c":"'+conList[0].Id+'","Language__c":"'+langList[0].Id+'","Language_Name__c":"Apache","Native_Language__c":false,"$$hashKey":"object:146","hasLangError":""}]';
            List<Known_Language__c> knlang = new List<Known_Language__c>();
            
            String skl = '[{"ExperienceName":"MAXIMUS","skl":{"Id":"'+skList[0].Id+'","Skill__c":"Curriculum Development","Status__c":"Not Verified", "From_Language_LU__c":"'+langList[1].Id+'", "From_Language_LU__r":{"Name":"'+ langList[1].Name +'","Id":"'+langList[1].Id+'"}, "To_Language_LU__c":"'+langList[0].Id+'", "To_Language_LU__r":{"Name":"'+ langList[0].Name +'","Id":"'+langList[0].Id+'"}},"$$hashKey":"object:138","hasSkillError":""}]';
            String skl1 = '[{"ExperienceName":"MAXIMUS","skl":{"Id":"'+skList[0].Id+'","Skill__c":"Curriculum Development","Status__c":"Not Verified"}, "$$hashKey":"object:138","hasSkillError":""}]';
            ResumeUploadRchilliClass.ProfPublicationAwardsClass proPubAward = new ResumeUploadRchilliClass.ProfPublicationAwardsClass(new Professional_Publication_and_Award__c(Company_Institution_Name__c='test',Name_of_the_Publication_Award__c='pd2',Year__c='2020',Contact__c=conList[0].Id));
            String conIdRet = ResumeUploadRchilliClass.saveNewRecords(con,contInfo,Persinfo,Qinfo,ExInfo,skl,lang, JSON.serialize(new List<ResumeUploadRchilliClass.ProfPublicationAwardsClass>{proPubAward})); 
            
            String conIdReturn = ResumeUploadRchilliClass.saveNewRecords(conIdRet,contInfo,Persinfo,Qinfo1,ExInfo1,skl1,json.serialize(knlang), JSON.serialize(new List<ResumeUploadRchilliClass.ProfPublicationAwardsClass>{proPubAward}));
            System.assertEquals(conIdReturn, conIdRet);
            
        }
    } 
    
    // For getting Lookup record values for Sobject
    private static testMethod void testMethod4() {
        String objName = 'Account';
        String searchStr = 'Test';
        String cond = '';
        List<Sobject> obj = ResumeUploadRchilliClass.getLookupRecords(objName, searchStr, cond);
        if(obj.size() > 0) {
            List<Account> accUp = [SELECT Id, Name FROM Account WHERE Name LIKE '%Test%'];
            System.assertEquals(accUp.size(), obj.size()); 
        }       
    } 
}