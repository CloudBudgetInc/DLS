@isTest
private class InstructorSearch_LightningCtrl_Test {
    @testSetup static void setup() { 
        Test.startTest();
            List<Known_Language__c> knownLangList= TestClassUtil.createTestKnownLanguages();
            List<Schedule__c> schList = TestClassUtil.createTestSchedule(); 
        Test.stopTest();
    }
   
    // For getting Contact
    private static testMethod void testMethod1() {
        
        List<Contact> conList = [SELECT Id, Name FROM Contact];
        String JSONConList = InstructorSearch_LightningCtrl.getContacts();
        if(JSONConList != null && JSONConList != '') {
            List<Contact> conListRet = (List<Contact>) JSON.deserialize(JSONConList, List<Contact>.class);
            System.assertEquals(conList.size(), conListRet.size());
        }
    }
    
    //For getting pickList values
    private static testMethod void testMethod2() {
        String JSONWarp = InstructorSearch_LightningCtrl.getFilterRelatedInfo();
        System.assert(JSONWarp.contains('serviceList'));
        
        InstructorSearch_LightningCtrl.getLookupRecords('Test','Contact','Name','',new List<String>{});
        
        List<AcctSeed__Project__c> projects = [SELECT Id,AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        
        InstructorSearch_LightningCtrl.getParentInformation(projects[0].Id,'PROJECT');
        InstructorSearch_LightningCtrl.getParentInformation(projects[0].AcctSeed__Opportunity__c,'OPPORTUNITY');
    } 
    
    //For getting the instructor list based on the filter conditions
    private static testMethod void testMethod3() {
        
        List<Schedule__c> schList = [SELECT Id, Name FROM Schedule__c LIMIT 2];
        InstructorSearchController.ConflictSearchParameter warpClass = new InstructorSearchController.ConflictSearchParameter();
        
        Date stDt = System.today();
        Date enDt = System.today().addDays(10);
        
        warpClass.startDate = dateMethod(stDt.month())+'/'+dateMethod(stDt.Day())+'/'+string.valueOf(stDt.year());
        warpClass.endDate = dateMethod(enDt.month())+'/'+dateMethod(enDt.Day())+'/'+string.valueOf(enDt.year());
        warpClass.startTime = '10.00';
        warpClass.startTime = '23.00';
        warpClass.monday = true;
        warpClass.tuesday = true;
        
        List<Known_Language__c> langList = [SELECT Id, Name, Language__c, Language__r.Name, Contact__c FROM Known_Language__c LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :langList[0].Contact__c];
        List<RecordType> conRt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Candidate' AND SobjectType = 'Contact'];
        
        List<Qualification_Bundle__c> quaBunList = new List<Qualification_Bundle__c> {
            new Qualification_Bundle__c(Name = 'Test Bundle', Record_Type__c = 'SLP')
        };
        insert quaBunList;
        
        List<Qualification_Bundle_item__c> quaBunItemList = new List<Qualification_Bundle_item__c> {
            new Qualification_Bundle_item__c(Name = 'Test Bundle', Bundle__c = quaBunList[0].Id)
        };
        insert quaBunItemList;
        
        if(conList.size() > 0 && conRt.size() > 0 && schList.size() > 0) {
            
            schList[0].Instructor__c = conList[0].Id;
            schList[0].End_Date__c = System.today().addDays(10);
            schList[0].Start_Date__c = System.today();
            update schList;
            
            conList[0].RecordTypeId = conRt[0].Id;
            conList[0].Ineligible_for_Rehire__c = false;
            conList[0].Language_1__c = langList[0].Language__r.Name;
            conList[0].Work_Experience__c = 2;
            conList[0].Country_of_Birth__c = 'Albania';
            conList[0].DLS_Candidate_Rating__c = null;
            update conList;
        } 
        
        SearchParameter searchWrap = new SearchParameter();
                
        if(langList.size() > 0) {
            searchWrap.language = langList[0].Language__r.Name;
            searchWrap.languageIds = new String[]{langList[0].Language__c};
            searchWrap.bundleId = quaBunList[0].Id;
            searchWrap.proximity = 2;
            searchWrap.zip = '1234';
            searchWrap.experience = 2;
            searchWrap.service = new String[]{'Test Service 1', 'Test Service 2'};
            searchWrap.candidateRating = new String[]{'1', '2'};
            searchWrap.foreignProficiency = new String[]{'Native', '1/1', '2/2', '3/3', '4/4', '5/5'};
            searchWrap.englishProficiency = new String[]{'1/1', '2/3', '3/3', '4/4', '5/5'};
            searchWrap.isVerified = true;
            searchWrap.degree = new String[]{'Ph.D', 'M.Phil'};
            searchWrap.citizenship = true;
            searchWrap.citizenshipValues = new String[]{'Indian', 'U.S'};
            searchWrap.countryOfbirth = 'U.S';
            searchWrap.skillRating = new String[]{'1', '2'};
            searchWrap.instructorStatus = new String[]{'Active', 'Ended'};
            searchWrap.availabilityDate = String.valueOf(System.today());
            searchWrap.sortingType = 'Proxy';
            searchWrap.dliQualified = false;
            
            String warpClassJSON = JSON.Serialize(warpClass);
            String searchWrapJSON = JSON.Serialize(searchWrap);
            String ret = InstructorSearch_LightningCtrl.getAllInstructors(true, warpClassJSON, searchWrapJSON);
            if(ret != '')
                System.assert(ret.contains('instructors'));
        }
    }
    
    //For getting the instructor list based on the filter conditions
    private static testMethod void testMethod3a() {
        
        InstructorSearchController.ConflictSearchParameter warpClass = new InstructorSearchController.ConflictSearchParameter();
        
        Date stDt = System.today();
        Date enDt = System.today().addDays(10);
        
        warpClass.startDate = dateMethod(stDt.month())+'/'+dateMethod(stDt.Day())+'/'+string.valueOf(stDt.year());
        warpClass.endDate = dateMethod(enDt.month())+'/'+dateMethod(enDt.Day())+'/'+string.valueOf(enDt.year());
        warpClass.startTime = '10.00';
        warpClass.startTime = '23.00';
        warpClass.monday = true;
        warpClass.tuesday = true;
        
        List<Known_Language__c> langList = [SELECT Id, Name, Language__c, Language__r.Name, Contact__c FROM Known_Language__c LIMIT 2];
        String locRt, conRt;
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName IN ('Client_Site', 'Candidate') AND SobjectType IN ('MTT_Location__c', 'Contact')]) {
            if(rt.DeveloperName == 'Candidate')
                conRt = rt.Id;
            else 
                locRt = rt.Id;
        }
        
