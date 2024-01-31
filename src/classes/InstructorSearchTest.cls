@isTest
public class InstructorSearchTest {
     @testSetup static void setup(){
         Test.StartTest();
            List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
        Test.Stoptest();  
        List<Events__c> evtlist = TestClassUtil.createTestEvent();
        List<Qualification_Bundle_Item__c> roomlist = TestClassUtil.createTestQualificationBundleItem();
        List<Language_Testing__c> language = TestClassUtil.createTestLanguageTesting();
        List<MTT_Location__c> locationRecord = TestClassUtil.createTestLocations();
        List<Skill__c> skills = TestClassUtil.createTestSkill();
        //List<Language__c> langList = TestClassUtil.createTestLanguages();
        
    }
    public static testMethod void testInstructorSearch() {
        Qualification_Bundle__c bundle = [SELECT Id, Name FROM Qualification_Bundle__c LIMIT 1];
        
        List<Events__c> eventList = [SELECT Id, Name, Instructor__c, Schedule__c,Date__c, Start_Time__c, End_Time__c, Status__c FROM Events__c LIMIT 2];
        List<Id> qualificationId = new List<Id>();
        List<Qualification__c> qualificationList = [SELECT Id, Name, Condition__c, Type__c, Value__c From Qualification__c limit 3];
        Qualification__c quali = new Qualification__c(Condition__c = 'LESS THAN OR EQUAL TO',Type__c = 'Experience',Value__c = '10');
        qualificationList.add(quali);
        
        for(Qualification__c qual : qualificationList){
            qualificationId.add(qual.Id);
        }
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> conList = [SELECT Id,Location_GeoCode__Latitude__s, Name FROM Contact LIMIT 4];
       
        Test.startTest();
        InstructorSearchController.getQualificationSettings(bundle.Id,qualificationId);
        InstructorSearchController.getAllQualificationBundle();
        InstructorSearchController.getService();
        InstructorSearchController.getAllLanguages();
        InstructorSearchController.getAllColleges();
        InstructorSearchController.getAllCompanies();
        InstructorSearchController.getDlSRatePicklistValues();
        InstructorSearchController.getCertifiedSkillsValues();
        InstructorSearchController.getTimePicklist();
        InstructorSearchController.getDegreeLevel();
        InstructorSearchController.sanitizeScore('N/A');
        InstructorSearchController.sanitizeScore('0');
        InstructorSearchController.sanitizeScore('4+');
        InstructorSearchController.sanitizeScore('');
        InstructorSearchController.assignInstructor(eventList[0].Schedule__c, eventList[0].Instructor__c);        
        
        List<AcctSeed__Project_Task__c> projList = [SELECT Id, Name, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Client_Contact__c FROM AcctSeed__Project_Task__c LIMIT 1];
        //Assign instructor with project
        InstructorSearchController.assignContactAssignment('', projList[0].AcctSeed__Project__c, projList[0].AcctSeed__Client_Contact__c, true);
        
        Account a = new Account(Name='Test Account Name 1');
            insert a;
        List<Contact> con1 = new List<Contact>{
            new Contact(LastName = 'Testing Contact 1', AccountId = a.Id)
        };
        
        insert con1;
        //Assign instructor with Opportunity
        system.debug('::con1[0].Id::'+con1[0].Id);
        InstructorSearchController.assignContactAssignment('', projList[0].AcctSeed__Project__r.AcctSeed__Opportunity__c, con1[0].Id, true);
        
        InstructorSearchController.assignInstructor(eventList[0].Schedule__c,eventList[0].Instructor__c);
        
        InstructorSearchController.ConflictSearchParameter cs = new InstructorSearchController.ConflictSearchParameter();
        cs.monday = true;
        cs.tuesday = true;
        cs.wednesday = true;
        cs.thursday = true;
        cs.friday = true;
        cs.saturday = true;
        cs.sunday = true;       
        
        cs.startDate = date.today().addDays(-3).format() ;        
        cs.endDate = date.today().addDays(+3).format();
        system.debug('::::cs.startDate::::'+cs.startDate);
        system.debug('::::cs.endDate::::'+cs.endDate);
        cs.startTime = '09:00 AM';
        cs.endTime = '10:00 AM';
        
        InstructorSearchController.ConflictSearchParameter cons = new InstructorSearchController.ConflictSearchParameter();
        cs.monday = false;
        cs.tuesday = false;
        cs.wednesday = false;
        cs.thursday = false;
        cs.friday = false;
        cs.saturday = false;
        cs.sunday = false;       
        
        cs.startDate = date.today().addDays(-3).format() ;        
        cs.endDate = date.today().addDays(+3).format();
        system.debug('::::cs.startDate::::'+cs.startDate);
        system.debug('::::cs.endDate::::'+cs.endDate);
        cs.startTime = '09:00 AM';
        cs.endTime = '10:00 AM';
        
        // Get Location record id
        List<MTT_Location__c> locationRec = [SELECT Id,Name FROM MTT_Location__c LIMIT 2];
        
        List<Language__c> langList = [SELECT Id,Name FROM Language__c LIMIT 1];

        //SearchParameter
        SearchParameter parameter = new SearchParameter();
        parameter.language = langList[0].Name;
        parameter.languageId = langList[0].Id;
        parameter.bundleId = bundle.Id;
        parameter.experience = 2;
        parameter.candidateRating = new String[] {'3'};
        parameter.foreignProficiency = new String[] {'2/2'};
        parameter.englishProficiency = new String[] {'2/2'};
        parameter.service = new String[] {'Language Training'};
        parameter.isVerified = true;
        parameter.degree = new String[] {'Bachelor'};
        parameter.citizenship = true;
        parameter.zip = '65733';
        parameter.locationId = locationRec[0].Id;
        
        eventList[0].Start_Time__c = Null;
        eventList[0].Status__c = 'Scheduled';
        eventList[0].Date__c = date.today();         
        update eventList[0];
        
        
        String qualificationJSONString = JSON.serialize(qualificationList);
        
        List<Qualification_Bundle__c> bundleList = new List<Qualification_Bundle__c>{
            new Qualification_Bundle__c(Name = 'Test'),
            new Qualification_Bundle__c(Name = 'Test1')};
            
        String qualbundleJSONString = JSON.serialize(bundleList);
        InstructorSearchController.getContactIdSet(conList);       
        
        InstructorSearchController.getAllInstructors(false, cs, parameter);
                
        Test.stopTest();
        
        InstructorSearchController.getAllInstructors(true, cs, parameter);              
        InstructorSearchController.hasday(system.today(),cons);
        
        //To increase code coverage for "QualificationUtil"
        
        List<Qualification_Bundle_Item__c> quaBunList = [SELECT Id,Qualification__c,Bundle__c,Score__c,Prefered_Required__c,Qualification__r.Type__c,Qualification__r.Value__c,Qualification__r.Condition__c FROM Qualification_Bundle_Item__c];
        System.Location zipLocation;
        QualificationUtil.findScore(con1[0],parameter,quaBunList,zipLocation);

        
    }
    
