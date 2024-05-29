@isTest
Public class TestClassUtil {
    
    public Static Set<String> createdObjNameSet = new Set<String>();
    public Static Map<String, Map<String, Id>> rtMap = new Map<String, Map<String, Id>>();
    public Static List<Contact> staticContactList = new List<Contact>();
    public Static List<Account> accountStaticList = new List<Account>();
    public Static List<Opportunity> oppStaticList = new List<Opportunity>();
    public Static List<AcctSeed__Project__c> projectStaticList = new List<AcctSeed__Project__c>();
    public Static List<Contact_Assignments__c> contactAssignStaticList = new List<Contact_Assignments__c>();
    public Static Form_Template__c formTempStatic = new Form_Template__c();
    public Static Map<String, Goal__c> goalMapStatic = new Map<String, Goal__c>();
    public Static List<Task> staticTaskList = new List<Task>();
    public Static List<Event> staticEventList = new List<Event>();
    
    public static testMethod Map<String, Map<String, Id>> queryRecordTypes() {
        
        List<RecordType> rtList = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType];
        for(RecordType rt : rtList) {
            if(!rtMap.containsKey(rt.SObjectType)) {
                rtMap.put(rt.SObjectType, new Map<String, Id>{rt.DeveloperName => rt.Id});
            } else {
                if(!rtMap.get(rt.SObjectType).containsKey(rt.DeveloperName)) {
                    rtMap.get(rt.SObjectType).put(rt.DeveloperName, rt.Id);
                }
            }
        }
        return rtMap;
    }
    
    public static testMethod List<Job_Posting__c> createTestJobPosting() {
    
        List<Job_Posting__c> jobpostingList = new List<Job_Posting__c>();
        jobpostingList.add(new Job_Posting__c(city__c = 'asd', Job_Post_Expiration_Date__c = system.today()));
    
        if(jobpostingList != null && jobpostingList.size() > 0) {
        
            insert jobpostingList;
        } 
        return jobpostingList;
    }
    public static testMethod List<Job_Application__c> createTestJobApplication() {
        
        List<Job_Posting__c> jobpostingList = new List<Job_Posting__c>();
        List<Contact> conlist = new List<Contact>();
        
        if(!createdObjNameSet.Contains('JobPosting')){
            jobpostingList = createTestJobPosting();
            createdObjNameSet.add('JobPosting');
        }else{
            jobpostingList = [SELECT Id, city__c, Job_Post_Expiration_Date__c FROM Job_Posting__c LIMIT 1];
        }
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        }        
        List<Job_Application__c> jobpostingAppList = new List<Job_Application__c>();
        
        if(jobpostingList != null && jobpostingList.size() > 0){
            jobpostingAppList.add(new Job_Application__c(Applicant__c = conlist[0].Id, Job_Posting__c = jobpostingList[0].Id,Status__c = 'Applied'));
            
        }
        if(jobpostingAppList != null && jobpostingAppList.size() > 0)
        insert jobpostingAppList;
            
        return jobpostingAppList;
    }
    public static testMethod List<User> createTestUsers() {
        List<Contact> conList = new List<Contact>();
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            //conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
            conList = staticContactList;
        }
         
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        Id stdProfileId, DLSProfileId;
        
        List<Profile> profileUser = [SELECT Id, Name FROM Profile WHERE Name IN ('DLS Instructor', 'System Administrator')];
        
        if(profileUser != Null && profileUser.size() > 0) {
            for(Profile pro : profileUser) {
                if(pro.Name == 'DLS Instructor') {
                    DLSProfileId = pro.Id;
                } else {
                    stdProfileId = pro.Id;
                }
            }
        }
        
        List<User> userList = new List<User>{        
            new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8', LastName='Testing', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = stdProfileId, contact=conList[0], 
            TimeZoneSidKey='America/Los_Angeles', UserName=un,Instructor_Access__c = true,  
            Student_Access__c = true, Partner_Access__c = true, Client_Access__c = true)
        };
        
        if(DLSProfileId != null && conList != null && conList.size() > 0){
            userList.add(new User(Alias = 'harry', Email='harry_potter@gmail.com',EmailEncodingKey='UTF-8', 
            LastName='harry potter', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = DLSProfileId, 
            contactId=conList[0].Id,contact=conList[0], TimeZoneSidKey='America/Los_Angeles', UserName=en,
            Instructor_Access__c = true, Student_Access__c = true, Partner_Access__c = true, Client_Access__c = true,Staff_Access__c = true));
        }
        
        insert userList;
        return userList;
    }
    public static testMethod List<ContentVersion> createTestContents() {
       
        List<ContentVersion> contentList = new List<ContentVersion>{
        new ContentVersion(ContentURL='http://www.google.com/', Title = 'Google',Number_of_Downloads__c = 1,Sum_Of_Rating__c = 2),
        new ContentVersion(ContentURL='http://www.google.com/', Title = 'Google'),
        new ContentVersion(Title = 'Google',PathOnClient='Penguins.jpg',VersionData=blob.valueOf('Test'), IsMajorVersion = true)
        };        
        
        insert contentList;
        return contentList;
    }
    public static testMethod List<Request__c> createTestRequests() {
        
        List<ContentVersion> contentList = new List<ContentVersion>();
        if(!createdObjNameSet.Contains('ContentVersion')){
            contentList = createTestContents();
            createdObjNameSet.add('ContentVersion');
        }
        else{
            contentList = [SELECT Id, ContentURL, Title, Number_of_Downloads__c, Sum_Of_Rating__c, PathOnClient,VersionData, IsMajorVersion FROM ContentVersion LIMIT 3];
        }
        List<Request__c> reqList = new List<Request__c>();
        if(contentList != null && contentList.size() > 1){
        
            reqList = new List<Request__c>{
                new Request__c(ContentVersionId__c=contentList[0].Id),
                new Request__c(ContentVersionId__c=contentList[1].Id)
            };
        }
        insert reqList;
        return reqList;
    }
    
    public static testMethod List<Materials__c> createTestmaterials() {
       
        List<Materials__c> MaterialsList = new List<Materials__c>();
        
        MaterialsList = new List<Materials__c>{
            new Materials__c(Name = 'Test 1',Cost__c = 49.00),
            new Materials__c(Name = 'Test 2',Cost__c = 65.50)
        };
      
        insert MaterialsList;
        return MaterialsList;
    }
    public static testMethod List<Material_Rating__c> createTestmaterialsRating() {
        List<ContentVersion> contentList = new List<ContentVersion>();
        if(!createdObjNameSet.Contains('ContentVersion')){
            contentList = createTestContents();
            createdObjNameSet.add('ContentVersion');
        }
        else{
            contentList = [SELECT Id, ContentURL, Title, Number_of_Downloads__c, Sum_Of_Rating__c, PathOnClient,VersionData, IsMajorVersion FROM ContentVersion LIMIT 3];
        }
        List<Materials__c> MaterialsList = new List<Materials__c>();
        if(!createdObjNameSet.Contains('Materials')){
            MaterialsList = createTestmaterials();
            createdObjNameSet.add('Materials');
        }
        else{
            MaterialsList = [SELECT Id, Name FROM Materials__c LIMIT 2];
        }
        List<Material_Rating__c> rateList = new List<Material_Rating__c>();
        if(contentList != null && contentList.size() > 1 && MaterialsList != null && MaterialsList.size() > 0){
        
            rateList = new List<Material_Rating__c>{
                new Material_Rating__c(ContentVersionId__c=contentList[0].Id, Rating__c = '4', Material_Name__c = MaterialsList[0].Id),
                new Material_Rating__c(ContentVersionId__c=contentList[1].Id, Rating__c = '4', Material_Name__c = MaterialsList[0].Id)
            };
        }
        insert rateList;
        return rateList;
    }
    
    // Added this method by Sukanya on JAN 24 2017 - Material Request object
    public static testMethod List<Materials_Request__c> createTestMaterialRequest() {
        
        List<OpportunityLineItem> oppList = new List<OpportunityLineItem>();
        if(!createdObjNameSet.Contains('OppLineItem')){
            oppList = createTestOppLineItem();
            createdObjNameSet.add('OppLineItem');
        }else{
            oppList = [SELECT Id, OpportunityId, PricebookEntryId, Quantity, UnitPrice FROM OpportunityLineItem LIMIT 3];
        } 
        
        List<Materials__c> MaterialsList = new List<Materials__c>();
        if(!createdObjNameSet.Contains('Materials')){
            MaterialsList = createTestmaterials();
            createdObjNameSet.add('Materials');
        }
        else{
            MaterialsList = [SELECT Id, Name FROM Materials__c LIMIT 2];
        }
              
        List<Contact> contactList = [SELECT Id,Name,AccountId FROM Contact LIMIT 2];
        
        List<Materials_Request__c> materialReqList = new List<Materials_Request__c>();
        
        if(oppList != null && oppList.size() > 0 && MaterialsList != null && MaterialsList.size() > 0 && contactList != null && contactList.size() > 0){
        
            materialReqList = new List<Materials_Request__c> {
                new Materials_Request__c(Class_Name__c = oppList[0].OpportunityId, Contact__c = contactList[0].Id, Materials_Name__c = MaterialsList[0].Id,Date_Ordered__c = system.today().addDays(3),Due_Date__c = system.today().addDays(20),Qty__c = 1,Date_Delivered__c = system.today().addDays(10),Request_Status__c = 'Ordered',Vendor_Name__c = contactList[0].AccountId),
                new Materials_Request__c(Class_Name__c = oppList[1].OpportunityId, Contact__c = contactList[0].Id, Materials_Name__c = MaterialsList[0].Id,Date_Ordered__c = system.today().addDays(6),Due_Date__c = system.today().addDays(25),Qty__c = 2,Date_Delivered__c = system.today().addDays(18),Request_Status__c = 'Ordered',Vendor_Name__c = contactList[0].AccountId)
            };
        }
        insert materialReqList;
        return materialReqList;
    }
    
    public static testMethod List<MTT_Location__c> createTestLocations() {
        List<MTT_Location__c> locList = new List<MTT_Location__c>();
        locList.add(new MTT_Location__c(Name='DLS - Rosslyn',State__c = 'VA'));
        locList.add(new MTT_Location__c(Name='DLS - Elkridge',State__c = 'MD'));
        insert locList;
        return locList;
    }
    public static testMethod List<Hotel__c> createTestHotels() {
        
        List<MTT_Location__c> locList = new List<MTT_Location__c>();
        if(!createdObjNameSet.Contains('MTTLocation')){
            locList = createTestLocations();
            createdObjNameSet.add('MTTLocation');
        }
        else{
            locList = [SELECT Id, Name, State__c FROM MTT_Location__c LIMIT 1];
        }
        List<Hotel__c> HotelList = new List<Hotel__c>();
        if(locList != null && locList.size() > 0){
        
            HotelList = new List<Hotel__c>{
                new Hotel__c(name='Test Hotel 1',MTT_Location__c = locList[0].Id,Address__c = '4601 US Highway 17, Richmond Hill, GA 31324')
            };
        }
        insert HotelList;
        return HotelList;
    }
    
    
    public static testMethod List<Account> createTestAccounts() {
    
        Id dlsAccRtId;
        
        if(rtMap.containsKey('Account') && rtMap.get('Account').containsKey('DLS')) {
            dlsAccRtId = rtMap.get('Account').get('DLS');
        }else {
            rtMap = queryRecordTypes();
            dlsAccRtId = rtMap.get('Account').get('DLS');
        }
         
        List<Account> acctList = new List<Account>{
            new Account(Name='Test Account 1',Follow_Up__c = date.today(),Type = 'Other',BillingStreet = '24 Jackson Road',RecordTypeId = dlsAccRtId),
            new Account(Name='Test Account 2',Follow_Up__c = date.today()+3,Type = 'Other',BillingStreet = '25 Jackson Road'),
            new Account(Name='Test Account 3',Follow_Up__c = date.today()+6,Type = 'Other',BillingStreet = '26 Jackson Road')
        };
        insert acctList;
        
        accountStaticList = acctList;
        
        return acctList;
    }
    
    public static testMethod List<AcctSeed__GL_Account__c> createTestGLAccount() {
        
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {
            new AcctSeed__GL_Account__c(Name = '19003 - Right of Use Asset-HRND', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '24122 - Lease Liability-ARL', AcctSeed__Sub_Type_1__c = 'Liabilities', AcctSeed__Sub_Type_2__c = 'Current Liabilities', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '32000 - Capital - Jim Bellas', AcctSeed__Sub_Type_1__c = 'Owners Equity', AcctSeed__Sub_Type_2__c = 'Equity', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '30601 - Current Year Earnings', AcctSeed__Sub_Type_1__c = 'Owners Equity', AcctSeed__Sub_Type_2__c = 'Equity', AcctSeed__Active__c  = false, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '50401 - Vendor Payment Discounts', AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Materials', AcctSeed__Active__c  = false, AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '49001 - Customer Payment Discounts', AcctSeed__Sub_Type_1__c = 'Product Revenue', AcctSeed__Sub_Type_2__c = 'Product Family 1', AcctSeed__Active__c  = false, AcctSeed__Type__c ='Revenue', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '40110 - Language Training Revenue', AcctSeed__Sub_Type_1__c = 'Service Revenue', AcctSeed__Sub_Type_2__c = 'Language_Training', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Revenue', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '11011 - Unapplied A/R Clearing AS', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '20002 - Sucontractor Payable', AcctSeed__Sub_Type_1__c = 'Liabilities', AcctSeed__Sub_Type_2__c = 'Current Liabilities', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '22000 - Accrued Payroll Expenses', AcctSeed__Sub_Type_1__c = 'Liabilities', AcctSeed__Sub_Type_2__c = 'Current Liabilities', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '11001 - Accounts Receivable', AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '24125 - Lease Incentive', AcctSeed__Sub_Type_1__c = 'Liabilities', AcctSeed__Sub_Type_2__c = 'Current Liabilities', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false),
            new AcctSeed__GL_Account__c(Name = '51220 - Direct Contractors-Other', AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Direct Services', AcctSeed__Active__c  = true, AcctSeed__Type__c ='Expense', AcctSeed__Bank__c = false)
        };
        
        insert glAcc;
        return glAcc;
    }
    
    public static testMethod List<AcctSeed__GL_Account_Default__c> createTestGLAccountDefault() {
    
        List<AcctSeed__GL_Account_Default__c> glAccountDefault = new List<AcctSeed__GL_Account_Default__c>();
        
        List<AcctSeed__GL_Account__c> glAccount = new List<AcctSeed__GL_Account__c>();
        if(!createdObjNameSet.Contains('GLAcct')){
            glAccount = createTestGLAccount();
            createdObjNameSet.add('GLAcct');
        }else{
            glAccount = [SELECT Id, Name FROM AcctSeed__GL_Account__c];
        }
        
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        if(!createdObjNameSet.Contains('Ledger')){
            ledgers = createTestLedger();
            createdObjNameSet.add('Ledger');
        }else{
            ledgers = [SELECT Id, Name FROM AcctSeed__Ledger__c];
        }
        
        Map<String, String> glAccNameAndSpecification = new Map<String, String>{
            '19003 - Right of Use Asset-HRND' => 'Default_Credit_GL_Account_Expense',
            '24122 - Lease Liability-ARL' => 'Vouchers_Payable_GL_Account',
            '32000 - Capital - Jim Bellas' => 'Retained_Earnings_GL_Account',
            '30601 - Current Year Earnings' => 'Current_Year_Earnings_GL_Account',
            '50401 - Vendor Payment Discounts' => 'Payment_Discount_GL_Account',
            '49001 - Customer Payment Discounts' => 'Customer_Payment_Adjustment_GL_Account',
            '40110 - Language Training Revenue' => 'Revenue_GL_Account',
            '11011 - Unapplied A/R Clearing AS' => 'Unapplied_Cash_GL_Account',
            '20002 - Sucontractor Payable' => 'AP_Control_GL_Account',
            '22000 - Accrued Payroll Expenses' => 'Labor_GL_Account',
            '11001 - Accounts Receivable' => 'AR_Control_GL_Account',
            '24125 - Lease Incentive' => 'Work_in_Process_GL_Account',
            '51220 - Direct Contractors-Other' => 'Default_Project_Task_Labor_GL_Account'
        };
        
        for(AcctSeed__GL_Account__c glAcc : glAccount){
                       
            String specification =  glAccNameAndSpecification.containsKey(glAcc.Name) ? glAccNameAndSpecification.get(glAcc.Name) : '';

            glAccountDefault.add(new AcctSeed__GL_Account_Default__c(AcctSeed__Ledger__c = ledgers[0].Id, AcctSeed__GL_Account__c = glAcc.Id, AcctSeed__GL_Account_Specification__c = specification));
            
            if(glAcc.Name == '40110 - Language Training Revenue'){    
                glAccountDefault.add(new AcctSeed__GL_Account_Default__c(AcctSeed__Ledger__c = ledgers[0].Id, AcctSeed__GL_Account__c = glAcc.Id, AcctSeed__GL_Account_Specification__c = 'Default_Credit_GL_Account_Revenue'));    
            }
        }
        
        insert glAccountDefault;
        
        return glAccountDefault;
    }
    
    public static testMethod List<Contact> createTestContacts()  {
        
        List<Account> getAccList = new List<Account>();
        if(!createdObjNameSet.Contains('Account')){
            getAccList = createTestAccounts();
            createdObjNameSet.add('Account');
        }
        else{
            //getAccList = [SELECT Id, Name, Follow_Up__c, Type, BillingStreet, RecordTypeId FROM Account LIMIT 2];
            getAccList = accountStaticList;
        }
        
        List<Contact> contList = new List<Contact>{
            new Contact(LastName='Test Contact1',account=getAccList[0],Email='test1@test.com',MailingPostalCode = '60012',AccountId=getAccList[0].Id, Geo_Code_Status__c = 'Processed'),
            new Contact(LastName='Test Contact2',account=getAccList[0],Email='test2@test.com',MailingPostalCode = '60013',AccountId=getAccList[1].Id, Geo_Code_Status__c = 'Processed'),
            new Contact(LastName='Test Contact3',account=getAccList[0],Email='test3@test.com',MailingPostalCode = '60014',AccountId=getAccList[0].Id),
            new Contact(LastName='Testing',account=getAccList[0],Email='test3@test.com',MailingPostalCode = '60015',AccountId=getAccList[1].Id, Geo_Code_Status__c = 'Processed')
        };
        
        Id instructorTypeId, studentTypeId, staffTypeId, client1TypeId, client2TypeId;
        if(!rtMap.containsKey('Contact')) {
            rtMap = queryRecordTypes();
        }
        
        if(rtMap.containsKey('Contact')) {
            if(rtMap.get('Contact').containsKey('Candidate')) 
                instructorTypeId = rtMap.get('Contact').get('Candidate');
            if(rtMap.get('Contact').containsKey('Student')) 
                studentTypeId = rtMap.get('Contact').get('Student');
            if(rtMap.get('Contact').containsKey('DLS_Employee')) 
                staffTypeId = rtMap.get('Contact').get('DLS_Employee');
            if(rtMap.get('Contact').containsKey('Commercial_Client'))
                client1TypeId = rtMap.get('Contact').get('Commercial_Client');
            if(rtMap.get('Contact').containsKey('USG_Client'))
                client2TypeId = rtMap.get('Contact').get('USG_Client');
        }
        
        contList.add(new Contact(LastName='Test Contact1',account=getAccList[0],Email='test1@test.com',MailingPostalCode = '60012',AccountId=getAccList[0].Id, Geo_Code_Status__c = 'Processed',RecordTypeId = instructorTypeId));
        contList.add(new Contact(LastName='StudentContact',account=getAccList[0],Email='test1@test.com',MailingPostalCode = '60012',AccountId=getAccList[0].Id, Geo_Code_Status__c = 'Processed',RecordTypeId = studentTypeId));
        contList.add(new Contact(LastName='StaffContact',account=getAccList[0],Email='test1@test.com',MailingPostalCode = '60012',AccountId=getAccList[0].Id, Geo_Code_Status__c = 'Processed',RecordTypeId = staffTypeId, Active_DLS_Employee__c=true));
        contList.add(new Contact(LastName='Commercial Client',account=getAccList[0],Email='ccClient@test.com',MailingPostalCode = '60012',AccountId=getAccList[0].Id, Geo_Code_Status__c = 'Processed',RecordTypeId = client1TypeId));
        contList.add(new Contact(LastName='USG Client',account=getAccList[0],Email='usgClient@test.com',MailingPostalCode = '60012',AccountId=getAccList[0].Id, Geo_Code_Status__c = 'Processed',RecordTypeId = client2TypeId));
        
        
        Contact c = new Contact();
        c.AccountId = getAccList[0].Id;
        c.FirstName = 'myFirstName';
        c.LastName = 'myLastName';
        c.MiddleName = 'myMidName';
        c.Email = 'myInsttestemail789@gmail.com';
        c.RecordTypeId = instructorTypeId;
        contList.add(c);
        
        
        insert contList;
        
         Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        User user = new User(alias = 'test789', email='myInsttestemail789@gmail.com',
                             emailencodingkey='UTF-8', FirstName='myFirstName', LastName = 'myLastName', 
                             MiddleName = 'myMidName', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = contList[7].Id,
                             timezonesidkey='America/Los_Angeles', username='tester789@noemail.com');
        
        insert user;     
        
        staticContactList = contList;
        
        return contList;
    }
    public static testMethod List<Language__c> createTestLanguages()  {
           
        List<Language__c> langList = new List<Language__c>();
        langList = new List<Language__c> {
        
            new Language__c(Name ='English'),
            new Language__c(Name ='Russian'),
            new Language__c(Name ='Dari'),
            new Language__c(Name ='French')
        
        };
        insert langList;
        return langList;   
    }
    public static testMethod List<Known_Language__c> createTestKnownLanguages()  {
        List<Language__c> langList = new List<Language__c>();
        List<Contact> conList = new List<Contact>();
        List<Known_Language__c> KnownlangList = new List<Known_Language__c>();
        if(!createdObjNameSet.Contains('Language')){
            langList = createTestLanguages();
            createdObjNameSet.add('Language');
        }
        else{
            langList = [SELECT Id, Name FROM Language__c limit 4];
        }
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        }
        KnownlangList = new List<Known_Language__c> {
        
            new Known_Language__c(Language__c = langList[0].Id,Contact__c = conList[0].Id),
            new Known_Language__c(Language__c = langList[0].Id,Contact__c = conList[0].Id),
            new Known_Language__c(Language__c = langList[0].Id,Contact__c = conList[0].Id),
            new Known_Language__c(Language__c = langList[0].Id,Contact__c = conList[0].Id)
        
        };
        insert KnownlangList;
        return KnownlangList;   
    }
    
    public static testMethod List<Contract> createTestContracts() {
        
        String GovernContractId;
        Id genContrRtId;
        
        if(!rtMap.containsKey('Contract'))
            rtMap = queryRecordTypes();
        
        if(rtMap.containsKey('Contract') && rtMap.get('Contract').containsKey('Federal_Client')) {
            genContrRtId = rtMap.get('Contract').get('Federal_Client');
        }
        
        List<Contact> contactList = new List<Contact>();
        if(!createdObjNameSet.Contains('Contact')){
            contactList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            contactList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        }
        List<Account> getAccList = [SELECT Id,Name FROM Account LIMIT 2];
        List<System_Values__c> sysValuesList = createSystemValues();
        List<Contract> contractList = new List<Contract> {
            
            new Contract(RecordTypeId = genContrRtId,AccountId = getAccList[0].Id, Status = 'Completed Draft',StartDate = system.today(),Billing_Contact__c = contactList[1].Id,Primary_POC__c = contactList[0].Id),
            new Contract(RecordTypeId = genContrRtId,AccountId = getAccList[1].Id,Status = 'Completed Draft',StartDate = system.today(),Primary_POC__c = contactList[0].Id)
        };
        
        insert contractList;
        return contractList;
    }
    
    public static testMethod List<Opportunity> createTestOpportunities() {
        
        String newClassRT;
        String testingOppRT;
        String DLIWOppRT;
        
        if(!rtMap.containsKey('Opportunity')) {
            rtMap = queryRecordTypes();
        }
        
        if(rtMap.containsKey('Opportunity')) {
            if(rtMap.get('Opportunity').containsKey('New_Classes_Opportunities')) 
                newClassRT = rtMap.get('Opportunity').get('New_Classes_Opportunities');
            
            if(rtMap.get('Opportunity').containsKey('Testing_Opportunities')) 
                testingOppRT = rtMap.get('Opportunity').get('Testing_Opportunities');
                
            if(rtMap.get('Opportunity').containsKey('DLI_W_TO_Opportunities'))
                DLIWOppRT = rtMap.get('Opportunity').get('DLI_W_TO_Opportunities');
        }
        
        List<Account> getAccList = new List<Account>();
        if(!createdObjNameSet.Contains('Account')){
            getAccList = createTestAccounts();
            createdObjNameSet.add('Account');
        }else{
            //getAccList = [SELECT Id,Name FROM Account LIMIT 2];
            getAccList = accountStaticList;
        }

        List<System_Values__c> sysVal = new List<System_Values__c>{
            new System_Values__c(Name =  'FBI Account',Value__c = getAccList[0].Id),
            new System_Values__c(Name = 'ICA Language Services Account',Value__c = getAccList[1].Id)
        };
        
        Insert sysVal;
        List<Opportunity> oppList = new List<Opportunity> {
            new Opportunity(Name = 'Test Opp 1',StageName = 'Inquiry',Start_Date__c = System.Today(),End_Date__c = System.Today()+30,CloseDate = System.Today()+20,AccountId = getAccList[0].Id,RecordTypeId = newClassRT,Hours_Week__c = 6,Section__c = 'AA',Language__c = 'French'),
            new Opportunity(Name = 'Test Opp 4',StageName = 'Active',Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = getAccList[1].Id,RecordTypeId = testingOppRT),
            new Opportunity(Name = 'Test Opp 5',StageName = 'Order',Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = getAccList[1].Id,RecordTypeId = newClassRT),
            new Opportunity(Name = 'Test Opp 6',StageName = 'Order',Start_Date__c = System.Today()+10,End_Date__c = System.Today()+40,CloseDate = System.Today()+45,AccountId = getAccList[1].Id,RecordTypeId = DLIWOppRT)
        };
        
        insert oppList;
        
        oppStaticList = oppList;
        
        return oppList;
    }
    
    /*** Custom Setting Object *****/
    public static testMethod List<Opportunity_Project_Mapping__c> createTestOpportunityProjectMapping() {
    
        List<Opportunity_Project_Mapping__c> oppProjMappingList = new List<Opportunity_Project_Mapping__c>();
        String TestingOppRTId, PartnerSchoolOppRTId, NewClassOppRTId, AdminOppRTId, AFPAKOppRTId, TestingPrjRTId, PartnerSchoolPrjRTId, NewClassPrjRTId, AdminPrjRTId, AFPAKPrjRTId;
    
        if(!rtMap.containsKey('Opportunity')) {
            rtMap = queryRecordTypes();
        }
        
        if(rtMap.containsKey('Opportunity')) {
        
            if(rtMap.get('Opportunity').containsKey('Testing_Opportunities')) 
                TestingOppRTId = rtMap.get('Opportunity').get('Testing_Opportunities');
                
            if(rtMap.get('Opportunity').containsKey('Partner_School')) 
                PartnerSchoolOppRTId = rtMap.get('Opportunity').get('Partner_School');
                
            if(rtMap.get('Opportunity').containsKey('New_Classes_Opportunities')) 
                NewClassOppRTId = rtMap.get('Opportunity').get('New_Classes_Opportunities');
                
            if(rtMap.get('Opportunity').containsKey('Admin_Opportunities')) 
                AdminOppRTId = rtMap.get('Opportunity').get('Admin_Opportunities');
        }
        if(rtMap.containsKey('AcctSeed__Project__c')) {
        
            if(rtMap.get('AcctSeed__Project__c').containsKey('Testing_Projects')) 
                TestingPrjRTId = rtMap.get('AcctSeed__Project__c').get('Testing_Projects');
                
            if(rtMap.get('AcctSeed__Project__c').containsKey('Partner_School_LT_Projects')) 
                PartnerSchoolPrjRTId = rtMap.get('AcctSeed__Project__c').get('Partner_School_LT_Projects');
                
            if(rtMap.get('AcctSeed__Project__c').containsKey('Language_Training_Projects')) 
                NewClassPrjRTId = rtMap.get('AcctSeed__Project__c').get('Language_Training_Projects');
                
            if(rtMap.get('AcctSeed__Project__c').containsKey('Admin_Projects')) 
                AdminPrjRTId = rtMap.get('AcctSeed__Project__c').get('Admin_Projects');
        } 
        
        oppProjMappingList = new List<Opportunity_Project_Mapping__c> {
        
            new Opportunity_Project_Mapping__c(Name = 'Planned',Value_Type__c = 'Stage',Project_Value__c = 'Planned',Opportunity_Value__c='Planned'),
            new Opportunity_Project_Mapping__c(Name = 'Order',Value_Type__c = 'Stage',Project_Value__c = 'Order',Opportunity_Value__c='Order'),
            new Opportunity_Project_Mapping__c(Name = 'On Hold',Value_Type__c = 'Stage',Project_Value__c = 'On Hold',Opportunity_Value__c='On Hold'),
            new Opportunity_Project_Mapping__c(Name = 'Ended',Value_Type__c = 'Stage',Project_Value__c = 'Ended',Opportunity_Value__c='Ended'),
            new Opportunity_Project_Mapping__c(Name = 'Active',Value_Type__c = 'Stage',Project_Value__c = 'Active',Opportunity_Value__c='Active'),
            
            new Opportunity_Project_Mapping__c(Name = TestingOppRTId,Value_Type__c = 'RT',Project_Value__c = TestingPrjRTId,Opportunity_Value__c = TestingOppRTId),
            new Opportunity_Project_Mapping__c(Name = PartnerSchoolOppRTId,Value_Type__c = 'RT',Project_Value__c = PartnerSchoolPrjRTId,Opportunity_Value__c = PartnerSchoolOppRTId),
            
            new Opportunity_Project_Mapping__c(Name = NewClassOppRTId,Value_Type__c = 'RT',Project_Value__c = NewClassPrjRTId,Opportunity_Value__c = NewClassOppRTId),
            new Opportunity_Project_Mapping__c(Name = AdminOppRTId,Value_Type__c = 'RT',Project_Value__c = AdminPrjRTId,Opportunity_Value__c = AdminOppRTId)

        };
        if(oppProjMappingList != null && oppProjMappingList.size() > 0)
            insert oppProjMappingList;
        return oppProjMappingList;
    }
    public static testMethod List<Transaction__c> createTestTransactions() {
        
        List<OpportunityLineItem> oppList = new List<OpportunityLineItem>();
        if(!createdObjNameSet.Contains('OppLineItem')){
            oppList = createTestOppLineItem();
            createdObjNameSet.add('OppLineItem');
        }else{
            oppList = [SELECT Id, OpportunityId, PricebookEntryId, Quantity, UnitPrice FROM OpportunityLineItem LIMIT 3];
        }        
        List<Transaction__c> transactionList = new List<Transaction__c>();
        List<AcctSeed__Project_Task__c> proj = new List<AcctSeed__Project_Task__c>();
        if(!createdObjNameSet.Contains('AcctPrjtTask')){
            proj = createTestProjectTask();
            createdObjNameSet.add('AcctPrjtTask');
        }else{
            proj = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        }
        if(oppList != null && oppList.size() > 0){
        
            transactionList = new List<Transaction__c>{
            new Transaction__c(Opportunity__c = oppList[0].OpportunityId,Transaction_Date__c=System.today(),Project__c = proj[0]. AcctSeed__Project__c),
            new Transaction__c(Opportunity__c = oppList[1].OpportunityId,Transaction_Date__c=System.today())
            };
            Insert transactionList;
        }
        return transactionList;
    }
    public static testMethod List<Payment_Item__c> createTestpaymentItems() {
        
        List<Transaction__c> transactionList = new List<Transaction__c>();
        if(!createdObjNameSet.Contains('Transaction')){
            transactionList = createTestTransactions();
            createdObjNameSet.add('Transaction');
        }else{
            transactionList = [SELECT Id,Opportunity__c, Transaction_Date__c, Project__c FROM Transaction__c LIMIT 2];
        }
        List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>();
        if(transactionList != null && transactionList.size() > 0){
            paymentItemList = new List<Payment_Item__c>{new Payment_Item__c(Payment__c = transactionList[0].Id,Amount__c=100)};
        Insert paymentItemList;
        }
        return paymentItemList;
    }
    
     public static testMethod List<AcctSeed__Project__c> createTestProject() {
        
        Id projRTId;
        Id adminproRTId;
        if(!rtMap.containsKey('AcctSeed__Project__c')) {
            rtMap = queryRecordTypes();
        }
        
        if(rtMap.containsKey('AcctSeed__Project__c')) {
            if(rtMap.get('AcctSeed__Project__c').containsKey('Language_Training_Projects')) 
                projRTId = rtMap.get('AcctSeed__Project__c').get('Language_Training_Projects');
                
            if(rtMap.get('AcctSeed__Project__c').containsKey('Admin_Projects')) 
                adminproRTId = rtMap.get('AcctSeed__Project__c').get('Admin_Projects');
        }
        
        Id usrId = UserInfo.getUserId();
        List<Opportunity> OppList = new List<Opportunity>();
        if(!createdObjNameSet.Contains('Opportunity')){
            oppList = createTestOpportunities();
            createdObjNameSet.add('Opportunity');
        }
        else{
            //oppList = [SELECT Id, Name, StageName, Start_Date__c, End_Date__c, CloseDate,AccountId, RecordTypeId, Hours_Week__c FROM Opportunity LIMIT 4];
            oppList = oppStaticList;
        }   
        
        List<Account> getAccList = new List<Account>();
        if(!createdObjNameSet.Contains('Account')){
            getAccList = createTestAccounts();
            createdObjNameSet.add('Account');
        }else{
            getAccList = accountStaticList;
        }
        
        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();    
        if(OppList != null && OppList.size () > 0) { 
         
        projList = new List<AcctSeed__Project__c> {
            new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = projRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = OppList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10), AcctSeed__Account__c = getAccList[0].Id),
            new AcctSeed__Project__c(Name = 'Test Project 2',AcctSeed__Status__c = 'Inquiry',RecordTypeId = projRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = OppList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10), AcctSeed__Account__c = getAccList[1].Id),
            new AcctSeed__Project__c(Name = 'Test Project 3',AcctSeed__Status__c = 'Active',RecordTypeId = adminproRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = OppList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10), AcctSeed__Account__c = getAccList[0].Id),
            new AcctSeed__Project__c(Name = 'Test Project 4',AcctSeed__Status__c = 'Inquiry',RecordTypeId = adminproRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = OppList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10), AcctSeed__Account__c = getAccList[1].Id)
        };
        
        }
        
        insert projList;
        projectStaticList = projList;        
        return projList;
    }
    public static testMethod List<AcctSeed__Accounting_Period__c> createTestAccountingPeriod() {
    
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        Date weekEnd = myDate.toStartofWeek()+7;
        
        String month;
        date monthStart = weekStart.toStartofMonth();
        date monthEnd = weekStart.addMonths(1).toStartofMonth().addDays(-1);
        date monthStart1 = weekEnd.toStartofMonth();
        date monthEnd1 = weekEnd.addMonths(1).toStartofMonth().addDays(-1);
        
        List<AcctSeed__Accounting_Period__c> accPeriodList = new List< AcctSeed__Accounting_Period__c >();
        
        if(monthStart.month() < 10){
            month = '0'+monthStart.month();
        }else {
            month = String.valueOf(monthStart.month());
        }
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
        accPeriod.name = weekStart.year()+'-' +month;
        accPeriod.AcctSeed__Start_Date__c = monthStart;
        accPeriod.AcctSeed__End_Date__c = monthEnd;
        Insert accPeriod;
        accPeriodList.add(accPeriod);
        
        //Insert 2nd Accounting period If week start and week end are in different month
        if(monthStart != monthStart1 && monthEnd != monthEnd1) {
            if(monthStart1.month() < 10){
                month = '0'+monthStart1.month();
            }else {
                month = String.valueOf(monthStart1.month());
            }
            
            AcctSeed__Accounting_Period__c accPeriod1 = new AcctSeed__Accounting_Period__c();
            accPeriod1.name = weekEnd.year()+'-' +month;
            accPeriod1.AcctSeed__Start_Date__c = monthStart1;
            accPeriod1.AcctSeed__End_Date__c = monthEnd1;
            Insert accPeriod1;
            accPeriodList.add(accPeriod1);
        }
        
        return accPeriodList;
    }
    
    /*public static testMethod List<AcctSeed__Billing_Format__c>() {
        List<AcctSeed__Billing_Format__c> BillingFormatList = new List<AcctSeed__Billing_Format__c>{
        
            new AcctSeed__Billing_Format__c(AcctSeed__Visualforce_PDF_Page__c = 'ConvertToProject', AcctSeed__Default_Email_Template__c = 'Billing_Email_Template')
        
        };
        insert BillingFormatList;
        return BillingFormatList;
    }
    public static testMethod List<AcctSeed__Billing__c> createTestBilling() {
    
        List<Opportunity> oppList = new List<Opportunity>();
        if(!createdObjNameSet.Contains('Opportunity')){
            oppList = createTestOpportunities();
            createdObjNameSet.add('Opportunity');
        }
        else{
            oppList = [SELECT Id, Name, StageName, Start_Date__c, End_Date__c, CloseDate,AccountId, RecordTypeId, Hours_Week__c FROM Opportunity LIMIT 4];
        }
        List<AcctSeed__Accounting_Period__c> accPeriod = new List<AcctSeed__Accounting_Period__c>();
        if(!createdObjNameSet.Contains('AcctPeriod')){
            accPeriod = createTestAccountingPeriod();
            createdObjNameSet.add('AcctPeriod');
        }
        else{
            accPeriod = [SELECT Id, Name, AcctSeed__End_Date__c,AcctSeed__Start_Date__c, AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c LIMIT 1];
        }
        List<AcctSeed__Billing_Format__c> billingFormat = new List<AcctSeed__Billing_Format__c>();
        if(!createdObjNameSet.Contains('BillFormat')){
            billingFormat = createTestBillingFormat();
            createdObjNameSet.add('BillFormat');
        }
        else{
            billingFormat = [SELECT Id, AcctSeed__Visualforce_PDF_Page__c, AcctSeed__Default_Email_Template__c FROM AcctSeed__Billing_Format__c LIMIT 1];
        }
        List<Account> accList = [select Id, Name from Account limit 1];
        List<AcctSeed__Billing__c> acctseedBillingList = new List<AcctSeed__Billing__c> {
        
            new AcctSeed__Billing__c(AcctSeed__Opportunity__c = oppList[0].Id, AcctSeed__Customer__c = accList[0].Id,AcctSeed__Accounting_Period__c = accPeriod[0].Id, AcctSeed__Billing_Format__c = billingFormat[0].Id)
        
        }; 
        insert acctseedBillingList;
        return acctseedBillingList;   
    }
    
    public static testMethod List< AcctSeed__Billing_Rates__c > createTestBillingRate() {
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c>();
        if(!createdObjNameSet.Contains('AcctPrjtTask')){
            projTask = createTestProjectTask();
            createdObjNameSet.add('AcctPrjtTask');
        }else{
            projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        }
        List<AcctSeed__Billing_Rates__c> billingRate = new List< AcctSeed__Billing_Rates__c >();
    
        billingRate = new List< AcctSeed__Billing_Rates__c > {
        
            new AcctSeed__Billing_Rates__c(AcctSeed__Project_Task__c = projTask[0].Id, AcctSeed__Project__c = projTask[0].AcctSeed__Project__c)
        
        
        };
        insert billingRate;
        return billingRate;   
    }
    
    public static testMethod List< AcctSeed__Billing_Line__c > createTestBillingLine() {
        
        List<AcctSeed__Billing__c> acctseedBillingList = new List<AcctSeed__Billing__c>();
        if(!createdObjNameSet.Contains('AcctBill')){
            acctseedBillingList = createTestBilling();
            createdObjNameSet.add('AcctBill');
        }else{
            acctseedBillingList = [SELECT Id, AcctSeed__Opportunity__c, AcctSeed__Customer__c,AcctSeed__Accounting_Period__c, AcctSeed__Billing_Format__c FROM AcctSeed__Billing__c LIMIT 1];
        }
        List<AcctSeed__GL_Account__c> glAccount = new List<AcctSeed__GL_Account__c>();
        if(!createdObjNameSet.Contains('GLAcct')){
            glAccount = createTestGLAccount();
            createdObjNameSet.add('GLAcct');
        }else{
            glAccount = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 2];
        }
        List<AcctSeed__Billing_Line__c> billingLineList = new List<AcctSeed__Billing_Line__c>{
            new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = acctseedBillingList[0].Id, AcctSeed__Rate__c = 20, AcctSeed__Revenue_GL_Account__c = glAccount[0].Id)
        };   
        
        insert billingLineList;  
        return billingLineList;
    }
    */
    /*public static testMethod List<Assessment_Report__c> createTestAssessmentReport() {
        
        List<AcctSeed__Project__c> projList = createTestProject();
        List<Contact> conList = createTestContacts();
        
        //List<Account> accList = createTestAccounts();
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<Assessment_Report__c> assReport = new List<Assessment_Report__c> {
            new Assessment_Report__c(Name = 'Test Report1',Project__c=projList[0].Id,Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10),
            new Assessment_Report__c(Name = 'Test Report2',Project__c=projList[0].Id,Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'English',Student__c = conList[0].Id,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+20)
        };
        
        insert assReport;
        return assReport;
    }*/
    /*public static testMethod List<AcctSeed__Accounting_Settings__c> createTestAccountingSetting() {
        List<AcctSeed__GL_Account__c> glAccList = createTestGLAccount();
        List<AcctSeed__Accounting_Settings__c> acctList = new List<AcctSeed__Accounting_Settings__c> {
        
            new AcctSeed__Accounting_Settings__c(AcctSeed__Default_Project_Task_Labor_GL_Account__c  = glAccList[0].Id)
        };
        insert acctList;
        return acctList;
    }*/
    public static testMethod List<AcctSeed__Project_Task__c> createTestProjectTask() {
        
        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        List<Contact> conList = new List<Contact>();
        List<AcctSeed__Project__c> adminprojList = new List<AcctSeed__Project__c>();
        if(!createdObjNameSet.Contains('AcctPrjt')){
            projList = createTestProject();
            createdObjNameSet.add('AcctPrjt');
        }else{  
            //projList = [SELECT Id, Name, AcctSeed__Status__c,RecordTypeId,RecordType.DeveloperName, Project_Manager__c, AcctSeed__Opportunity__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 5];
            projList = projectStaticList;
        }
        
        if(!rtMap.containsKey('AcctSeed__Project__c')) {
            rtMap = queryRecordTypes();
        }
        
        List<System_Values__c> sysValuesList = createSystemValues();
        
        Id projRTId;
        Id adminproRTId;
        
        if(rtMap.containsKey('AcctSeed__Project__c')) {
            if(rtMap.get('AcctSeed__Project__c').containsKey('Language_Training_Projects')) 
                projRTId = rtMap.get('AcctSeed__Project__c').get('Language_Training_Projects');
                
            if(rtMap.get('AcctSeed__Project__c').containsKey('Admin_Projects')) 
                adminproRTId = rtMap.get('AcctSeed__Project__c').get('Admin_Projects');
        }
        
        for(AcctSeed__Project__c pro : projList){
            if(pro.RecordTypeId == adminproRTId)
                adminprojList.add(pro);
        }
                
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            //conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 4];
            conList = staticContactList;
        }
        List<AcctSeed__GL_Account__c> glAccList = new List<AcctSeed__GL_Account__c>();
        if(!createdObjNameSet.Contains('GLAcct')){
            glAccList = createTestGLAccount();
            createdObjNameSet.add('GLAcct');
        }else{
            glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 2];
        }
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Task-Tamil',AcctSeed__Client_Contact__c=conList[0].Id,AcctSeed__Project__c=projList[0].Id,Project_Task_Type__c='Language Training',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=41),
            new AcctSeed__Project_Task__c(Name = 'Test Task-English',AcctSeed__Client_Contact__c=conList[1].Id,AcctSeed__Project__c=projList[1].Id,Project_Task_Type__c='Language Testing',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40),
            new AcctSeed__Project_Task__c(Name = 'Test Translation (per Word)',AcctSeed__Client_Contact__c=conList[0].Id,AcctSeed__Project__c=projList[1].Id,Project_Task_Type__c='Translation (per word)',Default_Cost_Rate_Rate_Type__c='Non-SCA Translation (Per Word)',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40),
            new AcctSeed__Project_Task__c(Name = 'Test Translation  (per Hour)',AcctSeed__Client_Contact__c=conList[0].Id,AcctSeed__Project__c=projList[1].Id,Project_Task_Type__c='Translation (per hr)',Default_Cost_Rate_Rate_Type__c='Non-SCA Translation (Per Hour)',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40),
            new AcctSeed__Project_Task__c(Name = 'Test Interpretation (per Hour)',AcctSeed__Client_Contact__c=conList[0].Id,AcctSeed__Project__c=projList[1].Id,Project_Task_Type__c='Interpretation (per hr)',Default_Cost_Rate_Rate_Type__c='Non-SCA Interpretation (Per Hour)',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40)
        };
        
        if(adminprojList.size() > 0) {
            projTask.add(new AcctSeed__Project_Task__c(Name = 'Test Fringe',AcctSeed__Client_Contact__c=conList[1].Id,AcctSeed__Project__c = adminprojList[0].Id,Project_Task_Type__c='Fringe',AcctSeed__Labor_GL_Account__c=glAccList[0].Id));
        }
        
        insert projTask;
        return projTask;
    }
    
    public static testMethod List<Experience__c> createTestExperience() {
        
        List<Contact> conList = new List<Contact>();
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        }
        Map<String,Id> ExpRTNamWithIdMap = new Map<String,Id>();
      
        if(!rtMap.containsKey('Experience__c')) {
            rtMap = queryRecordTypes();
        }
        
        if(rtMap.containsKey('Experience__c')) {
            ExpRTNamWithIdMap = rtMap.get('Experience__c');
        }
        
        List<Experience__c> expList = new List<Experience__c>{
            new Experience__c(RecordTypeId = ExpRTNamWithIdMap.get('Education_Experience'),Start_Date__c = date.newinstance(2000, 03, 01), College_School__c = 'Test College',Degree__c = 'Test Degree',Degree_Level__c = 'B.A.',End_Date__c = date.newinstance(2000, 2, 17),Contact__c = conList[0].Id),
            new Experience__c(RecordTypeId = ExpRTNamWithIdMap.get('Professional_Work_Experience'),Start_Date__c = date.newinstance(2000, 03, 01),End_Date__c = date.newinstance(2002, 10, 29),Contact__c = conList[0].Id,Name_of_Company__c = 'Test Company 1',Degree_Level__c = 'M.A.'),
            new Experience__c(RecordTypeId = ExpRTNamWithIdMap.get('Professional_Work_Experience'),Start_Date__c = date.newinstance(2002, 11, 01),End_Date__c = date.newinstance(2006, 8, 30),Contact__c = conList[1].Id,Name_of_Company__c = 'Test Company 2',Degree_Level__c = 'B.A.'),
            new Experience__c(RecordTypeId = ExpRTNamWithIdMap.get('Volunteer_Experience'),Start_Date__c = date.newinstance(2004, 11, 01),End_Date__c = date.newinstance(2004, 12, 30),Contact__c = conList[1].Id,Degree_Level__c = 'B.A.')
        };
        Insert expList;
        return expList;
    }
    
    public static testMethod List<Skill__c> createTestSkill() {
        List<Contact> conList = new List<Contact>();
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        }
        List<Skill__c> skillList = new List<Skill__c> {
            new Skill__c(Contact__c = conList[0].Id, From_Language__c='Tamil', To_Language__c='Russian')        
        };  
        insert skillList;
        return skillList;  
    }
    
    public static testMethod List<Language_Testing__c> createTestLanguageTesting() {        
        
        List<AcctSeed__Project_Task__c> projTaskList = new List<AcctSeed__Project_Task__c>();
        if(!createdObjNameSet.Contains('AcctPrjtTask')){
            projTaskList = createTestProjectTask();
            createdObjNameSet.add('AcctPrjtTask');
        }else{
            projTaskList = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        }
       
        List<contact> conList = [SELECT Id,Name FROM Contact LIMIT 5];
        List<Language_Testing__c> langtestList = new List<Language_Testing__c>();
        
        if(conList != null && conList.size() > 0 && projTaskList != null && projTaskList.size() > 1){
        
            langtestList = new List<Language_Testing__c> {
                new Language_Testing__c(Name='Test Lang', Project_Task__c=projTaskList[0].Id, Testee__c = conList[0].Id,S_Goal__c='0',L_Goal__c='0',R_Goal__c='0',W_Goal__c='0',Target_Language__c='Tamil'),
                new Language_Testing__c(Name='Test Lang2', Project_Task__c=projTaskList[1].Id, Testee__c = conList[0].Id,S_Goal__c='0',L_Goal__c='0',R_Goal__c='0',W_Goal__c='0',Target_Language__c='Tamil'),
                new Language_Testing__c(Name='Test Lang3', Project_Task__c=projTaskList[0].Id, Testee__c = conList[0].Id)
            };
        
        }
        insert langtestList;
        return langtestList;
    }
    public static testMethod List<Product2> createTestProduct(){
        
        List<Product2> prodList = new List<Product2> {
            new Product2(Name = 'Test Product', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training'),
            new Product2(Name = 'Test Product2', Description = 'Test Desc2', productCode = 'Test Code2', isActive = TRUE,Family='Language Training'),
            new Product2(Name = 'Test Product2', Description = 'Test Desc2', productCode = 'Test Code2', isActive = TRUE,Family='Material Budget'),
            new Product2(Name = 'Test Product2', Description = 'Test Desc2', productCode = 'Test Code2', isActive = TRUE,Family='Travel'),
            new Product2(Name = 'Test Product2', Description = 'Test Desc2', productCode = 'Test Code2', isActive = TRUE,Family='ODC')
        };
        
        Insert prodList;
        return prodList;
    }
    
    public static testMethod List<PricebookEntry> createTestPriceBook(){
        List<Product2> prodList = new List<Product2>();
        if(!createdObjNameSet.Contains('Product')){
            prodList = createTestProduct();
            createdObjNameSet.add('Product');
        }else{
            prodList = [SELECT Id, Name, Description, productCode, isActive, Family FROM Product2 LIMIT 5];
        }
        String stdPriceBookId = Test.getStandardPricebookId();
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>{
        
         new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100),
         new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[1].Id, IsActive = TRUE, UnitPrice = 100),
         new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[2].Id, IsActive = TRUE, UnitPrice = 100),
         new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[3].Id, IsActive = TRUE, UnitPrice = 100),
         new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = prodList[4].Id, IsActive = TRUE, UnitPrice = 100)
        };
        
        Insert priceBookEntryList;
        return priceBookEntryList;
    }
    public static testMethod List<Quote> createTestQuote() { 
        
        List<Opportunity> oppList = new List<Opportunity>();
        if(!createdObjNameSet.Contains('Opportunity')){
            oppList = createTestOpportunities();
            createdObjNameSet.add('Opportunity');
        }
        else{
            //oppList = [SELECT Id, Name, StageName, Start_Date__c, End_Date__c, CloseDate,AccountId, RecordTypeId, Hours_Week__c FROM Opportunity LIMIT 4];
            oppList = oppStaticList;
        }
        
        if(!rtMap.containsKey('Opportunity')) {
            rtMap = queryRecordTypes();
        }
        
        Id newClassOppRT;
        if(rtMap.containsKey('Opportunity')) {
            if(rtMap.get('Opportunity').containsKey('New_Classes_Opportunities'))
                newClassOppRT = rtMap.get('Opportunity').get('New_Classes_Opportunities');
        }
        
        Id opp1Id;
        for(Opportunity opp : oppList){
            if(opp.RecordTypeId == newClassOppRT)
                opp1Id = opp.Id;
        }
        
        List<Quote> opliList = new List<Quote> {
        
            new Quote(Name = 'Test Quote 1', OpportunityId = opp1Id),
            new Quote(Name = 'Test Quote 2',OpportunityId = opp1Id),
            new Quote(Name = 'Test Quote 3',OpportunityId = opp1Id)
            
        };
        
        insert opliList;
        return opliList;
    }
    
    public static testMethod List<OpportunityLineItem> createTestOppLineItem() { 
        
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        List<CLIN__c> clinList = new List<CLIN__c>();
        String oppId;
        List<Opportunity> oppList = new List<Opportunity>();
        if(!createdObjNameSet.Contains('PriceBookEntry')){
            priceBookEntryList = createTestPriceBook();
            createdObjNameSet.add('PriceBookEntry');
        }
        else{
            priceBookEntryList = [SELECT Id, Pricebook2Id, Product2Id, IsActive, UnitPrice FROM PricebookEntry LIMIT 5];
        }
        
        if(!createdObjNameSet.Contains('CLIN')){
            clinList = createTestClin();
            createdObjNameSet.add('CLIN');
        }
        else{
            clinList = [SELECT Id, Contract__c, Name, CLIN_Name__c FROM CLIN__c LIMIT 5];
        }
        if(!createdObjNameSet.Contains('Opportunity')){
            oppList = createTestOpportunities();
            createdObjNameSet.add('Opportunity');
        }
        else{
            //oppList = [SELECT Id, Name, StageName, Start_Date__c, End_Date__c, CloseDate,AccountId, RecordTypeId, Hours_Week__c FROM Opportunity LIMIT 8];
             oppList = oppStaticList;
        }
        
        if(!rtMap.containsKey('Opportunity')) {
            rtMap = queryRecordTypes();
        }
        
        Id newClassOppRT;
        if(rtMap.containsKey('Opportunity')) {
            if(rtMap.get('Opportunity').containsKey('New_Classes_Opportunities'))
                newClassOppRT = rtMap.get('Opportunity').get('New_Classes_Opportunities');
        }
        
        Id opp1Id;
        for(Opportunity opp : oppList){
            if(opp.RecordTypeId == newClassOppRT)
                opp1Id = opp.Id;
        }
        
        
        List<Language__c> langList = new List<Language__c>();
        if(!createdObjNameSet.Contains('Language')){
            langList = createTestLanguages();
            createdObjNameSet.add('Language');
        }
        else{
            langList = [SELECT Id, Name FROM Language__c limit 4];
        }
        
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem> {
        
            new OpportunityLineItem(OpportunityId = opp1Id, PricebookEntryId = priceBookEntryList[0].Id, Quantity = 2, UnitPrice = 200,CLIN_LU__c = clinList[0].Id, Language__c = langList[0].Id),
            new OpportunityLineItem(OpportunityId = opp1Id, PricebookEntryId = priceBookEntryList[1].Id, Quantity = 1, UnitPrice = 200, Language__c = langList[0].Id),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookEntryList[1].Id, Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[0].Id, Language__c = langList[1].Id),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookEntryList[2].Id, Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[0].Id, Language__c = langList[1].Id),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookEntryList[3].Id, Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[0].Id, Language__c = langList[2].Id),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookEntryList[4].Id, Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[0].Id, Language__c = langList[2].Id),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookEntryList[4].Id, Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[0].Id, Language__c = langList[3].Id)
        };
        
        for(Integer i = 2;i < priceBookEntryList.size();i++) {
            if(clinList != null && i-2 < clinList.size()) {
                opliList.add(new OpportunityLineItem(OpportunityId = opp1Id, PricebookEntryId = priceBookEntryList[i].Id, Quantity = 2, UnitPrice = 200,CLIN_LU__c = clinList[i-2].Id, Language__c = langList[3].Id));
            }
        }
        insert opliList;
        return opliList;
    }
    public static testMethod List<Floor_Suite__c> createTestSuite() {
        
        List<Contact> conList = new List<Contact>();
        if(!createdObjNameSet.Contains('Contact')){
            conList = CreateTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        }
        List<Floor_Suite__c> suiteList = new List<Floor_Suite__c>();
        if(conList != null && conList.size() > 0 ){
           suiteList = new List<Floor_Suite__c> {
               new Floor_Suite__c(Name = 'Suite 1' )
           }; 
            
        }
        insert suiteList;
        return suiteList;
    
    }
    public static testMethod List<Room__c> createTestRoom() {
        
        List<Floor_Suite__c> suiteList = new List<Floor_Suite__c>();
        if(!createdObjNameSet.Contains('FloorSuite')){
            suiteList = createTestSuite();
            createdObjNameSet.add('FloorSuite');
        }else{
            suiteList = [SELECT Id, Name FROM Floor_Suite__c LIMIT 1];
        }
        List<MTT_Location__c> locList = new List<MTT_Location__c>();
        if(!createdObjNameSet.Contains('MTTLocation')){
            locList = createTestLocations();
            createdObjNameSet.add('MTTLocation');
        }
        else{
            locList = [SELECT Id, Name, State__c FROM MTT_Location__c LIMIT 1];
        }
        List<Room__c> roomList = new List<Room__c>();
        if(suiteList != null && suiteList.size() > 0 && locList != null && locList.size() > 0){
           roomList = new List<Room__c> {
               new Room__c(Name = 'Room', Floor_Suite__c = suiteList[0].Id, Location_n__c = locList[0].Id, Student_Capacity__c = 1, Room_Location__c = 'Window', Function__c = 'Classroom', Ext__c = '00345 00045', Room_Status__c = 'Active'),
               new Room__c(Name = 'Room 1', Floor_Suite__c = suiteList[0].Id, Location_n__c = locList[0].Id, Student_Capacity__c = 1, Room_Location__c = 'Window', Function__c = 'Classroom', Ext__c = '00345 00045', Room_Status__c = 'Active')
           };             
        }
        if(roomList != null && roomList.size() > 0)
        insert roomList;
        return roomList;
    
    }
    public static testMethod List<Contact_Assignments__c> createTestContactAssignment() {
        
        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        List<User> usrListSample = new List<User>();
        
        if(!createdObjNameSet.Contains('AcctPrjt')){
            projList = createTestProject();
            createdObjNameSet.add('AcctPrjt');
        }else{
            //projList = [SELECT Id, Name, AcctSeed__Status__c,RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 2];
            projList = projectStaticList;
        }
       
        List<OpportunityLineItem> oppList = [SELECT Id, Name,OpportunityId FROM OpportunityLineItem WHERE OpportunityId != :projList[0].AcctSeed__Opportunity__c];
        List<Contact_Assignments__c> conAssign = new List<Contact_Assignments__c>();
        if(!createdObjNameSet.Contains('User')){
            usrListSample = createTestUsers();
            createdObjNameSet.add('User');
        }
        else {
            usrListSample = [SELECT Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, ContactId,
                            TimeZoneSidKey, UserName,Instructor_Access__c, Student_Access__c, Partner_Access__c, Client_Access__c FROM User LIMIT 1];
        }
        
        List<User>  usrList = [SELECT Id,ContactId FROM User WHERE Profile.Name = 'DLS Instructor' AND ContactId != null];
        Id conId, conStdId;
        List<Contact> conList = [SELECT Id, LastName, RecordType.DeveloperName FROM Contact WHERE LastName LIKE 'Testing' OR RecordType.DeveloperName = 'Student'];
        for(Contact con: conList) {
            if(con.LastName == 'Testing')
                conId = con.Id;
            if(con.RecordType.DeveloperName == 'Student')
                conStdId = con.Id;
        }
        
        //Insert Paper Timesheet custom setting
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
        
        Insert sysVal;
        
        if(usrList != null && usrList.size() > 0){
        
            if(projList != null && projList.size() > 0){
                conAssign = new List<Contact_Assignments__c> {
                
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=conStdId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c, Status__c = 'Active'),
                    new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=conStdId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c, Status__c = 'Active')

                };
                if(oppList != null && oppList.size() > 0)
                    conAssign.add(new Contact_Assignments__c(Project__c=projList[0].Id,Candidate_Name__c=usrList[0].ContactId,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = oppList[0].OpportunityId,Status__c = 'Active'));
            }
        }
        
        if(!rtMap.containsKey('Contact_Assignments__c')) {
            rtMap = queryRecordTypes();
        }
        
        if(rtMap.containsKey('Contact_Assignments__c')) {
            for(String recType : rtMap.get('Contact_Assignments__c').keySet()) {
                if(recType == 'Client_Partner') {
                    conAssign[0].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Client_Partner');
                    conAssign[0].Assignment_Position__c = 'Client';
                }
                
                if(recType == 'Instructor') {
                    conAssign[1].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Instructor');
                    conAssign[1].Assignment_Position__c = 'Instructor';
                    conAssign[6].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Instructor');
                    conAssign[6].Assignment_Position__c = 'Instructor';
                    conAssign[10].RecordTypeId= rtMap.get('Contact_Assignments__c').get('Instructor');
                }
                
                if(recType == 'Staff') {
                    conAssign[2].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Staff');
                    conAssign[2].Assignment_Position__c = 'Staff';
                    conAssign[8].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Staff');
                    conAssign[8].Assignment_Position__c = 'Staff';
                }
                
                if(recType == 'Student') {
                    conAssign[3].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Student');
                    conAssign[3].Assignment_Position__c = 'Student';
                    conAssign[9].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Student');
                    conAssign[9].Assignment_Position__c = 'Student';
                }
                
                if(recType == 'Client_Partner') {
                    conAssign[4].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Client_Partner');
                    conAssign[4].Assignment_Position__c = 'COR';
                }
                
                if(recType == 'Client_Partner') {
                    conAssign[5].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Client_Partner');
                    conAssign[5].Assignment_Position__c = 'Billing Contact';
                }
                
                if(recType == 'Consultant') {
                    conAssign[7].RecordTypeId = rtMap.get('Contact_Assignments__c').get('Consultant');
                    conAssign[7].Assignment_Position__c = 'Consultant';
                }
            }
        }           
        insert conAssign;
        contactAssignStaticList = conAssign;
        return conAssign;
    }
    public static testMethod List<Planned_Days_Off__c> createTestPlannedDaysOff() {
    
        List<Contact_Assignments__c> conAssign = new List<Contact_Assignments__c>();
        if(!createdObjNameSet.Contains('Assignment')){
            conAssign = createTestContactAssignment();
            createdObjNameSet.add('Assignment');
        }else{
            //conAssign = [SELECT Id, Project__c, Candidate_Name__c, Start_Date__c, End_Date__c, Opportunity_Name__c, Status__c FROM Contact_Assignments__c LIMIT 10];
            conAssign = contactAssignStaticList;
        }
        List<Planned_Days_Off__c> plannedDaysoffList = new List<Planned_Days_Off__c>();
        Id conId;
        for(Contact_Assignments__c con : conAssign){
            if(con.RecordType.DeveloperName == 'Student' && con.Candidate_Name__r.RecordType.DeveloperName == 'Student')
                conId = con.Candidate_Name__c;
        }
        Id instructorTypeId, studentTypeId, staffTypeId;
       
        if(!rtMap.containsKey('Planned_Days_Off__c')) {
            rtMap = queryRecordTypes();
        }
        
        if(rtMap.containsKey('Planned_Days_Off__c')) {
            if(rtMap.get('Planned_Days_Off__c').containsKey('Instructor_Planned_Days_Off'))
                instructorTypeId = rtMap.get('Planned_Days_Off__c').get('Instructor_Planned_Days_Off');
                
            if(rtMap.get('Planned_Days_Off__c').containsKey('Student_Planned_Days_Off'))
                studentTypeId = rtMap.get('Planned_Days_Off__c').get('Student_Planned_Days_Off');
                
            if(rtMap.get('Planned_Days_Off__c').containsKey('Staff_Planned_Days_Off'))
                staffTypeId = rtMap.get('Planned_Days_Off__c').get('Staff_Planned_Days_Off');
        }
        if(conAssign != null && conAssign.size() > 0){

             plannedDaysoffList.add(new Planned_Days_Off__c(Contact__c = conAssign[0].Candidate_Name__c,Date__c=System.today().addDays(-1),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId=instructorTypeId));
             plannedDaysoffList.add(new Planned_Days_Off__c(Contact__c = conId,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId=studentTypeId));
             plannedDaysoffList.add(new Planned_Days_Off__c(Contact__c = conId,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId=staffTypeId));
        }
        
        insert plannedDaysoffList;
        return plannedDaysoffList;
    
    }
    
    public static testMethod List<AcctSeed__Time_Card_Period__c> createTestTimeCardPeriod() {
        
        date myDate = date.today();
        date weekStart = myDate.toStartofWeek()+1;
        date weekEnd = myDate.toStartofWeek()+7;
        List<AcctSeed__Accounting_Period__c> accPeriod = new List<AcctSeed__Accounting_Period__c>();
        if(!createdObjNameSet.Contains('AcctPeriod')){
            accPeriod = createTestAccountingPeriod();
            createdObjNameSet.add('AcctPeriod');
        }
        else{
            accPeriod = [SELECT Id, Name, AcctSeed__End_Date__c,AcctSeed__Start_Date__c, AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c LIMIT 2];
        }
        List<AcctSeed__Time_Card_Period__c> timeCardPeriod = new List<AcctSeed__Time_Card_Period__c> {
            new AcctSeed__Time_Card_Period__c(Name = myDate.year()+'-'+myDate.Month(),AcctSeed__End_Date__c = weekEnd,AcctSeed__Start_Date__c= weekStart)
        };
        insert timeCardPeriod;
        return timeCardPeriod;
    }
    
    public static testMethod List<AcctSeed__Time_Card__c> createTestTimeCard() {
        List<User> userList = new List<User>();
        List<AcctSeed__Time_Card_Period__c> timeCardPeriod = new List<AcctSeed__Time_Card_Period__c>();
        if(!createdObjNameSet.Contains('User')){
            userList = createTestUsers();
            createdObjNameSet.add('User');
        }
        else{
            userList = [SELECT Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, ContactId,
                            TimeZoneSidKey, UserName,Instructor_Access__c, Student_Access__c, Partner_Access__c, Client_Access__c FROM User LIMIT 1];
        }
                
        if(!createdObjNameSet.Contains('AccountSetting')){
            createAccountSettings();
            createdObjNameSet.add('AccountSetting');
        }
        
        List<AcctSeed__Ledger__c> ledgerList = new List<AcctSeed__Ledger__c>();
        if(!createdObjNameSet.Contains('Ledger')){
            ledgerList = createTestLedger();
            createdObjNameSet.add('Ledger');
        }else{
            ledgerList = [SELECT Id, Name, AcctSeed__Type__c FROM AcctSeed__Ledger__c WHERE AcctSeed__Type__c = 'Transactional' LIMIT 1];
        }
                     
        if(!createdObjNameSet.Contains('AcctTimeCardPeriod')){
            timeCardPeriod = createTestTimeCardPeriod();
            createdObjNameSet.add('AcctTimeCardPeriod');
        }
        else{
            timeCardPeriod = [SELECT Id, Name, AcctSeed__End_Date__c, AcctSeed__Start_Date__c FROM AcctSeed__Time_Card_Period__c LIMIT 2];
        }
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 1];
        List<AcctSeed__Time_Card__c> timeCard = new List<AcctSeed__Time_Card__c> {
            new AcctSeed__Time_Card__c(AcctSeed__Employee__c=userList[0].Id,Intructor__c=conList[0].Id,AcctSeed__Time_Card_Period__c=timeCardPeriod[0].Id, AcctSeed__Ledger__c = ledgerList[0].Id)
        };
        
        insert timeCard;
        return timeCard;
    }
    public static testMethod List<Qualification__c> createTestQualification() {
         
         List<Qualification__c> qualificationList = new List<Qualification__c>{
            new Qualification__c(Condition__c = 'LESS THAN OR EQUAL TO',Type__c = 'Experience',Value__c = '3'),
            new Qualification__c(Condition__c = 'LESS THAN OR EQUAL TO',Type__c = 'Candidate Rating',Value__c = '3'),
            new Qualification__c(Condition__c = 'LESS THAN OR EQUAL TO',Type__c = 'Foreign Language Proficiency',Value__c = '3/3'),
            new Qualification__c(Condition__c = 'LESS THAN OR EQUAL TO',Type__c = 'English Language Proficiency',Value__c = '3/3'),
            new Qualification__c(Condition__c = 'EQUAL TO',Type__c = 'Has Certified Skills',Value__c = 'true'),
            new Qualification__c(Condition__c = 'EQUAL TO',Type__c = 'Degree',Value__c = 'true'),
            new Qualification__c(Condition__c = 'EQUAL TO',Type__c = 'Citizenship / Work Status',Value__c = 'true'),
            new Qualification__c(Condition__c = 'CONTAINS ANY ONE',Type__c = 'Service',Value__c = 'Language Training')
        
        };
        if(qualificationList != null && qualificationList.size() > 0 )
            insert qualificationList;  
        return qualificationList;
    }  
    public static testMethod List<Qualification_Bundle__c> createTestQualificationBundle() {
         
         List<Qualification_Bundle__c> qualificationList = new List<Qualification_Bundle__c>{
            new Qualification_Bundle__c()
        };
        if(qualificationList != null && qualificationList.size() > 0 )
            insert qualificationList;  
        return qualificationList;
    }  
    public static testMethod List<Qualification_Bundle_Item__c> createTestQualificationBundleItem() {
         
         List<Qualification__c> qualificationList = new List<Qualification__c>();
         if(!createdObjNameSet.Contains('Qualification')){
            qualificationList = createTestQualification();
            createdObjNameSet.add('Qualification');
        }
        else{
            qualificationList = [SELECT Id, Condition__c,Type__c FROM Qualification__c LIMIT 8];
        }
         List<Qualification_Bundle__c> qualificationBundleList = new List<Qualification_Bundle__c>();
         if(!createdObjNameSet.Contains('QualifictionBundle')){
            qualificationBundleList = createTestQualificationBundle();
            createdObjNameSet.add('QualifictionBundle');
        }
        else{
            qualificationBundleList = [SELECT Id FROM Qualification_Bundle__c LIMIT 1];
        }
         List<Qualification_Bundle_Item__c> qualificationBundleItemList = new List<Qualification_Bundle_Item__c>();
         
         if(qualificationList != null && qualificationList.size() > 0){
             
             for( Qualification__c qualify : qualificationList){
                 if(qualify.Condition__c == 'LESS THAN OR EQUAL TO' ){
                 
                     if(qualify.Type__c == 'Experience'){
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                     }else if(qualify.Type__c == 'Candidate Rating'){
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                     }else if(qualify.Type__c == 'Foreign Language Proficiency'){
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                     }else if(qualify.Type__c == 'English Language Proficiency'){
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                     }else{
                     
                     }
                     
                 }else if(qualify.Condition__c == 'EQUAL TO'){
                    
                     if(qualify.Type__c == 'Degree'){
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                     }else if(qualify.Type__c == 'Has Certified Skills'){
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                     }else if(qualify.Type__c == 'Citizenship / Work Status'){
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                         qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                     }else{
                     
                     }  
                 
                 }else if(qualify.Condition__c == 'CONTAINS ANY ONE'){
                     
                     qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 10,Prefered_Required__c = 'Prefered'));
                     qualificationBundleItemList.add(new Qualification_Bundle_Item__c(Qualification__c = qualify.Id,Bundle__c = qualificationBundleList[0].Id,Score__c = 5,Prefered_Required__c = 'Required'));
          
                 }else{}
             }
         }
         
        
        if(qualificationBundleItemList != null && qualificationBundleItemList.size() > 0 )
            insert qualificationBundleItemList;  
        return qualificationBundleItemList;
    }  
    public static testMethod List<Schedule__c> createTestSchedule() {
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c>();
        List<OpportunityLineItem> oppLIItem = new List<OpportunityLineItem>();
        if(!createdObjNameSet.Contains('AcctPrjtTask')){
            projTask = createTestProjectTask();
            createdObjNameSet.add('AcctPrjtTask');
        }else{
            projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        }
        if(!createdObjNameSet.Contains('OppLineItem')){
            oppLIItem = createTestOppLineItem();
            createdObjNameSet.add('OppLineItem');
        }else{
            oppLIItem = [SELECT Id, OpportunityId, PricebookEntryId, Quantity, UnitPrice FROM OpportunityLineItem LIMIT 3];
        }
        List<Schedule__c> schedule = new List<Schedule__c>();
        if(oppLIItem != null && oppLIItem.size() > 0)        
        schedule = new List<Schedule__c> {
            new Schedule__c(Name = '15-00687-SH1',Project__c = projTask[0].AcctSeed__Project__c,Project_Task__c=projTask[0].Id, Opportunity__c = oppLIItem[0].OpportunityId, Total_Hours__c = 5,End_Date__c=System.Today() + 10, Start_Date__c=System.Today(),Status__c= 'Drafted'),
            new Schedule__c(Name = '15-00687-SH1',Project__c = projTask[0].AcctSeed__Project__c,Project_Task__c=projTask[0].Id, Opportunity__c = projTask[0].AcctSeed__Project__r.AcctSeed__Opportunity__c, Total_Hours__c = 5,End_Date__c=System.Today() + 10, Start_Date__c=System.Today(),Status__c= 'Drafted'),
            new Schedule__c(Name = 'scheduleWithoutEvent', Project__c = projTask[0].AcctSeed__Project__c, Total_Hours__c = 5, Status__c= 'Active')
            
        };
        
        insert schedule;
        return schedule;
    }
    public static testMethod List<Schedule__c> createTestScheduleWithOpportunity() {
       
        List<Schedule__c> scheduleList = new List<Schedule__c>();
        if(!createdObjNameSet.Contains('Schedule')){
            scheduleList = createTestSchedule();
            createdObjNameSet.add('Schedule');
        }
        else{
            scheduleList = [SELECT Id, Name, Project__c, Project_Task__c, Opportunity__c, Total_Hours__c, End_Date__c, Start_Date__c, Status__c FROM Schedule__c LIMIT 2];
        }
        List<OpportunityLineItem> OppLiList= [SELECT Id, Name, OpportunityId FROM OpportunityLineItem WHERE OpportunityId !=:scheduleList[0].Opportunity__c];
        List<Schedule__c> schedule = new List<Schedule__c>();
        if(scheduleList != null && scheduleList.size() > 0)        
        schedule = new List<Schedule__c> {
            new Schedule__c(Name = '15-00687-SH1',Opportunity__c = OppLiList[0].OpportunityId, Total_Hours__c = 5,End_Date__c=System.Today() + 10, Start_Date__c=System.Today(),Status__c= 'Drafted'),
            new Schedule__c(Name = '15-00687-SH1',Opportunity__c = OppLiList[0].OpportunityId, Total_Hours__c = 5,End_Date__c=System.Today() + 10, Start_Date__c=System.Today(),Status__c= 'Drafted')
        
        };
        if(schedule != null && schedule.size() > 0)
            System.debug('$$$schedule$$$'+schedule);
            insert schedule;
        return schedule;
    }
    
    public static testMethod List<Events__c> createTestEvent() {
        List<Schedule__c> schListSample = new List<Schedule__c>();
        List<Contact> conList = new List<Contact>();
        if(!createdObjNameSet.Contains('ScheduleWithOpp')){
            schListSample = createTestScheduleWithOpportunity();
            createdObjNameSet.add('ScheduleWithOpp');
        }
        else{
            schListSample = [SELECT Id, Name, Opportunity__c, Total_Hours__c, End_Date__c, Start_Date__c, Status__c FROM Schedule__c LIMIT 2];
        }
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        }
        List<Events__c> event = new List<Events__c>();
        List<Schedule__c> schList = [SELECT Id, Name,Project__c, Project__r.Project_Manager__c FROM Schedule__c WHERE Project__r.Project_Manager__c != null LIMIT 2];
        if(conList != null && conList.size() > 1 && schList != null && schList.size() > 0){
            event = new List<Events__c> {
                new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[1].Id,Date__c = system.today().addDays(-1),Project__c = schList[0].Project__c,Status__c = 'Completed',Duration__c = 2),
                new Events__c(Name = '15-00687-SH1-EV2',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = system.today().addDays(-1),Project__c = schList[0].Project__c,Status__c = 'Scheduled',Duration__c = 2),
                new Events__c(Name = '15-00687-SH1-EV3',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = system.today(),Project__c = schList[0].Project__c,Status__c = 'Scheduled',Duration__c = 2)
            };
        }
        List<Contact> conList1 = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        schList = [SELECT Id, Name,Project__c FROM Schedule__c WHERE Project__c = null];
        
        if(conList1 != null && conList1.size() > 0  && schList != null && schList.size() > 1){
            event.addall(new List<Events__c> {
                new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList1[0].Id,Date__c = system.today().addDays(-1),Status__c = 'Completed',Duration__c = 2),
                new Events__c(Name = '15-00687-SH1-EV2',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList1[0].Id,Date__c = system.today().addDays(-2),Status__c = 'Scheduled',Duration__c = 2),
                new Events__c(Name = '15-00687-SH1-EV3',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList1[0].Id,Date__c = system.today(),Status__c = 'Scheduled',Duration__c = 2),
                new Events__c(Name = '15-00687-SH1-EV4',Schedule__c = schList[1].Id,SequenceNo__c = 1,Instructor__c = conList1[0].Id,Date__c = system.today().addDays(-3),Status__c = 'Scheduled',Duration__c = 2)
            });
        }
        if(event != null && event.size() > 0)
            insert event;
        return event;
    }
    public static testMethod List<Attendance__c> createTestAttendance() {
        
        List<Events__c> eventList = new List<Events__c>();
        if(!createdObjNameSet.Contains('Event')){
            eventList = createTestEvent();
            createdObjNameSet.add('Event');
        }
        else{
            eventList = [SELECT Id, Name, Schedule__c, schedule__r.Project_Task__c FROM Events__c];
        }
        List<Attendance__c> attendList = new List<Attendance__c> {
                                            new Attendance__c(Event__c = eventList[0].Id /*,Contact__c =  eventList[0].Instructor__c*/)
        
        };
        insert attendList;
        return attendList;
        
    }
    
    public static testMethod List<AcctSeed__Time_Card_Line__c> createTestTimeCardLine() {
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c>();
        List<AcctSeed__Time_Card__c> timeCard = new List<AcctSeed__Time_Card__c>();
        
        if(!createdObjNameSet.Contains('AcctTimeCard')){
            timeCard = createTestTimeCard();
            createdObjNameSet.add('AcctTimeCard');
        }
        else{
            timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c LIMIT 2];
        }
        if(!createdObjNameSet.Contains('AcctPrjtTask')){
            projTask = createTestProjectTask();
            createdObjNameSet.add('AcctPrjtTask');
        }else{
            projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        }
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
        List<Events__c> eventList1 = [SELECT Id, Name, Schedule__c, schedule__r.Project_Task__c FROM Events__c WHERE schedule__r.Project_Task__c != null];
       
        timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
            new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = projTask[0].Id, AcctSeed__Project__c = projTask[0].AcctSeed__Project__c, Payroll_Item__c = 'R'),
            new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = projTask[0].Id, AcctSeed__Project__c = projTask[0].AcctSeed__Project__c, Payroll_Item__c = 'R')                
        };
        
        insert timeCardLine;
        return timeCardLine;
    }
    
    public static testMethod List<AcctSeed__Time_Card_Day__c> createTestTimeCardDay() {
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
        
        if(!createdObjNameSet.Contains('AcctTimeCardLine')){
            timeCardLine = createTestTimeCardLine();
            createdObjNameSet.add('AcctTimeCardLine');
        }
        else{
            timeCardLine = [SELECT Id, AcctSeed__Time_Card__c, AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];
        }
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c>();
        
        timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Start_Time1__c = '08:00 AM',End_Time1__c = '10:00 AM',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today(),Status__c = 'Approved'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Start_Time1__c = '10:00 AM',End_Time1__c = '11:00 AM',Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(-1),Status__c = 'Approved'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Start_Time1__c = '09:00 AM',End_Time1__c = '12:00 AM',Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(-2),Status__c = 'Approved')
        };
        
        insert timeCardDay;
        return timeCardDay;
        
    }
    public static testMethod List<Assessment_Report__c> createTestAssessmentReport() {
    
        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        List<Contact> conList = new List<Contact>();       
        List<Assessment_Report__c> assessReport = new List<Assessment_Report__c>();
        if(!rtMap.containsKey('Assessment_Report__c')) {
            rtMap = queryRecordTypes();
        }
        if(!createdObjNameSet.Contains('AcctPrjt')){
            projList = createTestProject();
            createdObjNameSet.add('AcctPrjt');
        }else{
            //projList = [SELECT Id, Name, AcctSeed__Status__c,RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 2];
            projList = projectStaticList;
        }
        
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 2];
        } 
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        if(projList != null && projList.size() > 0){
            assessReport = new List<Assessment_Report__c> {
                new Assessment_Report__c(Name = 'Test Report1',Project__c=projList[0].Id,Report_Type__c = 'DLI',RecordTypeId=rtMap.get('Assessment_Report__c').get('DLI_W_Progress'), Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = conList[0].Id,Instructor__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10),
                new Assessment_Report__c(Name = 'Test Report2',Project__c=projList[0].Id,Report_Type__c = 'DLI',RecordTypeId=rtMap.get('Assessment_Report__c').get('DLI_W_Progress'), Status__c = 'Scheduled',Language__c = 'English',Student__c = conList[0].Id,Instructor__c = conList[1].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+20),
                new Assessment_Report__c(Name = 'LTReport',Project__c=projList[0].Id,RecordTypeId =rtMap.get('Assessment_Report__c').get('Language_Training_Progress') , Status__c = 'Scheduled',Instructor__c = conList[1].Id),
                new Assessment_Report__c(Name = 'TestReport',Project__c=projList[0].Id,RecordTypeId =rtMap.get('Assessment_Report__c').get('Test_Report') , Status__c = 'Scheduled',Instructor__c = conList[1].Id),
                new Assessment_Report__c(Name = 'ObservationReport',Project__c=projList[0].Id,RecordTypeId =rtMap.get('Assessment_Report__c').get('Observation_Report') , Status__c = 'Scheduled',Instructor__c = conList[1].Id)
            };
        }
        
        insert assessReport;        
        return assessReport;
    }
    public static testMethod List<Test_Score__c> createTestscore() {
    
        List<Assessment_Report__c> assessReport = new List<Assessment_Report__c>();
        if(!createdObjNameSet.Contains('Report')){
            assessReport = createTestAssessmentReport();
            createdObjNameSet.add('Report');
        }
        else{
            assessReport = [SELECT Id, Name, Project__c, Report_Type__c, Status__c, Language__c, Student__c, Training_officer__c, Sponser__c, Evaluation_Period_From__c, Evaluation_Period_To__c FROM Assessment_Report__c LIMIT 2];
        }
        List<Test_Score__c> testScoreList = new List<Test_Score__c>();
        if(assessReport != null && assessReport.size() > 0)
        testScoreList = new List<Test_Score__c> {
               new Test_Score__c(Assessment_Report__c = assessReport[0].Id)
        };
        
        insert testScoreList;
        return testScoreList;
    }
    public static testMethod List<Action_Plan__c> createTestActionPlan() {
    
        List<Test_Score__c> assessReport = new List<Test_Score__c>();
        if(!createdObjNameSet.Contains('TestScore')){
            assessReport = createTestscore();
            createdObjNameSet.add('TestScore');
        }
        else{
            assessReport = [SELECT Id, Assessment_Report__c FROM Test_Score__c LIMIT 1];
        }
        List<Action_Plan__c> actionPlanList = new List<Action_Plan__c>();
        if(assessReport != null && assessReport.size() > 0)
        actionPlanList = new List<Action_Plan__c> {
               new Action_Plan__c(Assessment_Report__c = assessReport[0].Assessment_Report__c)
        };
        
        insert actionPlanList;
        return actionPlanList;
    }
    
    public static testMethod List<Holiday> createTestHoliday() {
        List<Holiday> hol = new List<Holiday>{new Holiday(Name='Test holiday',activitydate = System.Today()),
                   new Holiday(Name='Test holiday1',activitydate = System.Today().addDays(-1)),
                   new Holiday(Name='Test holiday1',activitydate = System.Today().toStartOfMonth().addDays(1)),
                   new Holiday(Name='Test holiday2',activitydate = System.Today().toStartOfMonth())
        };
        
        insert hol;
        return hol;
    }
    
    public static testMethod List<CLIN__c> createTestClin() {
        
        List<Contract> contrList = new List<Contract>();
        if(!createdObjNameSet.Contains('Contract')){
            contrList = createTestContracts();
            createdObjNameSet.add('Contract');
        }else{
            contrList = [SELECT Id,RecordTypeId, AccountId, Status, StartDate, Billing_Contact__c, Primary_POC__c FROM Contract LIMIT 2];
        }
        List<CLIN__c> clinList = new List<CLIN__c> {
                                            new CLIN__c(Contract__c = contrList[0].Id, CLIN_Name__c = '2',Name= '2a'),
                                            new CLIN__c(Contract__c = contrList[0].Id, CLIN_Name__c = '1',Name= '1a'),
                                            new CLIN__c(Contract__c = contrList[1].Id, CLIN_Name__c = '3',Name= '3a')
        };
        insert clinList;
        return clinList;
        
    }
    
    //Created by Karthiga on Feb 10, 2017
    public static testMethod List<Task_Order__c> createTaskOrder() {
        
        List<Account> acctList = new List<Account>();
        if(!createdObjNameSet.Contains('Account')){
            acctList = createTestAccounts();
            createdObjNameSet.add('Account');
        }else{
            //acctList = [SELECT Id,Name FROM Account LIMIT 2];
            acctList = accountStaticList;
        }
        List<Task_Order__c> toList = new List<Task_Order__c> {
                                            new Task_Order__c(Account__c = acctList[0].Id, Start_Date__c = system.today(), End_Date__c = system.today().addDays(20),Name= 'Test 1 TO'),
                                            new Task_Order__c(Account__c = acctList[0].Id, Start_Date__c = system.today(), End_Date__c = system.today().addDays(30),Name= 'Test 2 TO')
        };
        insert toList;
        return toList;
        
    }
    
    public static testMethod List<Case> createTestCase() {
   
        List<Case> caseList = new List<Case> {
                                        new Case (SuppliedEmail = 'test@test.com', Subject = 'Missing TimeLog Entry', Priority ='High', Description ='text case document', Status ='New'),
                                        new Case (SuppliedEmail = 'test1@test.com', Subject = 'Missing TimeLog Entry',Priority ='High',Description ='text case document1', Status ='New') };
        createdObjNameSet.add('Case');
        insert caseList;
        return caseList;
    }
    
    public static testMethod List<Attachment> createTestAttachment() {
        
        List<Opportunity> oppList = new List<Opportunity>();
        if(!createdObjNameSet.Contains('Opportunity')){
            oppList = createTestOpportunities();
            createdObjNameSet.add('Opportunity');
        }else{
            //oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
            oppList = oppStaticList;
        }
        List<Attachment> AttachmentList = new List<Attachment> {
                                        new Attachment (Name = 'testTimeline', Body = Blob.valueof('Test'), ParentId =oppList[0].Id),
                                        new Attachment (Name = 'test1Timeline', Body = Blob.valueof('Test1'), ParentId =oppList[0].Id) };
        createdObjNameSet.add('Attachment');
        insert AttachmentList;
        return AttachmentList;
    }

    public static testMethod List<Labor_Cost_Rate_Master__c> createTestCostRatesMaster() {
        List<Labor_Cost_Rate_Master__c> CostRateMasterList = new List<Labor_Cost_Rate_Master__c> {
                                                             new Labor_Cost_Rate_Master__c(Name = 'LT with Prep', Exempt_Status__c = 'Non-Exempt', Pay_frequency__c = 'Semi-Monthly', Payroll_Item__c = 'R', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep', Tax_Type__c = 'W-2', Rate_Type_Label__c = 'Language Training', Non_Billable_Payroll_Item__c = 'RNB', 
                                                             Position__c = 'Language Trainer'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'LT without Prep', Exempt_Status__c = 'Non-Exempt', Pay_frequency__c = 'Semi-Monthly', Payroll_Item__c = 'RT5', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT without Prep', Tax_Type__c = 'W-2', Rate_Type_Label__c = 'Language Training', Non_Billable_Payroll_Item__c = 'RNB', 
                                                             Position__c = 'Language Trainer'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'Non-SCA LT', Exempt_Status__c = 'Non-Exempt', Pay_frequency__c = 'Semi-Monthly', Payroll_Item__c = 'R', Pay_Type__c = 'Hourly', Rate_Type__c = 'Non-SCA LT', Tax_Type__c = 'W-2', Rate_Type_Label__c = 'Language Training', Non_Billable_Payroll_Item__c = 'RNB', 
                                                             Position__c = 'Language Trainer'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'International Salary', Exempt_Status__c = 'Exempt', Pay_frequency__c = 'Monthly', Payroll_Item__c = 'R', Pay_Type__c = 'Salary', Rate_Type__c = 'International Salary', Tax_Type__c = 'W-2', Rate_Type_Label__c = 'International Salary', Non_Billable_Payroll_Item__c = 'RNB'), 
                                                             new Labor_Cost_Rate_Master__c(Name = 'Non-SCA Testing', Exempt_Status__c = 'Non-Exempt', Pay_frequency__c = 'Semi-Monthly', Payroll_Item__c = 'R', Pay_Type__c = 'Testing', Rate_Type__c = 'Non-SCA Testing', Tax_Type__c = 'W-2', Rate_Type_Label__c = 'Language Testing', Non_Billable_Payroll_Item__c = 'RNB', 
                                                             Position__c = 'Language Tester'),
                                                             /*commented since this rate is splitted into 3 types new Labor_Cost_Rate_Master__c(Name = 'Non-SCA Translation (Per Word)', Exempt_Status__c = 'Non-Exempt', Pay_frequency__c = 'Invoice Terms', Payroll_Item__c = '1099', Pay_Type__c = 'Word', Rate_Type__c = 'Non-SCA Translation (Per Word)', Tax_Type__c = '1099', Rate_Type_Label__c = 'Translation (Per Word)', Position__c = 'Translator'), */                                                                                    
                                                             new Labor_Cost_Rate_Master__c(Name = 'Non-SCA Translation (Per Hour)',Exempt_Status__c = 'Exempt', Pay_frequency__c = 'Invoice Terms',Payroll_Item__c = 'R',Pay_Type__c = 'Hourly', Rate_Type__c = 'Non-SCA Translation (Per Hour)', Tax_Type__c = '1099', Rate_Type_Label__c = 'Translation (Per Hour)',Non_Billable_Payroll_Item__c = 'RNB',Position__c = 'Translator'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'Non-SCA Translation (FFP)',Exempt_Status__c = 'Non-Exempt', Pay_frequency__c = 'Invoice Terms',Payroll_Item__c = 'R',Pay_Type__c = 'FFP', Rate_Type__c = 'Non-SCA Translation (FFP)', Tax_Type__c = '1099', Rate_Type_Label__c = 'Translation (Fixed Price)',Non_Billable_Payroll_Item__c = 'RNB',Position__c = 'Translator'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'Non-SCA Translation W/O Editing',Exempt_Status__c = 'Exempt', Pay_frequency__c = 'Invoice Terms',Payroll_Item__c = 'R',Pay_Type__c = 'Word', Rate_Type__c = 'Non-SCA Translation W/O Editing (Per Word)', Tax_Type__c = '1099', Rate_Type_Label__c = 'Translation (Per Word)',Non_Billable_Payroll_Item__c = 'RNB',Position__c = 'Translator'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'SubK-LT', Exempt_Status__c = 'Exempt', Pay_frequency__c = 'Monthly', Payroll_Item__c = 'R', Pay_Type__c = 'Hourly', Rate_Type__c = 'SubK-LT', Tax_Type__c = 'W-2', Rate_Type_Label__c = 'SubK-LT', Non_Billable_Payroll_Item__c = 'RNB'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'DLI-21 SCA LT', Exempt_Status__c = 'Non-Exempt',  Payroll_Item__c = 'RT2', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT', Rate_Type_Label__c = 'Language Training', Non_Billable_Payroll_Item__c = 'RNB', 
                                                             Position__c = 'Language Trainer',H_W_Rate__c = 4.54,HOL_Rate__c=0),
                                                             new Labor_Cost_Rate_Master__c(Name = 'DLI-21 SCA CD', Exempt_Status__c = 'Non-Exempt',  Payroll_Item__c = 'RT2', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA CD', Rate_Type_Label__c = 'DLI-W OY4 (SCA) Curriculum Development', Non_Billable_Payroll_Item__c = 'RNB', 
                                                             Position__c = 'Language Trainer', H_W_Rate__c = 4.54,HOL_Rate__c=0, VAC_Rate__c = 0),
                                                             new Labor_Cost_Rate_Master__c(Name = 'DLI-21 SCA MTT', Exempt_Status__c = 'Non-Exempt',  Payroll_Item__c = 'RT2', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA MTT', Rate_Type_Label__c = 'DLI-W OY4 (SCA) Mobile Training Teams', Non_Billable_Payroll_Item__c = 'RNB', 
                                                             Position__c = 'Language Trainer'),
                                                             new Labor_Cost_Rate_Master__c(Name = 'FT Salary & Benefits', Exempt_Status__c = 'Exempt', Pay_frequency__c = 'Semi-Monthly', Payroll_Item__c = 'R', Pay_Type__c = 'Salary', Rate_Type__c = 'FT Salary & Benefits', Tax_Type__c = 'W-2', Rate_Type_Label__c = 'Full-time Salary & Benefits', Non_Billable_Payroll_Item__c = 'RNB')
                                                            };
        
        insert CostRateMasterList;
        return CostRateMasterList;
    }
    
    public static testMethod List<Equipment__c> createTestEquipment() {
       
       if(!rtMap.containsKey('Equipment__c')) {
            rtMap = queryRecordTypes();
        }
       
        List<Equipment__c> EquipList = new List<Equipment__c> {
                                           new Equipment__c(Name = 'TestEquipment 1', RecordTypeId = rtMap.get('Equipment__c').get('Access_Card')) /*EquipRTList[0].Id*/
                                       };
        insert EquipList;  
        return EquipList;   
    }
    
    public static testMethod List<Equipment_Assignment__c> createTestEquipmentAssignment() {
      
        List<Equipment__c> EquiList = new List<Equipment__c>();
       
        if(!createdObjNameSet.Contains('Equipment')){
            EquiList = createTestEquipment();
            createdObjNameSet.add('Equipment');
        }else{
            EquiList = [SELECT Id,RecordTypeId FROM Equipment__c LIMIT 3];
        } 
        
        List<Equipment_Assignment__c> EquipAssignList = new List<Equipment_Assignment__c> {
                                                           new Equipment_Assignment__c(Equipment__c = EquiList[0].Id, Stage__c = 'Active'),
                                                           new Equipment_Assignment__c(Equipment__c = EquiList[0].Id, Stage__c = 'Planned')
                                                        };
        insert EquipAssignList;
        return EquipAssignList;     
    }
    
    public static testMethod List<AcctSeed__Cost_Rates__c> createTestCostRates() {
        
        List<Contact> conList = new List<Contact>();
        if(!createdObjNameSet.Contains('Contact')){
            conList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            conList = [SELECT Id,LastName, Email, MailingPostalCode, AccountId, Geo_Code_Status__c  FROM Contact LIMIT 4];
        }
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 22,Status__c = 'Approved', Payroll_Item__c = 'R'),
            new AcctSeed__Cost_Rates__c(Contact__c = conList[1].Id, Pay_Type__c = 'Salary', AcctSeed__Hourly_Cost__c = 22 , Status__c = 'Draft',Payroll_Item__c='ADM'),
            new AcctSeed__Cost_Rates__c(Pay_Type__c = 'Salary', Rate_Type__c = 'Non-SCA Testing',AcctSeed__Hourly_Cost__c = 22, Per_Test_Cost__c = 1, Status__c = 'Approved',Payroll_Item__c='P'),
            new AcctSeed__Cost_Rates__c(Contact__c = conList[1].Id, Annual_Salary_Cost__c = 5500, Salary_Cost_Per_Hour__c = 20, Pay_Type__c = 'Salary', Rate_Type__c = 'FT Salary & Benefits', AcctSeed__Hourly_Cost__c = 22 , Status__c = 'Approved',Payroll_Item__c='ADM'),
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Rate_Type__c = 'Non-SCA Translation (Per Hour)',AcctSeed__Hourly_Cost__c = 22,Status__c = 'Approved', Payroll_Item__c = 'R'),
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Rate_Type__c = 'Non-SCA Interpretation (Per Hour)',AcctSeed__Hourly_Cost__c = 22,Status__c = 'Approved', Payroll_Item__c = 'R'),
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Rate_Type__c = 'Non-SCA Translation W/O Editing (Per Word)',Per_Word_Cost__c=0.11,Status__c = 'Approved', Payroll_Item__c = 'R')
        };
        createdObjNameSet.add('AcctSeed__Cost_Rates__c');
        
        insert costrateList;
        return costrateList;
    }
    
    public static testMethod List<System_Values__c> createSystemValues() {
        List<System_Values__c> sysValuesList = new List<System_Values__c> {
                                                    new System_Values__c(Name = 'Contract Modified Notify Users', Value__c = 'karthiga@softsquare.biz,sukanyan@softsquare.biz,nixon@softsquare.biz'),
                                                    new System_Values__c(Name ='Opp QB type - COMM:INDV Acct', Value__c = 'PVT'),
                                                    new System_Values__c(Name ='OH Applied - DLS-Site', Value__c = '45'),
                                                    new System_Values__c(Name ='OH Applied - Non-DLS-Site', Value__c = '13.79'),
                                                    new System_Values__c(Name ='GA Applied - Non-ICJ', Value__c = '13'),
                                                    new System_Values__c(Name ='EESC Applied', Value__c = '2'),
                                                    new System_Values__c(Name ='Enable Schedule Delete Validation', Value__c = 'TRUE'),
                                                    new System_Values__c(Name ='DODA CLIN for LT & Prep Time PTs', Value__c = '00010- (BY)'),
                                                    new System_Values__c(Name ='DODA CLIN for Material PTs', Value__c = '00020- (BY)'),
                                                    new System_Values__c(Name ='GSA Fee Percentage', Value__c = '0.75'),
                                                    new System_Values__c(Name ='Suspend Moodle User Batch Size', Value__c = '1'),
                                                    new System_Values__c(Name ='Moodle Last Access Days for Suspend', Value__c = '90'),
                                                    new System_Values__c(Name ='Moodle Last Access Days_Student', Value__c = '730'),
                                                    new System_Values__c(Name ='User Creation Exception Mails', Value__c = 'sukanyan@softsquare.biz'),
                                                    new System_Values__c(Name ='Schedule Update Notify Mail', Value__c = 'sukanyan@softsquare.biz'),
                                                    new System_Values__c(Name ='Cancel Orientation for New Hire', Value__c = 'sukanyan@softsquare.biz'),
                                                    new System_Values__c(Name ='Student CA Transfer Email', Value__c = 'sukanyan@softsquare.biz'),
                                                    new System_Values__c(Name ='Student CA Transfer Email User Name', Value__c = 'Sukanya')
                                              };
       List<OrgWideEmailAddress> orgAddress = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address LIKE '%timesheets%'];
       
       sysValuesList.add(new System_Values__c(Name ='Timesheet', Value__c = orgAddress[0].Id));
       sysValuesList.add(new System_Values__c(Name ='Contact Bounced Exception Email Ids', Value__c = 'sukanyan@softsquare.biz'));
        
        insert sysValuesList;
        return sysValuesList;
    }
    
    public static testMethod List<PriceBook2> createTestPriceBook2() {
        List<PriceBook2> pb = new List<PriceBook2> {
                                  new PriceBook2(Name = 'GSA Language Training Price Book', IsActive = True),
                                  new PriceBook2(Name = 'GSA Translation Price Book', IsActive = True),
                                  new PriceBook2(Name = 'PriceBook1', IsActive = True)
                              };
        insert pb;
        return pb;
                        
    }
    
    //Added by Sangeetha G on June 13 2018 for Inventory_Purchase__c record creation
    public static testMethod List<Inventory_Purchase__c> createInventoryPurchase() {
        
        List<MTT_Location__c> locList = new List<MTT_Location__c>();
        List<Account> getAccList = new List<Account>();
        
        if( !createdObjNameSet.Contains('MTTLocation') ) {
            locList = createTestLocations();
            createdObjNameSet.add('MTTLocation');
        } else {
            locList = [SELECT Id, Name, State__c FROM MTT_Location__c LIMIT 1];
        }
        
        
        if( !createdObjNameSet.Contains('Account') ) {
            getAccList = createTestAccounts();
            createdObjNameSet.add('Account');
        } else {
            getAccList = accountStaticList;
        }
        
        List<Inventory_Purchase__c> ipList = new List<Inventory_Purchase__c> {
                                                    new Inventory_Purchase__c(Location__c = locList[0].Id, Vendor__c = accountStaticList[0].Id ),
                                                    new Inventory_Purchase__c(Location__c = locList[0].Id, Vendor__c = accountStaticList[0].Id )
        };
        
        insert ipList;
        return ipList;
    }
    
    public static testMethod List<Materials_Stock__c> createMaterialsStock() {
        
        List<Materials__c> MaterialsList = new List<Materials__c>();
        List<MTT_Location__c> locList = new List<MTT_Location__c>();
        
        if( !createdObjNameSet.Contains('Materials') ) {
            
            MaterialsList = createTestmaterials();
            createdObjNameSet.add('Materials');
        } else {
            MaterialsList = [SELECT Id, Name FROM Materials__c LIMIT 2];
        }
        
        if( !createdObjNameSet.Contains('MTTLocation') ) {
            locList = createTestLocations();
            createdObjNameSet.add('MTTLocation');
        } else {
            locList = [SELECT Id, Name, State__c FROM MTT_Location__c LIMIT 2];
        }
        
        List<Materials_Stock__c> msList = new List<Materials_Stock__c> {
                                                new Materials_Stock__c( Materials__c = MaterialsList[0].Id, Location__c = locList[0].Id ),
                                                new Materials_Stock__c( Materials__c = MaterialsList[0].Id, Location__c = locList[1].Id )
        };
        insert msList;
        system.debug('msList::::::::::::::::::::::'+msList);
        
        return null;
    }
    
    // To insert the fixed asset - start
    public static testMethod List<AcctSeed__Billing_Format__c> createBillingFormat() {
        List<AcctSeed__Billing_Format__c> billFormatList = new List<AcctSeed__Billing_Format__c> {
            new AcctSeed__Billing_Format__c(Name = 'Test pdf1',AcctSeed__Visualforce_PDF_Page__c = 'ConvertToProject', AcctSeed__Default_Email_Template__c = 'Billing_Email_Template', AcctSeed__Type__c = 'Activity Statement'),
            new AcctSeed__Billing_Format__c(Name = 'Test pdf2',AcctSeed__Visualforce_PDF_Page__c = 'ConvertToProject', AcctSeed__Default_Email_Template__c = 'Billing_Email_Template', AcctSeed__Type__c = 'Outstanding Statement'),
            new AcctSeed__Billing_Format__c(Name = 'Test pdf2',AcctSeed__Visualforce_PDF_Page__c = 'ConvertToProject', AcctSeed__Default_Email_Template__c = 'Billing_Email_Template', AcctSeed__Type__c = 'Billing'),
            new AcctSeed__Billing_Format__c(Name = 'Test pdf2',AcctSeed__Visualforce_PDF_Page__c = 'ConvertToProject', AcctSeed__Default_Email_Template__c = 'Billing_Email_Template', AcctSeed__Type__c = 'Packing Slip'),
            new AcctSeed__Billing_Format__c(Name = 'Test pdf2',AcctSeed__Visualforce_PDF_Page__c = 'ConvertToProject', AcctSeed__Default_Email_Template__c = 'Billing_Email_Template', AcctSeed__Type__c = 'Purchase Order')
        };
        insert billFormatList;
        return billFormatList;
    }
    
    public static testMethod List<AcctSeed__Ledger__c> createTestLedger() {
        
        List<AcctSeed__GL_Account__c> glAccount = new List<AcctSeed__GL_Account__c>();
        if(!createdObjNameSet.Contains('GLAcct')){
            glAccount = createTestGLAccount();
            createdObjNameSet.add('GLAcct');
        }else{
            glAccount = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 2];
        }
        
        List<AcctSeed__Billing_Format__c> billFormatList = new List<AcctSeed__Billing_Format__c>();
        if(!createdObjNameSet.Contains('BillFormat')){
            billFormatList = createBillingFormat();
            createdObjNameSet.add('BillFormat');
        }
        else{
            billFormatList = [SELECT Id, Name, AcctSeed__Type__c, AcctSeed__Visualforce_PDF_Page__c, AcctSeed__Default_Email_Template__c FROM AcctSeed__Billing_Format__c LIMIT 5];
        }
        
        Id pdfActiveId, pdfOutId, pdfBillId, pdfPackingSlipId, pdfPurchaseId;
        
        for(AcctSeed__Billing_Format__c billFor : billFormatList) {
            if(billFor.AcctSeed__Type__c == 'Activity Statement') pdfActiveId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Outstanding Statement') pdfOutId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Billing') pdfBillId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Packing Slip') pdfPackingSlipId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Purchase Order') pdfPurchaseId = billFor.Id;
        }
        
        glAccount[0].AcctSeed__Bank__c = true;
        update glAccount;
        
        List<AcctSeed__Ledger__c> LedgerList = new list<AcctSeed__Ledger__c> {
            new AcctSeed__Ledger__c(Name = 'Actual', AcctSeed__Type__c = 'Transactional', AcctSeed__Billing_Activity_Statement_Format__c = pdfActiveId, AcctSeed__Billing_Outstanding_Statement_Format__c = pdfOutId, 
                                    AcctSeed__Default_Bank_Account__c = glAccount[0].Id, AcctSeed__Default_Billing_Format__c = pdfBillId, AcctSeed__Default_Packing_Slip_Format__c = pdfPackingSlipId, AcctSeed__Default_Purchase_Order_Format__c = pdfPurchaseId)
        };
        insert LedgerList;
        return LedgerList;
    }
    
    public static testMethod List<AcctSeed__Fixed_Asset__c> createFixedAsset() {
        
        List<AcctSeed__Ledger__c> ledgerList = new List<AcctSeed__Ledger__c>();
        if(!createdObjNameSet.Contains('Ledger')){
            LedgerList = createTestLedger();
            createdObjNameSet.add('Ledger');
        }else{
            LedgerList = [SELECT Id, Name FROM AcctSeed__Ledger__c LIMIT 2];
        }
        
        if(!rtMap.containsKey('AcctSeed__Fixed_Asset__c')) {
            rtMap = queryRecordTypes();
        }
        
        Id leaseRtId, comEqRtId;
        if(rtMap.containsKey('AcctSeed__Fixed_Asset__c') && rtMap.get('AcctSeed__Fixed_Asset__c').containsKey('Leasehold_Improvements') 
           && rtMap.get('AcctSeed__Fixed_Asset__c').containsKey('Computer_Equipment')) {
            leaseRtId = rtMap.get('AcctSeed__Fixed_Asset__c').get('Leasehold_Improvements');
            comEqRtId = rtMap.get('AcctSeed__Fixed_Asset__c').get('Computer_Equipment');
        }

        List<AcctSeed__Fixed_Asset__c> fixedAssetList = new List<AcctSeed__Fixed_Asset__c> {
            new AcctSeed__Fixed_Asset__c(Name = 'Test FixedAsset', AcctSeed__Value__c = 20.5, AcctSeed__Ledger__c = LedgerList[0].Id, RecordTypeId = comEqRtId, Accumulated_Depreciation__c = 5.2),
            new AcctSeed__Fixed_Asset__c(Name = 'Test FixedAsset', AcctSeed__Value__c = 20.5, AcctSeed__Ledger__c = LedgerList[0].Id, RecordTypeId = leaseRtId, Accumulated_Depreciation__c = 5.2)
        };
        insert fixedAssetList;
        return fixedAssetList;
    }
    // To insert the fixes asset - end
    
    // Sobject Master Field Mapping
    public static testMethod List<Sobject_Master_Field_Mapping__c> createSobjMasterFieldMap() {
    
        List<Sobject_Master_Field_Mapping__c> masterFieldMappingList = new List<Sobject_Master_Field_Mapping__c> {
            new Sobject_Master_Field_Mapping__c(Name = 'FA-monthofDepr', Field_Name__c = 'of_Months_Depreciation__c', Object_Name__c = 'AcctSeed__Fixed_Asset__c', RecordType_Name__c = 'Computer_Equipment', Default_Field_Value__c = '20'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-CreditGLAcc', Field_Name__c = 'AcctSeed__Credit_GL_Account__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = '15950'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-DebitGLAcc', Field_Name__c = 'AcctSeed__Debit_GL_Account__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = '81370'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-DebitElkGLAcc', Field_Name__c = 'AcctSeed__Debit_GL_Account__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = '75275'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-DebitHerGLAcc', Field_Name__c = 'AcctSeed__Debit_GL_Account__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = '75475'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-DebitRossGLAcc', Field_Name__c = 'AcctSeed__Debit_GL_Account__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = '75175'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-ElkGLAccVar', Field_Name__c = 'AcctSeed__GL_Account_Variable_1__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = 'FSC0MD'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-HerGLAccVar', Field_Name__c = 'AcctSeed__GL_Account_Variable_1__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = 'FSC0HRN'),
            new Sobject_Master_Field_Mapping__c(Name = 'AE-RossGLAccVar', Field_Name__c = 'AcctSeed__GL_Account_Variable_1__c', Object_Name__c = 'AcctSeed__Scheduled_Revenue_Expense__c', Default_Field_Value__c = 'FSC0ARL')
        };
        insert masterFieldMappingList;
        return masterFieldMappingList;
    }
    
    // Accounting Variable
    public static testMethod List<AcctSeed__Accounting_Variable__c> createAccountingVariable() {
        List<AcctSeed__Accounting_Variable__c> accVarList = new List<AcctSeed__Accounting_Variable__c> {
            new AcctSeed__Accounting_Variable__c(Name = 'FSC0MD', AcctSeed__Type__c = 'GL Account Variable 1'),
            new AcctSeed__Accounting_Variable__c(Name = 'FSC0HRN', AcctSeed__Type__c = 'GL Account Variable 1'),
            new AcctSeed__Accounting_Variable__c(Name = 'FSC0ARL', AcctSeed__Type__c = 'GL Account Variable 1'),
            new AcctSeed__Accounting_Variable__c(Name = 'ADM0SF', AcctSeed__Type__c = 'GL Account Variable 1'),
            new AcctSeed__Accounting_Variable__c(Name = 'LT - EFL', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true),
            new AcctSeed__Accounting_Variable__c(Name = 'LT - NonGSA', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true),
            new AcctSeed__Accounting_Variable__c(Name = 'LT - PVT', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true),
            new AcctSeed__Accounting_Variable__c(Name = 'CD', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true),
            new AcctSeed__Accounting_Variable__c(Name = 'CD - DLI-W', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true),
            new AcctSeed__Accounting_Variable__c(Name = 'LT - DODA', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true)
        };
        insert accVarList;
        return accVarList;
    }
    
    // To insert Account Settings
    public static testMethod List<AcctSeed__Accounting_Settings__c> createAccountSettings() {
       
        List<AcctSeed__GL_Account_Default__c> glAccountDefaultList = new List<AcctSeed__GL_Account_Default__c>();
        if(!createdObjNameSet.Contains('GlAccountDefault')){
            glAccountDefaultList = createTestGLAccountDefault();
            createdObjNameSet.add('GlAccountDefault');
        }
        else{
            glAccountDefaultList = [SELECT Id, Name, AcctSeed__GL_Account__c, AcctSeed__Ledger__c, AcctSeed__GL_Account_Specification__c FROM AcctSeed__GL_Account_Default__c];
        }
        
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        if(!createdObjNameSet.Contains('Ledger')){
            ledgers = createTestLedger();
            createdObjNameSet.add('Ledger');
        }else{
            ledgers = [SELECT Id, Name FROM AcctSeed__Ledger__c];
        }
        
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c>();
        if(!createdObjNameSet.Contains('GLAcct')){
            glAcc = createTestGLAccount();
            createdObjNameSet.add('GLAcct');
        }else{
            glAcc = [SELECT Id, Name FROM AcctSeed__GL_Account__c];
        }
        
        List<AcctSeed__Billing_Format__c> billFormatList = new List<AcctSeed__Billing_Format__c>();
        if(!createdObjNameSet.Contains('BillFormat')){
            billFormatList = createBillingFormat();
            createdObjNameSet.add('BillFormat');
        }
        else{
            billFormatList = [SELECT Id, Name, AcctSeed__Type__c, AcctSeed__Visualforce_PDF_Page__c, AcctSeed__Default_Email_Template__c FROM AcctSeed__Billing_Format__c LIMIT 5];
        }
                
        Id pdfActiveId, pdfOutId, pdfBillId, pdfPackingSlipId, pdfPurchaseId;
        
        for(AcctSeed__Billing_Format__c billFor : billFormatList) {
            if(billFor.AcctSeed__Type__c == 'Activity Statement') pdfActiveId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Outstanding Statement') pdfOutId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Billing') pdfBillId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Packing Slip') pdfPackingSlipId = billFor.Id;
            if(billFor.AcctSeed__Type__c == 'Purchase Order') pdfPurchaseId = billFor.Id;
        }
        
        List<AcctSeed__Accounting_Settings__c> settings = new List<AcctSeed__Accounting_Settings__c>();
        
        if(ledgers.size() > 0) {  
            
            Map<String, Id> specificationAndGLAccId = new Map<String, Id>();
            
            for(AcctSeed__GL_Account_Default__c glAD : glAccountDefaultList){
                specificationAndGLAccId.put(glAD.AcctSeed__GL_Account_Specification__c, glAD.AcctSeed__GL_Account__c);
            }
            
            settings.add(
                new AcctSeed__Accounting_Settings__c(
                    AcctSeed__AR_Control_GL_Account__c = specificationAndGLAccId.containsKey('AR_Control_GL_Account') ? specificationAndGLAccId.get('AR_Control_GL_Account') : glAcc[0].Id,
                    AcctSeed__AP_Control_GL_Account__c = specificationAndGLAccId.containsKey('AP_Control_GL_Account') ? specificationAndGLAccId.get('AP_Control_GL_Account') : glAcc[1].Id,
                    AcctSeed__Labor_GL_Account__c = specificationAndGLAccId.containsKey('Labor_GL_Account') ? specificationAndGLAccId.get('Labor_GL_Account') : glAcc[2].Id,
                    AcctSeed__Payment_Discount_GL_Account__c = specificationAndGLAccId.containsKey('Payment_Discount_GL_Account') ? specificationAndGLAccId.get('Payment_Discount_GL_Account') : glAcc[3].Id,
                    AcctSeed__Retained_Earnings_GL_Account__c = specificationAndGLAccId.containsKey('Retained_Earnings_GL_Account') ? specificationAndGLAccId.get('Retained_Earnings_GL_Account') : glAcc[5].Id,
                    AcctSeed__Default_Ledger__c = ledgers[0].Id,
                    //AcctSeed__Default_Bank_Account__c = specificationAndGLAccId.containsKey('Labor_GL_Account') ? specificationAndGLAccId.get('Labor_GL_Account') : glAcc[6].Id,
                    AcctSeed__Revenue_GL_Account__c = specificationAndGLAccId.containsKey('Revenue_GL_Account') ? specificationAndGLAccId.get('Revenue_GL_Account') : glAcc[7].Id,
                    AcctSeed__Default_Project_Task_Labor_GL_Account__c = specificationAndGLAccId.containsKey('Default_Project_Task_Labor_GL_Account') ? specificationAndGLAccId.get('Default_Project_Task_Labor_GL_Account') : glAcc[8].Id,
                    AcctSeed__Current_Year_Earnings_GL_Account__c = specificationAndGLAccId.containsKey('Current_Year_Earnings_GL_Account') ? specificationAndGLAccId.get('Current_Year_Earnings_GL_Account') : glAcc[9].Id,
                    AcctSeed__Enable_Product_Costing__c = true,
                    AcctSeed__Work_in_Process_GL_Account__c = specificationAndGLAccId.containsKey('Work_in_Process_GL_Account') ? specificationAndGLAccId.get('Work_in_Process_GL_Account') : glAcc[10].Id,
                    AcctSeed__Vouchers_Payable_GL_Account__c = specificationAndGLAccId.containsKey('Vouchers_Payable_GL_Account') ? specificationAndGLAccId.get('Vouchers_Payable_GL_Account') : glAcc[11].Id,
                    //AcctSeed__Inventory_Variance_GL_Account__c =  specificationAndGLAccId.containsKey('Labor_GL_Account') ? specificationAndGLAccId.get('Labor_GL_Account') : glAcc[12].Id,
                    AcctSeed__Customer_Payment_Adjustment_GL_Account__c = specificationAndGLAccId.containsKey('Customer_Payment_Adjustment_GL_Account') ? specificationAndGLAccId.get('Customer_Payment_Adjustment_GL_Account') : glAcc[13].Id,
                    AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
                    AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
                    AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true,
                    AcctSeed__Default_Billing_Format__c = pdfBillId,
                    AcctSeed__Billing_Outstanding_Statement_Format__c = pdfOutId,
                    AcctSeed__Billing_Activity_Statement_Format__c = pdfActiveId,
                    AcctSeed__Default_Credit_GL_Account_Revenue__c = specificationAndGLAccId.containsKey('Default_Credit_GL_Account_Revenue') ? specificationAndGLAccId.get('Default_Credit_GL_Account_Revenue') : null,   
                    AcctSeed__Default_Credit_GL_Account_Expense__c = specificationAndGLAccId.containsKey('Default_Credit_GL_Account_Expense') ? specificationAndGLAccId.get('Default_Credit_GL_Account_Expense') : glAcc[14].Id,
                    AcctSeed__Unapplied_Cash_GL_Account__c = specificationAndGLAccId.containsKey('Unapplied_Cash_GL_Account') ? specificationAndGLAccId.get('Unapplied_Cash_GL_Account') : null
               )
            );
        
            insert settings;
            
       }
       return settings;   
    }
    
    public Static testmethod List<APXTConga4__Conga_Template__c> createCongaTemplate() {
        List<APXTConga4__Conga_Template__c> congaTemp = new List<APXTConga4__Conga_Template__c> {
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Cover Page for Project'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Cover Page'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DLI TOEP'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'MTT ICA'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - DLI-W new and LT'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - DLI-W New Contract - SCA'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - Instructors LT'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Pay Rate Addendum'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - Staff - Exempt'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - Staff - Non-Exempt'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Job Summary Report - Labor Actual'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Job Summary Report - Labor Planned'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'send Tester Payment Form'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Material Disposition Form Project', APXTConga4__Template_Group__c = 'Disposition'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DLI Report', APXTConga4__Template_Group__c = 'Assessment Report'),
            new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Language Training Report', APXTConga4__Template_Group__c = 'Assessment Report')
        };
        insert congaTemp;
        return congaTemp;
    }
    
    public Static testmethod List<APXTConga4__Conga_Merge_Query__c> createCongaQuery() {
        List<APXTConga4__Conga_Merge_Query__c > congaQuery = new List<APXTConga4__Conga_Merge_Query__c> {
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'DLI TOEP OPLI Sum'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'DLI TOEP Contact Query'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'DLI TOEP Work Experience Query'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Cost Rate Query - CR Approval'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Cost Rate Query - Non approved'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'ICA Agreement Cost Rate Query'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Material Disposition Project Query'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Assess Report Doc Query'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Test Score - Assessment Report'),
            new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Action Plan - Assessment Report')
        };
        insert congaQuery;
        return congaQuery;
    }
    
    public static testmethod List<System_Values__c> createBillDotComSystemValues(){
    
        List<System_Values__c> sysVal = new List<System_Values__c>{
            new System_Values__c(Name ='Bill.com Vendor Last Sync Date Time', Value__c = '2020-04-24 08:30:45'), 
            new System_Values__c(Name ='Bill.com Job Last Sync Date Time', Value__c = '2020-04-24 08:30:45'),
            new System_Values__c(Name ='Bill.com Item Last Sync Date Time', Value__c = '2020-04-24 08:30:45'),
            new System_Values__c(Name ='Bill.com Class Last Sync Date Time', Value__c = '2020-04-24 08:30:45'),
            new System_Values__c(Name ='Bill.com COA Last Sync Date Time', Value__c = '2020-04-24 08:30:45')
        };
        insert sysVal;
        return sysVal;
    }

    public static testmethod Form_Template__c createFormTemplateAndFormTemplateElements(){
    
        Form_Template__c formTemp = new Form_Template__c(Name='Test Form Template',Header_Information__c='test header');
        insert formTemp;
        
        List<Form_Template_Element__c> formTempEle = new List<Form_Template_Element__c>{
            new Form_Template_Element__c(Form_Template__c=formTemp.Id, Answer_Options__c='option 1;option 2',Limit_Response__c=2,/*Question__c='Choose any one',*/Question_Type__c='Picklist',Required__c=true,Sequence__c=3,Set_As_Response_Name__c=false),
            new Form_Template_Element__c(Form_Template__c=formTemp.Id, Limit_Response__c=1,/*Question__c='Email',*/Question_Type__c='Email',Required__c=true,Sequence__c=2,Set_As_Response_Name__c=true),
            new Form_Template_Element__c(Form_Template__c=formTemp.Id, Question__c='Age',/*Question_Type__c='Number',*/Required__c=false,Sequence__c=4,Set_As_Response_Name__c=false),
            new Form_Template_Element__c(Form_Template__c=formTemp.Id, Question__c='Name',/*Question_Type__c='Text',*/Required__c=true,Sequence__c=1,Set_As_Response_Name__c=false)
        };
        insert formTempEle;
        formTempStatic = formTemp;
        
        return formTemp;
    }
    
    public static testmethod void createPerformanceCycleAndQuestionSet(){
        Form_Template__c formTemp = new Form_Template__c();
        if(!createdObjNameSet.Contains('Form_Template__c')){
            formTemp = createFormTemplateAndFormTemplateElements();
            createdObjNameSet.add('Form_Template__c');
        }else{
            formTemp = formTempStatic;
        }
        
        Performance_Cycle__c performanceCycle = new Performance_Cycle__c(Status__c='Pending',Due_Date__c=System.today().addDays(5));
        insert performanceCycle;
        List<Question_Set__c> qs = new List<Question_Set__c>{
            new Question_Set__c(Form_Template__c=formTemp.Id,Performance_Cycle__c=performanceCycle.Id, Feedback_Type__c='Self Summary', Due_Date__c=System.today().addDays(1)),
            new Question_Set__c(Form_Template__c=formTemp.Id,Performance_Cycle__c=performanceCycle.Id, Feedback_Type__c='Manager Summary', Due_Date__c=System.today().addDays(1)),
            new Question_Set__c(Form_Template__c=formTemp.Id,Performance_Cycle__c=performanceCycle.Id, Feedback_Type__c='Peer Summary', Due_Date__c=System.today().addDays(1))
        }; 
        insert qs;    
    }
    
    public static testMethod List<Project_Task_GL_Variable_Mapping__c> createTestProjectTaskGLVariableMapping() {
    
        List<Project_Task_GL_Variable_Mapping__c> projTaskGLVariableMappingList = new List<Project_Task_GL_Variable_Mapping__c>();        
        
        projTaskGLVariableMappingList = new List<Project_Task_GL_Variable_Mapping__c> {
        
            new Project_Task_GL_Variable_Mapping__c(Name = 'CD - DLI-W',Account__c = 'DLI-W - CD',Account_Condition__c = '=',GL_Variable_Name__c='CD - DLI-W',Project_Record_Type__c='CD_Projects',QB_Classification__c='CD0DLI',QB_Classification_Condition__c='='),
            new Project_Task_GL_Variable_Mapping__c(Name = 'CD',Account__c = 'DLI-W - CD',Account_Condition__c = '!=',GL_Variable_Name__c='CD',Project_Record_Type__c='CD_Projects'),
            new Project_Task_GL_Variable_Mapping__c(Name = 'LT - DODA',Account__c = 'DODA',Account_Condition__c = '=',GL_Variable_Name__c='LT - DODA',Project_Record_Type__c='DODA_Projects',QB_Classification__c='OF0MTT0PS',QB_Classification_Condition__c='!='),
            new Project_Task_GL_Variable_Mapping__c(Name = 'LT - NonGSA',Account__c = 'DLI-W,DODA,PVT,DLS',Account_Condition__c = 'NOT LIKE',GL_Variable_Name__c='LT - NonGSA',Project_Record_Type__c='Language_Training_Projects',QB_Contract_Type__c='FED:nonGSA',QB_Contract_Type_Condition__c='='),
            new Project_Task_GL_Variable_Mapping__c(Name = 'LT - PVT',Account__c = 'PVT',Account_Condition__c = 'LIKE',GL_Variable_Name__c='LT - PVT',Project_Record_Type__c='Language_Training_Projects',QB_Contract_Type__c='COMM:INDV',QB_Contract_Type_Condition__c='='),
            new Project_Task_GL_Variable_Mapping__c(Name = 'LT - EFL',GL_Variable_Name__c='LT - EFL',Project_Record_Type__c='EFL_Projects')            
        };
        if(projTaskGLVariableMappingList != null && projTaskGLVariableMappingList.size() > 0)
            insert projTaskGLVariableMappingList;
        return projTaskGLVariableMappingList;
    }
    
    public static testMethod List<Goal__c> CreateGoals(){
        
        Map<String, Goal__c> goalMap = new Map<String, Goal__c>();
        List<Goal__c> goals = new List<Goal__c>();
        
        Integer cy = Date.today().year();
        String currentYear = String.valueOf(cy);
        Date startDate_CurrentYear = Date.newinstance(cy, 01, 01);
        Date endDate_CurrentYear = Date.newinstance(cy, 12, 31);
        Date endDate_LastMonth = Date.today().toStartOfMonth()-1;        
        Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
        
        Integer lastYear = Date.today().year()-1;
        Date startDate_LastYear = Date.newinstance(lastYear, 01, 01);
        Date endDate_LastYear = Date.newinstance(lastYear, 12, 31);
        Date endDate_firstMonth = startDate_LastYear.addMonths(1)-1; 
        Date startDate_firstMonth = endDate_firstMonth.toStartOfMonth();
        
        Goal__c g1 = new Goal__c(Name = currentYear+' Proforma Actual - LT - ARL/(DC)', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_1', g1);
        
        Goal__c g2 = new Goal__c(Name = currentYear+' Proforma Actual - Testing', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_2', g2);
        
        Goal__c g3 = new Goal__c(Name = currentYear+' Proforma Actual GLAV - LT - DODA PS', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_3', g3);

        Goal__c g4 = new Goal__c(Name = lastYear+' Proforma Actual - LT - ARL/(DC)', Start_Date__c = startDate_LastYear, Due_Date__c = endDate_LastYear);
        goalMap.put('Goal_4', g4);

        Goal__c mg1 = new Goal__c(Name = currentYear+' Registrar Closure Rate per QTR', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_mg1', mg1);
        
        Goal__c mg2 = new Goal__c(Name = currentYear+' Registrar Closure Rate per Year', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_mg2', mg2);
        
        Goal__c mg3 = new Goal__c(Name = currentYear+' Registrar # of Inquiries', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_mg3', mg3);
        
        Goal__c mg4 = new Goal__c(Name = currentYear+' Registrar # of Enrollments', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_mg4', mg4);
        
        Goal__c mg5 = new Goal__c(Name = currentYear+' Registrar Value of Inquiries', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_mg5', mg5);
        
        Goal__c mg6 = new Goal__c(Name = currentYear+' Registrar Value of Enrollments', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_mg6', mg6);
        
        Goal__c mg7 = new Goal__c(Name = currentYear+' Registrar Avg Hourly Rate of Enrollments', Start_Date__c = startDate_CurrentYear, Due_Date__c = endDate_CurrentYear);
        goalMap.put('Goal_mg7', mg7);

        insert goalMap.values();
        goalMapStatic = goalMap;
        goals.addAll(goalMap.values());
        return goals;
    }
    
    public static List<Metric__c> createMetrics(){
        
        List<Goal__c> goals = new List<Goal__c>();
        if(!createdObjNameSet.Contains('Goals')){
            goals = CreateGoals();
            createdObjNameSet.add('Goals');
        }else{
            goals = [SELECT Id, Name FROM Goal__c];
        }
        
        List<Metric__c> metrics = new List<Metric__c>();
        Date endDate_LastMonth = Date.today().toStartOfMonth()-1;        
        Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
        
        Integer currentYear = Date.today().year();
        Integer lastYear = currentYear-1;
        Date sd_LY = Date.newinstance(lastYear, 12, 01);
        Date ed_LY = Date.newinstance(lastYear, 12, 31);
        
        Map<String, Goal__c> goalMap = new Map<String, Goal__c>();
        goalMap = goalMapStatic;
        
        Metric__c m1 = new Metric__c(Goal__c = goalMap.get('Goal_1').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Hours');
        metrics.add(m1);
        
        Metric__c m2 = new Metric__c(Goal__c = goalMap.get('Goal_2').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Hours');
        metrics.add(m2);
        
        Metric__c m3 = new Metric__c(Goal__c = goalMap.get('Goal_3').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Hours');
        metrics.add(m3);
        
        Metric__c m4 = new Metric__c(Goal__c = goalMap.get('Goal_4').Id, Start_Date__c = sd_LY, Due_Date__c = ed_LY, Metric_Type__c = 'Hours');
        metrics.add(m4);
        
        Metric__c mm_Q1 = new Metric__c(Name = 'Closure Rate - Q1' , Goal__c = goalMap.get('Goal_mg1').Id, Start_Date__c = Date.newinstance(currentYear, 01, 01), Due_Date__c = Date.newinstance(currentYear, 03, 31), Metric_Type__c = 'Sales - Enrollments');
        metrics.add(mm_Q1);
        
        Metric__c mm_Q2 = new Metric__c(Name = 'Closure Rate - Q2' , Goal__c = goalMap.get('Goal_mg1').Id, Start_Date__c = Date.newinstance(currentYear, 04, 01), Due_Date__c = Date.newinstance(currentYear, 06, 30), Metric_Type__c = 'Sales - Enrollments');
        metrics.add(mm_Q2);
        
        Metric__c mm_Q3 = new Metric__c(Name = 'Closure Rate - Q3' , Goal__c = goalMap.get('Goal_mg1').Id, Start_Date__c = Date.newinstance(currentYear, 07, 01), Due_Date__c = Date.newinstance(currentYear, 09, 30), Metric_Type__c = 'Sales - Enrollments');
        metrics.add(mm_Q3);
        
        Metric__c mm_Q4 = new Metric__c(Name = 'Closure Rate - Q4' , Goal__c = goalMap.get('Goal_mg1').Id, Start_Date__c = Date.newinstance(currentYear, 10, 01), Due_Date__c = Date.newinstance(currentYear, 12, 31), Metric_Type__c = 'Sales - Enrollments');
        metrics.add(mm_Q4);
                
        Metric__c mm2 = new Metric__c(Name = 'Closure Rate', Goal__c = goalMap.get('Goal_mg2').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Sales - Enrollments');
        metrics.add(mm2);
        
        Metric__c mm3 = new Metric__c(Name = '# of Inquiries', Goal__c = goalMap.get('Goal_mg3').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Sales - Inquiries');
        metrics.add(mm3);
                
        Metric__c mm4 = new Metric__c(Name = '# of Enrollments', Goal__c = goalMap.get('Goal_mg4').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Sales - Enrollments');
        metrics.add(mm4);
        
        Metric__c mm5 = new Metric__c(Name = 'Value of Inquiries', Goal__c = goalMap.get('Goal_mg5').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Sales - Inquiries');
        metrics.add(mm5);
                
        Metric__c mm6 = new Metric__c(Name = 'Value of Enrollments', Goal__c = goalMap.get('Goal_mg6').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Sales - Enrollments');
        metrics.add(mm6);
        
        Metric__c mm7 = new Metric__c(Name = 'Avg Hourly Rate of Enrollments', Goal__c = goalMap.get('Goal_mg7').Id, Start_Date__c = startDate_LastMonth, Due_Date__c = endDate_LastMonth, Metric_Type__c = 'Price');
        metrics.add(mm7);

        insert metrics;
        return metrics;
    }
    
    public static List<Goals_Metrics_Mapping__c> createGoalAndMetricMapping(){
    
        List<Goals_Metrics_Mapping__c> goalAndMetricMappingRecs = new List<Goals_Metrics_Mapping__c>{
        
            new Goals_Metrics_Mapping__c(Name = 'Proforma Actual - LT - ARL/(DC)', Goal_Name__c = 'Proforma Actual - LT - ARL/(DC)', 
                Account__c = 'DLI-W,DODA,DLS', Account_Condition__c = 'NOT CONTAINS', Billable__c = 'True', Billable_Condition__c = '=', 
                Contact_Assignment_Position__c = '', Contact_Assignment_Position_Condition__c = '', 
                Project_Record_Type__c = '', 
                Project_Record_Type_Condition__c = '', QB_Classification__c = 'OF0DCA,ON0LT0ARL',
                QB_Classification_Condition__c = 'IN', GLAV2__c = '', GLAV2_Condition__c = ''),
            
            new Goals_Metrics_Mapping__c(Name = 'Proforma Actual - Testing', Goal_Name__c = 'Proforma Actual - Testing', 
                Account__c = '', Account_Condition__c = '', Billable__c = 'True', Billable_Condition__c = '=',
                Contact_Assignment_Position__c = 'Instructor,Tester', Contact_Assignment_Position_Condition__c = 'IN', 
                Project_Record_Type__c = 'Testing_Projects', Project_Record_Type_Condition__c = 'IN', QB_Classification__c = '', 
                QB_Classification_Condition__c = '', GLAV2__c = '', GLAV2_Condition__c = ''),
            
            new Goals_Metrics_Mapping__c(Name = 'Proforma Actual GLAV - LT - DODA PS', Goal_Name__c = 'Proforma Actual GLAV - LT - DODA PS', 
                Account__c = '', Account_Condition__c = '', Billable__c = 'True', Billable_Condition__c = '=',
                Contact_Assignment_Position__c = '', Contact_Assignment_Position_Condition__c = '', 
                Project_Record_Type__c = '', Project_Record_Type_Condition__c = '', QB_Classification__c = 'OF0MTT0PS', 
                QB_Classification_Condition__c = 'IN', GLAV2__c = 'LT - DODA', GLAV2_Condition__c = 'EQUALS'),
            
            new Goals_Metrics_Mapping__c(Name = 'Registrar # of Enrollments', Goal_Name__c = 'Registrar # of Enrollments', 
                Account__c = 'DLI-W,DLI-W - AFPAK,DLI-W - LT,DLS,DLS1,DODA,ODNI,Softsquare ELT,APMO,PGLS', Account_Condition__c = 'NOT EQUALS',
                QB_Classification__c = 'ON0LNG', QB_Classification_Condition__c = 'NOT IN', 
                Opportunity_Record_Type__c = 'New_Classes_Opportunities,MTT_Opportunities,Partner_School', Opportunity_Record_Type_Condition__c = 'IN',
                Stage_Name__c = 'Order,Active,On Hold, Ended', Stage_Name_Condition__c = 'IN'),
            
            new Goals_Metrics_Mapping__c(Name = 'Registrar # of Inquiries', Goal_Name__c = 'Registrar # of Inquiries', 
                Account__c = 'DLI-W,DLI-W - AFPAK,DODA,DLI-W - LT,DLS,APMO,PGLS', Account_Condition__c = 'NOT EQUALS', 
                Opportunity_Record_Type__c = 'New_Classes_Opportunities', Opportunity_Record_Type_Condition__c = 'IN'),
            
            new Goals_Metrics_Mapping__c(Name = 'Registrar Avg HR of Enrollments', Goal_Name__c = 'Registrar Avg Hourly Rate of Enrollments', 
                Account__c = 'DLI-W,DLI-W - AFPAK,DLI-W - LT,DLS,DLS1,DODA,ODNI,Softsquare ELT,APMO,PGLS', Account_Condition__c = 'NOT EQUALS', 
                QB_Classification__c = 'ON0LNG', QB_Classification_Condition__c = 'NOT IN', 
                Opportunity_Record_Type__c = 'New_Classes_Opportunities,MTT_Opportunities,Partner_School', Opportunity_Record_Type_Condition__c = 'IN', 
                Stage_Name__c = 'Order,Active,On Hold, Ended', Stage_Name_Condition__c = 'IN'),
                
            new Goals_Metrics_Mapping__c(Name = 'Registrar Value of Enrollments', Goal_Name__c = 'Registrar Value of Enrollments', 
                Account__c = 'DLI-W,DLI-W - AFPAK,DLI-W - LT,DLS,DLS1,DODA,ODNI,Softsquare ELT,APMO,PGLS', Account_Condition__c = 'NOT EQUALS', 
                QB_Classification__c = 'ON0LNG', QB_Classification_Condition__c = 'NOT IN', 
                Opportunity_Record_Type__c = 'New_Classes_Opportunities,MTT_Opportunities,Partner_School', Opportunity_Record_Type_Condition__c = 'IN', 
                Stage_Name__c = 'Order,Active,On Hold, Ended', Stage_Name_Condition__c = 'IN'),
            
            new Goals_Metrics_Mapping__c(Name = 'Registrar Value of Inquiries', Goal_Name__c = 'Registrar Value of Inquiries', 
                Account__c = 'DLI-W,DLI-W - AFPAK,DODA,DLI-W - LT,DLS,APMO,PGLS', Account_Condition__c = 'NOT EQUALS', 
                Opportunity_Record_Type__c = 'New_Classes_Opportunities', Opportunity_Record_Type_Condition__c = 'IN')                
        };
        insert goalAndMetricMappingRecs;
        return goalAndMetricMappingRecs;
    }

    public static testMethod List<Task> createTasks(){
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opportunityList = new List<Opportunity>();

        if(!createdObjNameSet.Contains('Opportunity')){
            opportunityList = createTestOpportunities();
            createdObjNameSet.add('Opportunity');
        }
        else{
            opportunityList = oppStaticList;
        }
        if(!createdObjNameSet.Contains('Contact')){
            contactList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            contactList = staticContactList;
        }

        accountList = accountStaticList;

        List<Task> taskList = new List<Task>{
            new Task(WhatId = accountList[0].Id , TaskSubtype = 'Call' , Subject = 'Task1 Of Account' , ActivityDate = System.today().addDays(-10)),
            new Task(WhatId = accountList[0].Id , TaskSubtype = 'Call' , Subject = 'Task1 Of Account' , Status = 'Completed'),
            new Task(WhatId = opportunityList[0].Id , TaskSubtype = 'Task' , Subject = 'Task1 Of Opportunity' , Status = 'Completed'),
            new Task(WhatId = opportunityList[0].Id , TaskSubtype = 'Task' , Subject = 'Task1 Of Opportunity' , ActivityDate = System.today().addDays(-2)),
            new Task(WhatId = opportunityList[0].Id , TaskSubtype = 'Task' , Subject = 'Task1 Of Opportunity'),
            new Task(WhatId = accountList[0].Id , TaskSubtype = 'Email' , Subject = 'This is a System generated mail' , Status = 'Completed' , Description = 'To: ajaaykarthik@gmail.com\nBody: This is the subject of the System Generated Mail')
        };
        insert taskList;
        staticTaskList = taskList;
        return taskList;
    }
    
    public static testMethod List<Event> createEventsAndEmailMessageRecords(){
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opportunityList = new List<Opportunity>();

        if(!createdObjNameSet.Contains('Opportunity')){
            opportunityList = createTestOpportunities();
            createdObjNameSet.add('Opportunity');
        }
        else{
            opportunityList = oppStaticList;
        }
        if(!createdObjNameSet.Contains('Contact')){
            contactList = createTestContacts();
            createdObjNameSet.add('Contact');
        }else{
            contactList = staticContactList;
        }

        accountList = accountStaticList;

        List<Event> eventList = new List<Event>{
            new Event(WhatId = accountList[0].Id , StartDateTime = System.now().addDays(2) , EndDateTime = System.now().addDays(6)),
            new Event(WhatId = opportunityList[0].Id , StartDateTime = System.now().addDays(-1) ,  Subject = 'Event2 Of Opportunity' , EndDateTime = System.now()),
            new Event(WhatId = opportunityList[0].Id , StartDateTime  = Datetime.newInstance(2022,08,15,2,30,2) ,  Subject = 'Event2 Of Opportunity' ,EndDateTime = Datetime.newInstance(2022, 08, 17,2, 30, 2)),
            new Event(WhatId = opportunityList[0].Id , StartDateTime  = Datetime.newInstance(2022, 08, 15,17, 30, 2) ,  Subject = 'Event2 Of Opportunity' ,EndDateTime = Datetime.newInstance(2022, 08, 17,17, 30, 2)),
            new Event(WhatId = opportunityList[0].Id , StartDateTime  = System.now().addDays(7) ,  Subject = 'Event2 Of Opportunity' ,EndDateTime = System.now().addDays(9)),
            new Event(WhoId = contactList[0].Id , StartDateTime  = System.now().addDays(2) ,  Subject = 'Event4 Of Opportunity' ,EndDateTime = System.now().addDays(5))
        };
        EmailMessage emailMessage = new EmailMessage(status = '3' , fromName = 'Test Name' , subject = 'This is the Subject!' , htmlBody = '<html><body><b>Hello</b></body></html>' , toIds = new List<String>{contactList[0].Id} , toAddress = 'testuser1@testmail.com' );
        insert emailMessage;
    
        EmailMessageRelation emr = new EmailMessageRelation(emailMessageId = emailMessage.Id , relationId = contactList[0].Id , relationType = 'FromAddress');
        insert emr;
        
        insert eventList;
        staticEventList = eventList;
        return eventList;
    }
}