        List<MTT_Location__c> locList = new List<MTT_Location__c> {
            new MTT_Location__c(Name = 'Test Location 1', RecordTypeID = locRt)
        };
        insert locList;
       
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :langList[0].Contact__c];
        
        if(conList.size() > 0) {
            
            List<Bookmark__c> bmList = new List<Bookmark__c> {
                new Bookmark__c(Contact__c = conList[0].Id, User__c = userinfo.getuserid())
            };
            insert bmList;
        } 
       
        SearchParameter searchWrap = new SearchParameter();
                
        if(langList.size() > 0) {
            searchWrap.language = langList[0].Language__r.Name;
            searchWrap.languageIds = new String[]{langList[0].Language__c};
            searchWrap.proximity = 2;
            searchWrap.foreignProficiency = new String[]{'Native'};
            searchWrap.englishProficiency = new String[]{'1/1', '2/3', '3/3', '4/4', '5/5'};
            searchWrap.bookmarkedUserId = userinfo.getuserid();
        }
        
        searchWrap.dliQualified = false;
        
        String warpClassJSON = JSON.Serialize(warpClass);
        String searchWrapJSON = JSON.Serialize(searchWrap);
        String ret = InstructorSearch_LightningCtrl.getAllInstructors(false, warpClassJSON, searchWrapJSON);
        if(ret != '')
            System.assert(ret.contains('instructors'));
    } 
    
    //For getting the instructor list based on the filter conditions
    private static testMethod void testMethod3b() {
        
        InstructorSearchController.ConflictSearchParameter warpClass = new InstructorSearchController.ConflictSearchParameter();
        
        Date stDt = System.today();
        Date enDt = System.today().addDays(10);
        
        warpClass.startDate = dateMethod(stDt.month())+'/'+dateMethod(stDt.Day())+'/'+string.valueOf(stDt.year());
        warpClass.endDate = dateMethod(enDt.month())+'/'+dateMethod(enDt.Day())+'/'+string.valueOf(enDt.year());
        warpClass.startTime = '10.00';
        warpClass.startTime = '23.00';
        warpClass.monday = true;
        warpClass.tuesday = true;
        
        List<Known_Language__c> langList = [SELECT Id, Name, Language__c, Language__r.Name, Contact__c FROM Known_Language__c LIMIT 2];
        List<RecordType> expRt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Experience__c'];
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :langList[0].Contact__c];
        
        if(langList.size() > 0 && conList.size() > 0) {
            
            List<Skill__c> skillList = new List<Skill__c> {
                new Skill__c(Contact__c = conList[0].Id, From_Language_LU__c = langList[0].Language__r.Id, From_Language__c = langList[0].Language__r.Name, To_Language__c = 'Russian')        
            };  
            insert skillList;
            
            List<Experience__c> expList = new List<Experience__c>{
                new Experience__c(RecordTypeId = expRt[0].Id,Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(-10),Contact__c = conList[0].Id,Degree_Level__c = 'B.A.')
            };
            Insert expList;
        
            langList[0].Native_Language__c = true;
            update langList;
        }
        
        SearchParameter searchWrap = new SearchParameter();
                
        if(langList.size() > 0) {
            searchWrap.language = langList[0].Language__r.Name;
            searchWrap.languageIds = new String[]{langList[0].Language__c};
            //searchWrap.locationId = locList[0].Id;
            searchWrap.proximity = 2;
            searchWrap.foreignProficiency = new String[]{'Native'};
            searchWrap.searchByName = 'Test';
            searchWrap.sortingType = 'Experience';
            searchWrap.degree = new String[]{'B.A.', 'M.Phil'};
            
        }
       
        searchWrap.dliQualified = false;
        
        String warpClassJSON = JSON.Serialize(warpClass);
        String searchWrapJSON = JSON.Serialize(searchWrap);
        String ret = InstructorSearch_LightningCtrl.getAllInstructors(false, warpClassJSON, searchWrapJSON);
        if(ret != '')
            System.assert(ret.contains('instructors'));
    } 

    //For getting the instructor list based on the filter conditions
    private static testMethod void testMethod3c() {
        
        InstructorSearchController.ConflictSearchParameter warpClass = new InstructorSearchController.ConflictSearchParameter();
        
        Date stDt = System.today();
        Date enDt = System.today().addDays(10);
        
        warpClass.startDate = dateMethod(stDt.month())+'/'+dateMethod(stDt.Day())+'/'+string.valueOf(stDt.year());
        warpClass.endDate = dateMethod(enDt.month())+'/'+dateMethod(enDt.Day())+'/'+string.valueOf(enDt.year());
        warpClass.startTime = '10.00';
        warpClass.startTime = '23.00';
        warpClass.monday = true;
        warpClass.tuesday = true;
        
        List<Known_Language__c> langList = [SELECT Id, Name, Language__c, Language__r.Name, Contact__c FROM Known_Language__c LIMIT 2];
        String conRt, expRt;
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact', 'Experience__c') AND DeveloperName IN ('Candidate', 'Education_Experience')]) {
            if(rt.DeveloperName == 'Candidate')
                conRt = rt.Id;
            else 
                expRt = rt.Id;
        }
                
        List<Qualification_Bundle__c> quaBunList = new List<Qualification_Bundle__c> {
            new Qualification_Bundle__c(Name = 'Test Bundle', Record_Type__c = 'SLP')
        };
        insert quaBunList;
         
        List<Qualification__c> quaList = new List<Qualification__c> {
            new Qualification__c(Name = 'Test Qua 1', Type__c = 'DLS Candidate Rating', Value__c = '2', Condition__c = 'GREATER THAN OR EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 2', Type__c = 'Mths of Experience', Value__c = '1', Condition__c = 'GREATER THAN'),
            new Qualification__c(Name = 'Test Qua 3', Type__c = 'Mths of Experience', Value__c = '3', Condition__c = 'LESS THAN'),
            new Qualification__c(Name = 'Test Qua 4', Type__c = 'Mths of Experience', Value__c = '2', Condition__c = 'LESS THAN OR EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 5', Type__c = 'Mths of Experience', Value__c = '2', Condition__c = 'EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 6', Type__c = 'Mths of Experience', Value__c = '5', Condition__c = 'NOT EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 7', Type__c = 'Mths of Experience', Value__c = '4', Condition__c = 'CONTAINS ANY ONE'),
            new Qualification__c(Name = 'Test Qua 8', Type__c = 'Language', Value__c = 'Russian', Condition__c = 'EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 9', Type__c = 'Language', Value__c = '1', Condition__c = 'EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 10', Type__c = 'Service', Value__c = 'Russian;Interpretation', Condition__c = 'CONTAINS ANY ONE'),
            new Qualification__c(Name = 'Test Qua 11', Type__c = 'Service', Value__c = 'Interpretation', Condition__c = 'CONTAINS ALL'),
            new Qualification__c(Name = 'Test Qua 12', Type__c = 'Service', Value__c = 'Russian', Condition__c = 'CONTAINS ALL'),
            new Qualification__c(Name = 'Test Qua 13', Type__c = 'Service', Value__c = 'Russian', Condition__c = 'NOT EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 14', Type__c = 'Foreign Language Proficiency', Value__c = 'Native', Condition__c = 'EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 15', Type__c = 'Foreign Language Proficiency', Value__c = '1/1', Condition__c = 'NOT EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 16', Type__c = 'English Language Proficiency', Value__c = null, Condition__c = 'NOT EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 17', Type__c = 'English Language Proficiency', Value__c = '2/2', Condition__c = 'NOT EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 18', Type__c = 'Has Certified Skills', Value__c = 'true', Condition__c = 'NOT EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 19', Type__c = 'Degree', Value__c = 'Master', Condition__c = 'NOT EQUAL TO'),
            new Qualification__c(Name = 'Test Qua 20', Type__c = 'Degree', Value__c = 'Test', Condition__c = 'NOT EQUAL TO')  
            //new Qualification__c(Name = 'Test Qua 21', Type__c = 'Citizenship / Work Status', Value__c = 'Test', Condition__c = 'NOT EQUAL TO')
            //new Qualification__c(Name = 'Test Qua 22', Type__c = 'Proximity', Value__c = 'Test', Condition__c = 'NOT EQUAL TO')
        };
        insert quaList;
        
        List<Qualification_Bundle_item__c> quaBunItemList = new List<Qualification_Bundle_item__c> {
            new Qualification_Bundle_item__c(Name = 'Test Bundle 1', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[0].Id, Score__c = 2),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 2', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[1].Id), 
            new Qualification_Bundle_item__c(Name = 'Test Bundle 3', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[2].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 4', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[3].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 5', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[4].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 6', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[5].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 7', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[6].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 8', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[7].Id), //, Score__c = 2
            new Qualification_Bundle_item__c(Name = 'Test Bundle 9', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[8].Id), //, Score__c = 2
            new Qualification_Bundle_item__c(Name = 'Test Bundle 10', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[9].Id), //, Score__c = 2
            new Qualification_Bundle_item__c(Name = 'Test Bundle 11', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[10].Id), //, Score__c = 2
            new Qualification_Bundle_item__c(Name = 'Test Bundle 12', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[11].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 13', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[12].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 14', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[13].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 15', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[14].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 16', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[15].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 17', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[16].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 18', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[17].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 19', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[18].Id),
            new Qualification_Bundle_item__c(Name = 'Test Bundle 20', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[19].Id)
            //new Qualification_Bundle_item__c(Name = 'Test Bundle 21', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[20].Id) //, Score__c = 2
            //new Qualification_Bundle_item__c(Name = 'Test Bundle 22', Bundle__c = quaBunList[0].Id, Qualification__c = quaList[0].Id, Score__c = 2)
        };
        insert quaBunItemList;
        
        List<Contact> conList = [SELECT Id, Name, English_Proficiency__c FROM Contact WHERE Id = :langList[0].Contact__c];
        
        if(langList.size() > 0 && conList.size() > 0 && conRt != null && conRt != '' && expRt != null && expRt != '') {
            
            List<Language_Testing__c> langTestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang', Testee__c = conList[0].Id,S_Goal__c='0',L_Goal__c='0',R_Goal__c='0',W_Goal__c='0',Target_Language__c='Tamil')
            };
            insert langTestList;
                
            List<Skill__c> skillList = new List<Skill__c> {
                new Skill__c(Contact__c = conList[0].Id, From_Language_LU__c = langList[0].Language__r.Id, From_Language__c = langList[0].Language__r.Name, To_Language__c = 'Russian', Skill__c = 'Interpretation', Skill_Verification__c = 'Verified')        
            };  
            insert skillList;
            
            List<Experience__c> expList = new List<Experience__c>{
                new Experience__c(RecordTypeId = expRt,Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(-10),Contact__c = conList[0].Id,Degree_Level__c = 'B.A.')
            };
            Insert expList;
            
            langList[0].Listening_Proficiency__c = '4/4';
            langList[0].Speaking_Proficiency__c = '3/3';
            langList[0].Native_Language__c = true;
            update langList;
            
            conList[0].RecordTypeId = conRt;
            conList[0].Ineligible_for_Rehire__c = false;
            conList[0].Language_1__c = langList[0].Language__r.Name;
            conList[0].Work_Experience__c = 2;
            conList[0].Country_of_Birth__c = 'Albania';
            conList[0].DLS_Candidate_Rating__c = '4';
            conList[0].English_Proficiency__c = '3;3';
            conList[0].Citizenship__c = 'U.S. Citizen';
            conList[0].Location_GeoCode__latitude__s = 38.541556;
            conList[0].Location_GeoCode__longitude__s = -83.6942;
            update conList;
                        
            SearchParameter searchWrap = new SearchParameter();
            searchWrap.language = langList[0].Language__r.Name;
            searchWrap.languageIds = new String[]{langList[0].Language__c};
            searchWrap.foreignProficiency = new String[]{'Native', '1/1', '2/2', '3/3', '4/4', '5/5'};
            searchWrap.bundleId = quaBunList[0].Id;
            searchWrap.experience = 2;
            searchWrap.sortingType = 'Score';
            searchWrap.zip = '1234';
            searchWrap.citizenship = true;
            searchWrap.candidateRating = new String[]{'1', '2', '3', '4'};
            //searchWrap.proximity = 2;
            searchWrap.dliQualified = true;
            
            String warpClassJSON = JSON.Serialize(warpClass);
            String searchWrapJSON = JSON.Serialize(searchWrap);
            String ret = InstructorSearch_LightningCtrl.getAllInstructors(false, warpClassJSON, searchWrapJSON);
            if(ret != '')
                System.assert(ret.contains(conList[0].Name));
        }
    } 
    
    //For getting Contact related Book Mark record
    private static testMethod void testMethod4() {
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(conList.size() > 0) {
            List<Bookmark__c> bmList = new List<Bookmark__c> {
                new Bookmark__c(Contact__c = conList[0].Id, Referral_Source__c = true, To_Hire__c = true, User__c = userinfo.getuserid()),
                new Bookmark__c(Contact__c = conList[0].Id, Referral_Source__c = false, To_Hire__c = false, User__c = userinfo.getuserid())
            };
            insert bmList;
            
            String bmJSON = InstructorSearch_LightningCtrl.getBookmarkDetails(conList[0].Id,userinfo.getuserid());
            if(bmJSON != '' && bmJSON != null) {
                List<Bookmark__c> bmListRet = (List<Bookmark__c>) JSON.deserialize(bmJSON, List<Bookmark__c>.class);
                System.assertEquals(2, bmListRet.size());
            }
        }
    } 
    
    // For getting schedule, skill, experience and language testing records based on contact
    private static testMethod void testMethod5() {
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        List<Schedule__c> schList = [SELECT Id, Name FROM Schedule__c LIMIT 2];
        
        if(conList.size() > 0 && schList.size() > 0) {
            schList[0].Instructor__c = conList[0].Id;
            update schList;
            
            String wrpCls = InstructorSearch_LightningCtrl.getContactChildRecords(conList[0].Id);
            if(wrpcls != null && wrpCls != '')
                System.assert(wrpcls.contains(schList[0].Id));
        }
    }
    
    private static string dateMethod(Integer dtMo) {
        String moDt;
        if(dtMo > 10) {
            modt = '0'+dtMo;
        } else {
            moDt = String.valueOf(dtMo);
        }
        return moDt;
    } 
}