    public static testMethod void testInstructorSearch1() {
        
        Test.startTest();
            
            List<Qualification__c> qualificationList = [SELECT Id, Name, Condition__c, Type__c, Value__c From Qualification__c limit 3];
            
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            // Get Location record id
            List<MTT_Location__c> locationRec = [SELECT Id,Name FROM MTT_Location__c LIMIT 2];
            
            InstructorSearchController.ConflictSearchParameter cs = new InstructorSearchController.ConflictSearchParameter();
            cs.monday = true;
            cs.tuesday = true;
            cs.wednesday = true;
            cs.thursday = true;
            cs.friday = true;
            cs.saturday = true;
            cs.sunday = true;       
            
            cs.startDate = date.today().addDays(-3).format() ;        
            cs.endDate = date.today().addDays(+3).format();
            system.debug('::::cs.startDate::::'+cs.startDate);
            system.debug('::::cs.endDate::::'+cs.endDate);
            cs.startTime = '09:00 AM';
            cs.endTime = '10:00 AM';
            
            String qualificationJSONString = JSON.serialize(qualificationList);
        
            List<Qualification_Bundle__c> bundleList = new List<Qualification_Bundle__c>{
                new Qualification_Bundle__c(Name = 'Test'),
                new Qualification_Bundle__c(Name = 'Test1')};
                
            String qualbundleJSONString = JSON.serialize(bundleList);
            
            InstructorSearchController.hasday(system.today(),cs);  
            InstructorSearchController.hasday(system.today().addDays(1),cs);
            InstructorSearchController.hasday(system.today().addDays(2),cs);
            InstructorSearchController.hasday(system.today().addDays(3),cs);
            InstructorSearchController.hasday(system.today().addDays(-1),cs);
            InstructorSearchController.hasday(system.today().addDays(-2),cs);
            InstructorSearchController.getQualificationBundleRecordType();
            InstructorSearchController.getQualificationBundleClassType();
            InstructorSearchController.getLookupRecords('Qualification__c','a','');
            InstructorSearchController.createNewQualificationRecord(qualbundleJSONString,qualificationJSONString);
            InstructorSearchController.getParentInformation('OPPORTUNITY',opp.Id);
            InstructorSearchController.getLocationRecord(locationRec[0].Id);
            InstructorSearchController.getCitizenshipvalues();
            InstructorSearchController.getLatLangFromLocationObj(locationRec[0].Id);
            EventService.getEventByparentIdsAndFilters(new Set<Id>{},'','','');
            
             List<Qualification__c> qualifiList = new List<Qualification__c>{
                new Qualification__c(Condition__c = 'LESS THAN OR EQUAL TO',Type__c = 'Experience',Value__c = '3'),
                new Qualification__c(Condition__c = 'LESS THAN OR EQUAL TO',Type__c = 'Candidate Rating',Value__c = '3')
                
            };
                
            //To inrease code coverage for "QualificationBundleService","QualificationService"
            QualificationBundleService.getQualificationBundles(' WHERE Id != null','');
            QualificationService.qualificationCreation(qualifiList);
        Test.stopTest();
        
    }
    public static testMethod void testInstructorSearch2() {
    
        //To increase code coverage for "QualificationUtil"
        List<Contact> conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];

        Account a = new Account(Name='Test Account Name 1');
            insert a;
        List<Contact> con1 = new List<Contact>{
            new Contact(LastName = 'Testing Contact 1', AccountId = a.Id,Citizenship__c = 'U.S. Citizen',Citizenship_VISA_expiration_date__c = system.today().addMonths(6),Location_GeoCode__Latitude__s=13.0827,Location_GeoCode__Longitude__s =80.2707),
            new Contact(LastName = 'Testing Contact 1', AccountId = a.Id,Citizenship__c = 'Green Card Holder')
        };
        
        insert con1;
        System.Location location;
        
        QualificationUtil.compare('CONTAINS ANY ONE',new List<String>{'Test'},new List<String>{'Test'});
        QualificationUtil.compare('CONTAINS ALL',new List<String>{'Test'},new List<String>{'Test'});
        QualificationUtil.compare('EQUAL TO','Test',new List<String>{'Test'});
        QualificationUtil.compare('GREATER THAN',1000,500);
        QualificationUtil.compare('GREATER THAN OR EQUAL TO',1000,500);
        QualificationUtil.compare('LESS THAN',1000,1500);
        QualificationUtil.compare('LESS THAN OR EQUAL TO',1000,500);
        QualificationUtil.compare('EQUAL TO',1000,1000);
        QualificationUtil.compare('NOT EQUAL TO',1000,500);
        QualificationUtil.compare('EQUAL TO','Test','Test');
        QualificationUtil.compare('NOT EQUAL TO','Test1','Test2');
        QualificationUtil.compareIndex('',new List<String>{'Test'},'Test',new List<String>{'Test'});
        QualificationUtil.isUSCitizen(con1[0]);
        QualificationUtil.isGreencardHolder(con1[1]);
        QualificationUtil.isWithinVisaExpiration(con1[0],2);
        QualificationUtil.isNative('',con1[0],'');
        QualificationUtil.compareEducation('',new List<String>{},'');
        QualificationUtil.getProximites(con1[0],location);
        QualificationUtil.getEducations(conList[0]);
        QualificationUtil.hasVerifiedSkills(conList[0]);
        QualificationUtil.hasVerifiedSkills(conList[0],'Tamil');
        QualificationUtil.getAllLanguages(conList[0]);
        QualificationUtil.getAllServices(conList[0]);
        QualificationUtil.getLanguageServices(conList[0],'Tamil');
        QualificationUtil.getLanguageProficiency(conList[0],'','','Tamil');
        QualificationUtil.findTotalExperience(conList[0]);
        QualificationUtil.sanitizeScore('');
    }
    
    private static testMethod void getLookupRecords_Test1() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        List<Contact_Assignments__c> conassignList = [SELECT Id, Candidate_Name__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff'];
        conassignList[0].Candidate_Name__c = conList[0].Id;
        update conassignList[0];
        Test.startTest();        
        
            User user = new User(alias = 'steffi', email='staffemail@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = conList[0].Id, Staff_Access__c = true, Current_Previlege__c = 'Staff',
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
        Test.stopTest();
        
        System.runAs(user){
            
            SObjectQueryService.getLookupRecords('AcctSeed__Project__c', '', '');
        }
    }
    private static testMethod void getLookupRecords_Test2() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        List<Contact_Assignments__c> conassignList = [SELECT Id, Candidate_Name__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff'];
        conassignList[0].Candidate_Name__c = conList[0].Id;
        update conassignList[0];
        Test.startTest();        
        
            User user = new User(alias = 'steffi', email='staffemail@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = conList[0].Id, Staff_Access__c = true, Current_Previlege__c = 'Staff',
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
        Test.stopTest();
        
        System.runAs(user){
            
            SObjectQueryService.getLookupRecords('Opportunity', '', '');
        }
    }
    private static testMethod void getLookupRecords_Test3() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        List<Contact_Assignments__c> conassignList = [SELECT Id, Candidate_Name__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff'];
        conassignList[0].Candidate_Name__c = conList[0].Id;
        update conassignList[0];
        Test.startTest();        
        
            User user = new User(alias = 'steffi', email='staffemail@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = conList[0].Id, Staff_Access__c = true, Current_Previlege__c = 'Staff',
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
        Test.stopTest();
        
        System.runAs(user){
            
            SObjectQueryService.getLookupRecords('AcctSeed__Project__c', 'test', '');
        }
    }
    private static testMethod void getLookupRecords_Test4() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        List<Contact_Assignments__c> conassignList = [SELECT Id, Candidate_Name__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff'];
        conassignList[0].Candidate_Name__c = conList[0].Id;
        update conassignList[0];
        Test.startTest();        
        
            User user = new User(alias = 'steffi', email='staffemail@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = conList[0].Id, Staff_Access__c = true, Current_Previlege__c = 'Staff',
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
        Test.stopTest();
        
        System.runAs(user){
            
            SObjectQueryService.getLookupRecords('AcctSeed__Project__c', '', 'AcctSeed__Status__c = \'Active\'');
        }
    }
    
    private static testMethod void getLookupRecords_Test5() {
            
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        List<Contact_Assignments__c> conassignList = [SELECT Id, Candidate_Name__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff'];
        conassignList[0].Candidate_Name__c = conList[0].Id;
        update conassignList[0];
        
        Test.startTest();        
        
            SObjectQueryService.getLookupRecords('Contact_Assignments__c', '', 'Status__c = \'Active\'');
            SObjectQueryService.getLookupRecords('Contact_Assignments__c', 'test', 'Status__c = \'Active\'');
        Test.stopTest();
        
    }
    
    private static testMethod void getLookupRecords_Test6() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        List<Contact_Assignments__c> conassignList = [SELECT Id, Candidate_Name__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff'];
        conassignList[0].Candidate_Name__c = conList[0].Id;
        update conassignList[0];
        Test.startTest();        
        
            User user = new User(alias = 'steffi', email='staffemail@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = conList[0].Id, Staff_Access__c = true, Current_Previlege__c = 'Staff',
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
        Test.stopTest();
        
        System.runAs(user){
            
            SObjectQueryService.getLookupRecords('Opportunity', 'test', '');
        }
    }
    
    private static testMethod void getLookupRecords_Test7() {
            
        List<System_Values__c> systemValueList = [SELECT Id FROM System_Values__c LIMIT 1];
        
        Test.startTest();        
            
            if(systemValueList.size() > 0){
                SObjectQueryService.updateSystemValues(JSON.serialize(systemValueList));
            }
        Test.stopTest();
        
    }
}