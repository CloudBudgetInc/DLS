Global Class ResumeUploadRchilliClass {
    
    global Static Attachment resumeAtt{get; set;}
    global static List<ContactInfo> contactInfoList = new List<ContactInfo>();
    global static List<Experience__c> EduExpList = new List<Experience__c>();
    global static Map<String,String> collegeNameWithDegreeMap = new Map<String,String>();
    global static List<Experience__c> workExpList = new List<Experience__c>();
    global static Map<String,String> companyNameWithRoleMap = new Map<String,String>();
    //global static Map<String, String> selectedAccountIdAndNameMap{get; set;}
    global jsonResponseWrapperClass jsonParentClass{get; set;}
    // global Static String responseBody;    
    
    global ResumeUploadRchilliClass() {
        //jsonResume();        
        resumeAtt = new Attachment();
        
    }
    
    @RemoteAction
    public static Map<String, String> getAttachedResumeFromApplicantRec(Id applicantId){
        Map<String, String> resume  = new Map<String, String>();
        if(String.isNotEmpty(applicantId)){            
            List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink 
             															  WHERE LinkedEntityId = :applicantId AND ContentDocument.Title LIKE '%resume%' 
             															  ORDER BY ContentDocument.CreatedDate DESC LIMIT 1];
            if(cdls.size() > 0){
                List<ContentVersion> conVersion = [SELECT Id, VersionData, FileExtension , Title FROM ContentVersion WHERE ContentDocumentId = :cdls[0].ContentDocumentId AND IsLatest = true];
                String fileData = EncodingUtil.Base64Encode(conVersion[0].VersionData);    
                resume.put('resultbody',fileData);
                resume.put('name',conVersion[0].Title+'.'+conVersion[0].FileExtension );
            }            
        }
        
        return resume;
    }
    
    @RemoteAction
    global static List<Object> searchMatchedContact(Map<String, String> resumeContent) {
        
        system.debug(':::::resumeContent    ::::'+resumeContent);
        String bodyStr = resumeContent.containsKey('resultbody') ? resumeContent.get('resultbody') : 'Resume Untitled';
        String fileName = resumeContent.containsKey('name') ? resumeContent.get('name') : 'Resume Untitled';  
        String responseBody;
                
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        System_Values__c rchilliEndPointUrl = System_Values__c.getValues('RchilliEndPoint_URL');
        String endPointUrl = rchilliEndPointUrl.Value__c;
        
        request.setEndpoint(endPointUrl);        
        //request.setEndpoint('http://dlsdc7.rchilli.com/RChilliParser/Rchilli/parseResumeBinary');        
        request.setMethod('POST');        
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        request.setTimeout(15000);        
        
        System_Values__c rchilliUserKey = System_Values__c.getValues('Rchilli_Userkey');
        String userkey = rchilliUserKey.Value__c;
        System_Values__c rchilliVersion = System_Values__c.getValues('Rchilli_Version');
        String version = rchilliVersion.Value__c;
        System_Values__c rchilliSubUser = System_Values__c.getValues('Rchilli_subUserId');
        String subUserId = rchilliSubUser.Value__c;
        
        // Set the body as a JSON object 
        String setBodyStr = '{ "filedata" : '+'"'+bodyStr+'"'+' , "filename" : '+'"' + fileName+ '"'+', "userkey": '+'"'+userkey+'"'+', "version": '+'"'+version+'"'+', "subuserid": '+'"'+subUserId+'"'+' }';
        //String setBodyStr = '{ "filedata" : '+'"'+bodyStr+'"'+' , "filename" : '+'"' + fileName+ '"'+', "userkey": "FI17YQZ25UW", "version": "7.0.0", "subuserid": "dlsdc7" }';
        
        request.setBody(setBodyStr);
        
        if(Test.isRunningTest()) { 
            RChilliJSONDummyData js = new RChilliJSONDummyData();
            responseBody = js.jsonStr();
            //system.debug('responseBody:testclass:::'+responseBody);
        }else{
           
            HttpResponse response = http.send(request);
            responseBody = response.getbody();
        }
        
        List<contact> contactList = new List<contact>();
        String contqueryStr = 'SELECT Id,Name,Account.Name,Birthdate,Citizenship__c,Email,Fax,HomePhone,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MobilePhone,FirstName,LastName,MiddleName,Non_US_Passport_Country__c,Gender__c,Driver_s_License__c,Nationality__c FROM Contact WHERE '; // removed Language_s_Known__c,
       
        if(responseBody <> NULL){
            Boolean currencyContains = responseBody.contains('"Currency"');
            System.debug('currencyContains::::'+currencyContains);
            responseBody = responseBody.replaceAll('"Currency"', '"Currency_x"');
            responseBody = responseBody.replaceAll('"Number"', '"Number_x"');
            system.debug('::responseBody::'+responseBody);
            //jsonResponseWrapperClass newjsonClass = new jsonResponseWrapperClass();
            //System.debug('newjsonClass:::'+newjsonClass);
            jsonResponseWrapperClass jsonParentClass = (jsonResponseWrapperClass) System.JSON.deserialize(responseBody, jsonResponseWrapperClass.class);
            system.debug('::jsonParentClass:::'+jsonParentClass);
            String FirstNme;
            String MiddleNme;
            String LastNme;
            String Email;
            String Phone;
            String FullNme;
            Integer conditionCount = 0;
        
            FirstNme = jsonParentClass.ResumeParserData.Name.FirstName;
            MiddleNme = jsonParentClass.ResumeParserData.Name.MiddleName;
            LastNme = jsonParentClass.ResumeParserData.Name.LastName;
            if(jsonParentClass.ResumeParserData.Email.size() > 0) {
                Email = jsonParentClass.ResumeParserData.Email[0].EmailAddress;   
            }        //'sss@ss.com';
            for( PhoneNumberCls pn: jsonParentClass.ResumeParserData.PhoneNumber) {
                if(pn.Type == 'Phone' ){
                    Phone = pn.OriginalNumber;
                }
            }
            FullNme = jsonParentClass.ResumeParserData.Name.FullName;
                    
            if(FullNme != null && FullNme != ''){
                contqueryStr = contqueryStr + ' Name = \'' + FullNme + '\'';
                ++conditionCount;
            }
            if(LastNme != null && LastNme != '') {
                if(conditionCount > 0){
                    contqueryStr = contqueryStr + ' OR LastName = \'' + LastNme + '\'';
                }else {
                    contqueryStr = contqueryStr + 'LastName = \'' + LastNme + '\'';
                }
                ++conditionCount;
            }
            if(FirstNme != null && FirstNme != '') {
                if(conditionCount > 0){
                    contqueryStr = contqueryStr + ' OR FirstName = \'' + FirstNme + '\'';
                }else {
                    contqueryStr = contqueryStr + 'FirstName = \'' + FirstNme + '\'';
                }
                ++conditionCount;
            }
            if(MiddleNme != null && MiddleNme != '') {
                if(conditionCount > 0){
                    contqueryStr = contqueryStr + ' OR MiddleName = \'' + MiddleNme + '\'';
                }else {
                    contqueryStr = contqueryStr + 'MiddleName = \'' + MiddleNme + '\'';
                }
                ++conditionCount;
            }
            if(Email != null && Email != '') {
                if(conditionCount > 0){
                    contqueryStr = contqueryStr + ' OR Email = \'' + Email + '\'';
                }else {
                    contqueryStr = contqueryStr + 'Email = \'' + Email + '\'';
                }
                ++conditionCount;
            }
            if(Phone != null && Phone != '') {
                if(conditionCount > 0){
                    contqueryStr = contqueryStr + ' OR Phone = \'' + Phone + '\'';
                }else {
                    contqueryStr = contqueryStr + 'Phone = \'' + Phone + '\'';
                }
                ++conditionCount;
            }
            
            system.debug('conditionCount::::'+conditionCount);
            system.debug('::::::::::contqueryStr:::'+contqueryStr);
            if(conditionCount > 0) {
                contactList = database.query(contqueryStr);
            } 
        }    
        system.debug('::::contactList:::::'+contactList);
        
        return contactList;
    }


    //parsing of json response
    @RemoteAction
    global static String jsonResume( String contactId,Map<String,String> resumeContent, String type) {
        
        Set<String> existingSkillSet = new Set<String>();
        Map<String,Id> expRecTypeNameAndIdMap = new Map<String,Id>();
        Contact contactIns = new Contact();
        String default_AcctId;
        String responseBody;                
        
        String bodyStr = resumeContent.containsKey('resultbody') ? resumeContent.get('resultbody') : 'Resume Untitled';
        String fileName = resumeContent.containsKey('name') ? resumeContent.get('name') : 'Resume Untitled';  
        
        //system.debug('resumeContent.containsKey.name:::'+resumeContent.containsKey('name') );
        //system.debug('resumeContent.get(name)******'+resumeContent.get('name'));
        //system.debug('fileName***'+fileName);
        //system.debug('::    :::::bodyStr:::'+bodyStr);

        Map<String, List<Object>> resumeTypeToWrapper = new Map<String, List<Object>>();
        List<Contact> contactList = new List<Contact>();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        System_Values__c rchilliEndPointUrl = System_Values__c.getValues('RchilliEndPoint_URL');
        String endPointUrl = rchilliEndPointUrl.Value__c;
        
        request.setEndpoint(endPointUrl);  
        request.setMethod('POST');        
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');  
        request.setTimeout(15000);      
        
        System_Values__c rchilliUserKey = System_Values__c.getValues('Rchilli_Userkey');
        String userkey = rchilliUserKey.Value__c;
        System_Values__c rchilliVersion = System_Values__c.getValues('Rchilli_Version');
        String version = rchilliVersion.Value__c;
        System_Values__c rchilliSubUser = System_Values__c.getValues('Rchilli_subUserId');
        String subUserId = rchilliSubUser.Value__c;
        
        // Set the body as a JSON object 
        String setBodyStr = '{ "filedata" : '+'"'+bodyStr+'"'+' , "filename" : '+'"' + fileName+ '"'+', "userkey": '+'"'+userkey+'"'+', "version": '+'"'+version+'"'+', "subuserid": '+'"'+subUserId+'"'+' }';
        //String setBodyStr = '{ "filedata" : '+'"'+bodyStr+'"'+' , "filename" : '+'"' + fileName+ '"'+', "userkey": "FI17YQZ25UW", "version": "7.0.0", "subuserid": "dlsdc7" }';
        
        request.setBody(setBodyStr);
        
        if(Test.isRunningTest()) { 
            RChilliJSONDummyData js = new RChilliJSONDummyData();
            responseBody = js.jsonStr();
        }else{            
            HttpResponse response = http.send(request);
            responseBody = response.getbody();
        }
                
        if( responseBody <> NULL ) {
            responseBody = responseBody.replaceAll('"Currency"', '"Currency_x"');
            responseBody = responseBody.replaceAll('"Number"', '"Number_x"');            
            jsonResponseWrapperClass jsonParentClass = (jsonResponseWrapperClass) System.JSON.deserialize(responseBody, jsonResponseWrapperClass.class);
            
            system.debug('jsonParentClass*********'+jsonParentClass);
            
            resumeTypeToWrapper.put('EducationList',new List<EduOrWorkExperienceWrapperClass>());
            resumeTypeToWrapper.put('WorkList',new List<EduOrWorkExperienceWrapperClass>());
            resumeTypeToWrapper.put('LanguageKnownList', new List<Known_Language__c>());
            resumeTypeToWrapper.put('ContactInfo',new List<ContactInfo>{});
            resumeTypeToWrapper.put('PersonalInfo',new List<ContactInfo>{});
            resumeTypeToWrapper.put('NewSkillInfoList',new List<NewSkillsWrapperClass>{});
            
            resumeTypeToWrapper.put('LanguageList', new List<Language__c>());
            
            // Language is for Picklist
            List<Language__c> langList = LanguageService.getLanguages(' ORDER BY Name');
            
            for (Language__c l : langList) {
                if(resumeTypeToWrapper <> NULL){
                    if(resumeTypeToWrapper.containsKey('LanguageList'))
                        resumeTypeToWrapper.get('LanguageList').add(l);
                }
            }
            
            if (contactId <> 'NoContact') {     
                ContactList = [SELECT Id,Name,AccountId,Account.Name,Birthdate,Citizenship__c,Email,Fax,HomePhone,Phone,MailingAddress,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MobilePhone,FirstName,LastName,MiddleName,Non_US_Passport_Country__c,Gender__c,Driver_s_License__c,Nationality__c FROM Contact WHERE Id =: contactId]; //*removed Language_s_Known__c,
                
                //system.debug('expList:::testclass:'+expList);
                resumeTypeToWrapper = editProfile(contactId, type);                
            } 
            
            for (RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType = 'Experience__c']) {
                expRecTypeNameAndIdMap.put(rt.DeveloperName,rt.Id);
            }
            
            if( ContactList != null && ContactList.size() > 0 ) {
                contactIns = ContactList[0];
            }
            String langStr = '';
            if( resumeTypeToWrapper <> NULL && type == 'Upload' && jsonParentClass.ResumeParserData != null) {
                if(resumeTypeToWrapper.containsKey('ContactInfo')) {
                    String phoneNo = '';
                    String mobileNo = '';
                    resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('First Name', contactIns.FirstName,jsonParentClass.ResumeParserData.Name.FirstName));
                    resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Middle Name', contactIns.Middlename,jsonParentClass.ResumeParserData.Name.MiddleName));
                    resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Last Name', contactIns.LastName,jsonParentClass.ResumeParserData.Name.LastName));
                    if(jsonParentClass.ResumeParserData.Email.size() > 0) {
                        resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Email', contactIns.Email,jsonParentClass.ResumeParserData.Email[0].EmailAddress));
                    }
                    for( PhoneNumberCls pn: jsonParentClass.ResumeParserData.PhoneNumber) {
                        if(pn.Type == 'Phone' ){
                            phoneNo = pn.OriginalNumber;
                        }
                        if(pn.Type == 'Mobile' ){
                            mobileNo = pn.OriginalNumber;
                        } 
                    }
                    resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Phone', contactIns.Phone, phoneNo));
                    resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Mobile', contactIns.MobilePhone, mobileNo));
                    for( AddressCls adrs : jsonParentClass.ResumeParserData.Address) {
                        if(adrs.Type == 'Present') {
                            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Street',string.ValueOf(contactIns.MailingStreet),adrs.Street));
                            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('City', contactIns.MailingCity,adrs.City));
                            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('State', contactIns.MailingState,adrs.State));
                            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Country', contactIns.MailingCountry,adrs.Country));
                            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('ZipCode', contactIns.MailingPostalCode,adrs.ZipCode));
                        }
                    }
                    for(languageCls lang: jsonParentClass.ResumeParserData.LanguageKnown) {
                        if(langStr != '') {
                            langStr = langStr + ', ' + lang.Language;
                        } else {
                            langStr = langStr + lang.Language;
                        }
                    }
                    resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('LanguageKnown', '',langStr));

                }
                
                if(resumeTypeToWrapper.containsKey('PersonalInfo')) {
                    resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('Date Of Birth', String.ValueOf(contactIns.Birthdate),jsonParentClass.ResumeParserData.DateOfBirth));
                    resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('Gender', contactIns.Gender__c,jsonParentClass.ResumeParserData.Gender));
                    resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('LicenseNo', contactIns.Driver_s_License__c,jsonParentClass.ResumeParserData.LicenseNo));
                    resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('PassportNo', contactIns.Non_US_Passport_Country__c,jsonParentClass.ResumeParserData.PassportDetail.PassportNumber));
                    resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('VisaStatus', contactIns.Citizenship__c,jsonParentClass.ResumeParserData.VisaStatus));
                }
            }
            
            //system.debug('NewSkillInfoList::::'+resumeTypeToWrapper.get('NewSkillInfoList'));
            //system.debug('SkillInfoList::::'+resumeTypeToWrapper.get('SkillInfoList'));
            if(expRecTypeNameAndIdMap <> NULL && jsonParentClass.ResumeParserData != null) {
                if(expRecTypeNameAndIdMap.containsKey('Education_Experience')){
            
                    String tempDegree = '';
                    Boolean forCollege = false;
                    Boolean forDegree = false;
                    //Integer i = 0;
                    for(QualificationCls edusp : jsonParentClass.ResumeParserData.SegregatedQualification){
                        forCollege = false;
                        forDegree = false;

                        Experience__c ex = new Experience__c( RecordTypeId = expRecTypeNameAndIdMap.get('Education_Experience'));
                        ex.College_School__c = edusp.Institution.Name;
                        ex.College_School_Type__c = edusp.Institution.Type;
                        
                        if(collegeNameWithDegreeMap <> NULL){
                            if(collegeNameWithDegreeMap.containsKey(ex.College_School__c)) {
                                tempDegree = collegeNameWithDegreeMap.get(ex.College_School__c);
                                forCollege = true;
                            }
                        }
                        ex.City__c = edusp.Institution.Location.City; // check condition
                        ex.State__c = edusp.Institution.Location.State;
                        ex.Country__c = edusp.Institution.Location.Country;
                        ex.Degree__c = edusp.degree.DegreeName;
                        if(edusp.degree.Specialization.size() > 0) {
                            String fieldOfCon = '';
                            for(String st : edusp.degree.Specialization) {
                                if(fieldOfCon != '') {
                                    fieldOfCon = fieldOfCon + ', ' + st;
                                } else {
                                    fieldOfCon = st;
                                }
                            }
                            ex.Field_of_Concentration__c = fieldOfCon;
                        }
                        if(tempDegree != '' && edusp.degree.DegreeName != '' && tempDegree == edusp.degree.DegreeName) {
                            forDegree = true;
                        }
                        // To display the Year of Completion in the MM/DD/YYYY format.
                        if(String.isNotBlank(edusp.EndDate)) {
                            List<String> tempSDList = edusp.EndDate.split('/');
                            if(tempSDList != null && tempSDList.size() > 2) 
                                ex.Year_of_Completion__c = tempSDList[2];
                        }
                        //ex.Year_of_Completion__c = edusp.EndDate;
                        //system.debug('::::&&&&'+edusp.Aggregate.Value);
                        if(edusp.Aggregate <> NULL){
                            String aggr = edusp.Aggregate.Value;
                            if(String.isNotBlank(aggr))
                                ex.Aggregate__c = Decimal.ValueOf(aggr);
                        }
                        //System.debug('forDegree:::'+forDegree);
                        //System.debug('forCollege:::'+forCollege);
                        if(resumeTypeToWrapper <> NULL){
                            if(!forDegree && !forCollege && resumeTypeToWrapper.containsKey('EducationList')) {
                                resumeTypeToWrapper.get('EducationList').add(new EduOrWorkExperienceWrapperClass(ex,true,false));
                                //System.debug('Inside Education Add');
                            }
                        }
                    }
                }
                
                if(expRecTypeNameAndIdMap.containsKey('Professional_Work_Experience')) {
                    
                    String tempJobRole = '';
                    Boolean forCompanyName = false;
                    Boolean forJobRole = false;
                    for(SegregatedExperienceCls workExp : jsonParentClass.ResumeParserData.SegregatedExperience) {
                        forCompanyName = false;
                        forJobRole = false;
                        Experience__c wrk = new Experience__c(RecordTypeId = expRecTypeNameAndIdMap.get('Professional_Work_Experience'));
                        wrk.Name_of_Company__c = workExp.Employer.EmployerName;  // no name of company
                        System.debug('workExp:::::'+workExp);
                        wrk.Intensive_Proficiency_Oriented_Experienc__c = true;
                        if(companyNameWithRoleMap <> NULL){
                            //system.debug('companyNameWithRoleMap:for testclass::'+companyNameWithRoleMap);
                            //system.debug('wrk.Name_of_Company__c:for testclass::'+wrk.Name_of_Company__c);
                            if( companyNameWithRoleMap.Containskey(wrk.Name_of_Company__c) ) {
                                tempJobRole = companyNameWithRoleMap.get(wrk.Name_of_Company__c);
                                forCompanyName = true;
                            }
                        }
                        wrk.Role_Title__c = workExp.JobProfile.Title;   //job profile title
                        //system.debug('tempJobRole::::'+tempJobRole);
                        //system.debug('wrk.Role_Title__c::::'+wrk.Role_Title__c);
                        if(tempJobRole != '' && wrk.Role_Title__c != '' && tempJobRole == wrk.Role_Title__c) {
                            forJobRole = True;
                        }
                        
                        wrk.City__c = workExp.Location.City;
                        wrk.State__c = workExp.Location.State;
                        wrk.Country__c = workExp.Location.Country;

                        String tempSD = workExp.StartDate;
                        if(String.isNotBlank(tempSD)) {
                            List<String> tempSDList = tempSD.split('/');
                            if(tempSDList != null && tempSDList.size() > 2) 
                                wrk.Start_Date__c = Date.parse(tempSDList[1]+'/'+tempSDList[0]+'/'+tempSDList[2]);
                        }
                        String tempED = workExp.EndDate;
                        if(String.isNotBlank(tempED)) {
                            List<String> tempEDList = tempED.split('/');
                            if(tempEDList != null && tempEDList.size() > 2) 
                                wrk.End_Date__c = Date.parse(tempEDList[1]+'/'+tempEDList[0]+'/'+tempEDList[2]);
                        }    
                        
                        wrk.Description__c = workExp.JobDescription;
                        if(resumeTypeToWrapper <> NULL){
                            //System.debug('forCompanyName:::'+forCompanyName);
                            //System.debug('forJobRole:::'+forJobRole);
                            //System.debug('wrk::::::'+wrk);
                            if(!forCompanyName && !forJobRole && resumeTypeToWrapper.containsKey('WorkList')) {
                                resumeTypeToWrapper.get('WorkList').add(new EduOrWorkExperienceWrapperClass(wrk,true,false));
                                //System.debug('Inside Work Exp Add');
                            }
                        }
                    }
                }
            }
            
            if( jsonParentClass.ResumeParserData != null){
                for( SegregatedSkillCls sk : jsonParentClass.ResumeParserData.SegregatedSkill ) {
                    if( resumeTypeToWrapper <> NULL ) {
                        if( resumeTypeToWrapper.containsKey('NewSkillInfoList') ) {
                            if( sk.Type == 'BehaviourSkill' ) {
                                NewSkillsWrapperClass swc = returnSkillsList(sk);
                                if(swc != null && existingSkillSet != null && !existingSkillSet.Contains(swc.skill)) {
                                    resumeTypeToWrapper.get('NewSkillInfoList').add(swc);
                                }
                            }
                        
                            if( sk.Type == 'SoftSkill' ) {
                                NewSkillsWrapperClass swc = returnSkillsList(sk);
                                if(swc != null && existingSkillSet != null && !existingSkillSet.Contains(swc.skill)) {
                                    resumeTypeToWrapper.get('NewSkillInfoList').add(swc);
                                }
                            }
                        
                            if( sk.Type == 'OperationalSkill' ) {
                                NewSkillsWrapperClass swc = returnSkillsList(sk);
                                if(swc != null && existingSkillSet != null && !existingSkillSet.Contains(swc.skill)) {
                                    resumeTypeToWrapper.get('NewSkillInfoList').add(swc);
                                }
                            }
                        }
                    }
                }
            }
            
            // To defaultly set the Account Id for the Contact based on new Requirement - Recruiting Notebook
            System_Values__c DefaultAccId = System_Values__c.getValues('Rchilli_Contact_AccountId');
            if(DefaultAccId != null)
                default_AcctId = DefaultAccId.Value__c;

            List<Account> acc = [SELECT Id,Name FROM Account WHERE Id =: default_AcctId];
            
            if(resumeTypeToWrapper <> NULL){
                if(resumeTypeToWrapper.containsKey('ContactInfo')){
                    String conAcc = contactIns.AccountId;
                    resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Account Name',(conAcc != null ? (contactIns.AccountId +'~'+ contactIns.Account.Name) : ''),default_AcctId+'~'+((acc != null && acc.size() > 0) ? acc[0].Name : '')));             
                }
            }
        }        
        return JSON.serialize(resumeTypeToWrapper);
        
    }    
    
    @RemoteAction
    global static String saveNewRecords(String Cid,String CI,String PI,String QI, String EI, String Skill,String langKnown,String proPublication) {
        Contact con = new Contact();
        String ContactId;
        List<Experience__c> exListToInsert = new List<Experience__c>();
        List<Skill__c> skillList = new List<Skill__c>();
        Map<String,Id> ExpNameWithIdMap = new Map<String,Id>();
        Map<String,Id> expRecTypeNameAndIdMap = new Map<String,Id>();
        Set<Id> langSet = new Set<Id>();
        List<Known_Language__c> knownLanguageListToUpsert = new List<Known_Language__c>();
        List<Professional_Publication_and_Award__c> profPublucationAwardListToUpsert = new List<Professional_Publication_and_Award__c>();
        
        List<Account> accList = new List<Account>();
        String accId;
        
        
        //System.debug('Cid:::'+Cid);
        //System.debug('CI:::'+CI);
        //System.debug('QI:::'+QI);
        System.debug('EI::::'+QI);
        //System.debug('Skill::::'+Skill);
        //System.debug('langKnown::::'+langKnown);
        
         List<ContactInfo> CIwrap = (List<ContactInfo>) System.JSON.deserialize(CI, List<ContactInfo>.class);
         List<ContactInfo> PIwrap = (List<ContactInfo>) System.JSON.deserialize(PI, List<ContactInfo>.class); // For personal Info
         List<EduOrWorkExperienceWrapperClass> QIwrap = (List<EduOrWorkExperienceWrapperClass>) System.JSON.deserialize(QI, List<EduOrWorkExperienceWrapperClass>.class);
         List<EduOrWorkExperienceWrapperClass> EIwrap = (List<EduOrWorkExperienceWrapperClass>) System.JSON.deserialize(EI, List<EduOrWorkExperienceWrapperClass>.class);
         List<SkillsWrapperClass> Skillwrap = (List<SkillsWrapperClass>) System.JSON.deserialize(Skill, List<SkillsWrapperClass>.class);
         List<ProfPublicationAwardsClass> ppaWrap = (List<ProfPublicationAwardsClass>) System.JSON.deserialize(proPublication, List<ProfPublicationAwardsClass>.class);
         List<Known_Language__c> languageKnownList = (List<Known_Language__c>) System.JSON.deserialize(langKnown, List<Known_Language__c>.class);
         for (RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType = 'Experience__c']) {
             expRecTypeNameAndIdMap.put(rt.DeveloperName,rt.Id);
         }
         
         for (ContactInfo c : CIwrap) {
             if(c.conFieldLabel == 'First Name') con.FirstName = c.SelectedValue;
             if(c.conFieldLabel == 'Middle Name') con.MiddleName = c.SelectedValue;
             if(c.conFieldLabel == 'Last Name') con.LastName = c.SelectedValue;
             if(c.conFieldLabel == 'Email') con.Email = c.SelectedValue;
             if(c.conFieldLabel == 'Phone') con.Phone = c.SelectedValue;
             if(c.conFieldLabel == 'Mobile') con.Mobilephone = c.SelectedValue;
             if(c.conFieldLabel == 'Visa Status') con.Citizenship__c = c.SelectedValue;
             if(c.conFieldLabel == 'Street') con.MailingStreet = c.SelectedValue;
             if(c.conFieldLabel == 'City') con.MailingCity = c.SelectedValue;
             if(c.conFieldLabel == 'State') con.MailingState= c.SelectedValue;
             if(c.conFieldLabel == 'Country') con.MailingCountry = c.SelectedValue;
             if(c.conFieldLabel == 'ZipCode') con.MailingPostalCode = c.SelectedValue;
             if(c.conFieldLabel == 'Account Name') con.AccountId = c.SelectedValue; // Newly added on September 15, 2017 by GRK 
             accId = con.AccountId;
        }
         
        for (ContactInfo c : PIwrap) {
            if(c.conFieldLabel == 'Date Of Birth' && c.SelectedValue != null && c.SelectedValue != 'Invalid date') con.Birthdate = Date.ValueOf(c.SelectedValue); // Old Field refers to Date_of_Birth__c.
            if(c.conFieldLabel == 'Gender') con.Gender__c = c.SelectedValue;
            if(c.conFieldLabel == 'License No') con.Driver_s_License__c = c.SelectedValue;
            if(c.conFieldLabel == 'Passport No') con.Non_US_Passport_Country__c = c.SelectedValue;
            if(c.conFieldLabel == 'Visa Status') con.Citizenship__c = c.SelectedValue;
        }
         //system.debug(':::accId::'+accId);
         //system.debug('Cid::'+Cid);
         
         if( Cid != null ) {
             if (Cid != 'NoContact') {
                 con.Id = Cid;                 
             } else {
                 RecordType canRT = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Contact' AND DeveloperName = 'Candidate'];
                 
                 if( canRT != null ) {
                     con.RecordTypeId = canRT.Id;
                 }
                 
             }
             upsert con;
             ContactId = con.Id;
         } 
         
         for ( EduOrWorkExperienceWrapperClass q : QIwrap) {
             if(q.exp.RecordTypeId == null) {
                 q.exp.RecordTypeId = expRecTypeNameAndIdMap.get('Education_Experience');
             }
             if(q.isSelected && q.exp.RecordTypeId == expRecTypeNameAndIdMap.get('Education_Experience')) {
                 q.exp.Contact__c = ContactId;
                 exListToInsert.add(q.exp);
             }
             
         }
         
         for ( EduOrWorkExperienceWrapperClass e : EIwrap) {
             
             if(e.exp.RecordTypeId == null) {
                 e.exp.RecordTypeId = expRecTypeNameAndIdMap.get('Professional_Work_Experience');
             }
             if(e.isSelected && e.exp.RecordTypeId == expRecTypeNameAndIdMap.get('Professional_Work_Experience')) {
                 e.exp.Contact__c = ContactId;
                 if (e.exp.End_Date__c == System.today()) {
                     e.exp.End_Date__c = null;
                 }
                 exListToInsert.add(e.exp);
             }
         }
         
         if( exListToInsert != null && exListToInsert.size() > 0 ) {
             List<Experience__c> upsertedExps = ExperienceService.upsertExperiences(exListToInsert);
         }
         
         List<Experience__c> experienceList = ExperienceService.getExperiencesByRecordTypeDeveloperNameAndContactIdset(new Set<String>{'Professional_Work_Experience'}, new Set<Id>{ContactId});
         for(Experience__c exp : experienceList /*[SELECT Id,Name,Name_of_Company__c,Role_Title__c FROM Experience__c WHERE Contact__c =: ContactId AND RecordType.DeveloperName = 'Professional_Work_Experience']*/) {
             String expName = exp.Name_of_Company__c;
             if(exp.Role_Title__c != null) expName = expName + '_' + exp.Role_Title__c;
             ExpNameWithIdMap.put(expName,exp.Id);
         }
         //System.debug('Skillwrap::::'+Skillwrap);
         //System.debug('ExpNameWithIdMap::::'+ExpNameWithIdMap);
         for (SkillsWrapperClass sk : Skillwrap) {
             if(sk.skl.From_Language_LU__c != null)
                 langSet.add(sk.skl.From_Language_LU__c);
             if(sk.skl.To_Language_LU__c != null)    
                 langSet.add(sk.skl.To_Language_LU__c);
                 
             skill__c newSk = new Skill__c(Contact__c = ContactId,From_Language_LU__c = sk.skl.From_Language_LU__c,To_Language_LU__c = sk.skl.To_Language_LU__c,Skill__c = sk.skl.Skill__c,Skill_Verification__c = sk.skl.Skill_Verification__c,Rating__c = sk.skl.Rating__c);
             if(sk.skl.Id != null) {
                 newSk.Id = sk.skl.Id;
             }
             skillList.add(newSk);
             //System.debug('skillList::::'+skillList);
         }
         Set<Id> existKnownLangSet = new Set<Id>();
         for ( Known_Language__c lk : languageKnownList) {  
             if(Cid == 'NoContact') {           
                 lk.Contact__c = ContactId; 
             } 
             existKnownLangSet.add(lk.Language__c);           
             knownLanguageListToUpsert.add(lk);
         }
        
        for(ProfPublicationAwardsClass ppa : ppaWrap){
            ppa.ppa.Contact__c = ContactId;              
            profPublucationAwardListToUpsert.add(ppa.ppa);
        }
    
         // To Create Known Language Record from Skill Record
         for (Id l : langSet) {
             if(existKnownLangSet != null && !existKnownLangSet.Contains(l)) {
                 Known_Language__c newKL = new Known_Language__c(Contact__c = ContactId,Language__c = l,Contact_with_Language_Id__c=ContactId+l);
                 knownLanguageListToUpsert.add(newKL);
             }
         }
         
         if( skillList != null && skillList.size() > 0 ) {
             Upsert skillList; 
         }
         
         List<Known_Language__c> knownLangList = new List<Known_Language__c>();
         if( knownLanguageListToUpsert != null && knownLanguageListToUpsert.size() > 0 ) {
             knownLangList = KnownLanguageService.upsertKnownlanguage(knownLanguageListToUpsert);
         }

        if( profPublucationAwardListToUpsert != null && profPublucationAwardListToUpsert.size() > 0 ) {
            upsert profPublucationAwardListToUpsert;
         }
                 
         return ContactId;
    }
    
     // Get Lookup record values for Sobject
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        return LibraryContentSearch.getLookupRecords(objectName,searchString,condition);
        //return SObjectQueryService.getLookupRecords(objectName,searchString,condition);
    }
    public Static ContactInfo contactInfoFormationStatic( String lbl, String dbVal, String rsVal) {
                
        ContactInfo ci = new ContactInfo();
        ci.conFieldLabel = lbl;
        ci.conFieldValue = dbVal;
        ci.resumeFieldValue = rsVal;
        ci.optionName = lbl;
        ci.choice1 = lbl.replaceAll( '\\s+', '');
        if((dbVal != null && rsVal != null && rsVal != '') || (rsVal != null && rsVal != '')) {
            
            ci.SelectedValue = rsVal;
        } else if(dbVal != null) {
            ci.SelectedValue = dbVal;
        }
        return ci;
    }
    
    public static NewSkillsWrapperClass returnSkillsList(SegregatedSkillCls skSet){
        
        NewSkillsWrapperClass sw = new NewSkillsWrapperClass();
        sw.Skill = skSet.Skill;
        sw.ExperienceInMonths = String.ValueOf(skSet.ExperienceInMonths);
        return sw;
    }
    
    Global Class ContactInfo{       
        public String choice1;
        public String choice2;
        public String conFieldLabel;
        public String optionName;
        public String conFieldValue;
        public String resumeFieldValue;
        public String SelectedValue;
        public Boolean checkedVal;
    }
     
    Global Class NewSkillsWrapperClass {
        public Boolean isSelected;
        public String Skill;
        public String ExperienceInMonths;
    }
    
    Global Class SkillsWrapperClass {
        public Skill__c skl;
        public Boolean toLangDisabled;
        
        SkillsWrapperClass(Skill__c skil,Boolean dis) {
            skl = skil;
            toLangDisabled = dis;
        }
    }
    
    Global Class EduOrWorkExperienceWrapperClass {
        public Experience__c exp;
        public Boolean isNew;
        public Boolean isSelected;
        EduOrWorkExperienceWrapperClass (Experience__c e, Boolean n, Boolean s) {
            exp = e;
            isNew = n;
            isSelected = s;
        }
    }
    Global Class ProfPublicationAwardsClass {
        public Professional_Publication_and_Award__c ppa;
        public ProfPublicationAwardsClass(Professional_Publication_and_Award__c e) {
            this.ppa = e;
        }
    }
    
    
    global class jsonResponseWrapperClass{
        global ResumeParserDataCls ResumeParserData = new ResumeParserDataCls();
    }
    
    global class ResumeParserDataCls{
        global String ResumeFileName;
        global languageCls ResumeLanguage;
        global String ParsingDate;
        global ResumeCountryCls ResumeCountry;
        global NameCls Name; 
        global String DateOfBirth;
        global String Gender;
        global String FatherName;
        global String MotherName;
        global String MaritalStatus;
        global String Nationality;
        global List<languageCls> LanguageKnown;
        global String UniqueID;
        global String LicenseNo;
        global PassportDetailCls PassportDetail;
        global String PanNo;
        global String VisaStatus;
        global List<EmailCls> Email;
        global List<PhoneNumberCls> PhoneNumber;
        global List<WebSiteCls> WebSite;
        global List<AddressCls> Address;
        global String Category;
        global String SubCategory;
        global SalaryCls CurrentSalary;
        global SalaryCls ExpectedSalary;
        global String Qualification;
        global List<QualificationCls> SegregatedQualification;
        global String Certification;
        global List<SegregatedCertificationCls> SegregatedCertification;
        global String SkillBlock;
        global String SkillKeywords;
        global List<SegregatedSkillCls> SegregatedSkill;
        global String Experience;
        global List<SegregatedExperienceCls> SegregatedExperience;
        global String CurrentEmployer;
        global String JobProfile;
        global WorkedPeriodCls WorkedPeriod;
        global String GapPeriod;
        global String AverageStay;
        global String LongestStay;
        global String Summary;
        global String ExecutiveSummary;
        global String ManagementSummary;
        global String Coverletter;
        global String Publication;
        global List<SegregatedPublicationCls> SegregatedPublication;
        global List<LocationCls> CurrentLocation;
        global List<LocationCls> PreferredLocation;
        global String Availability;
        global String Hobbies;
        global String Objectives;
        global String Achievements;
        global List<SegregatedAchievementCls> SegregatedAchievement;
        global String References;
        global String CustomFields;
        global EmailInfoCls EmailInfo;
        global List<RecommendationCls> Recommendations;
        global String DetailResume;
        global String HtmlResume;
        global CandidateImageCls CandidateImage;
        global TemplateOutputCls TemplateOutput;
        global ApiInfoCls ApiInfo;
    }
    global class languageCls{
        global String language;
        global String LanguageCode;
    }
    global class ResumeCountryCls{
        global String Country;
        global String Evidence;
        global CountryCodeCls CountryCode;
    }
    global class CountryCodeCls{
        global String IsoAlpha2;
        global String IsoAlpha3;
        global String UNCode;
    }
    global class NameCls{
        global String FullName;
        global String TitleName;
        global String FirstName;
        global String MiddleName;
        global String LastName;
        global String FormattedName;
        global Integer ConfidenceScore;
    }
    global class PassportDetailCls{
        global String PassportNumber;
        global String DateOfExpiry;
        global String DateOfIssue;
        global String PlaceOfIssue;
    }
    global class EmailCls{
        global String EmailAddress;
        global Integer ConfidenceScore;
    }
    global class PhoneNumberCls{
        global String Number_x;
        global String ISDCode;
        global String OriginalNumber;
        global String FormattedNumber;
        global String Type;
        global Integer ConfidenceScore;
    }
    global class WebSiteCls{
        global String Type;
        global String Url;
    }
    global class AddressCls{
        global String Street;
        global String City;
        global String State;
        global String StateIsoCode;
        global String Country;
        global CountryCodeCls CountryCode;
        global String ZipCode;
        global String FormattedAddress;
        global String Type;
        global Integer ConfidenceScore;
    }
    global class SalaryCls{
        global String Amount;
        global String Symbol;
        global String Currency_x;
        global String Unit;
        global String Text;
    }
    global class QualificationCls{
        global InstitutionCls Institution;
        global DegreeCls Degree;
        global String FormattedDegreePeriod;
        global String StartDate;
        global String EndDate;
        global AggregateCls Aggregate; 
    }
    global class InstitutionCls{
        global String Name;
        global String Type;
        global LocationCls Location;
        global Integer ConfidenceScore;
    }
    global class LocationCls{
        global String City;
        global String State;
        global String StateIsoCode;
        global String Country;
        global CountryCodeCls CountryCode;
    }
    global class DegreeCls{
        global String DegreeName;
        global String NormalizeDegree;
        global List<String> Specialization;
        global Integer ConfidenceScore;
    }
    global class AggregateCls{
        global String Value;
        global String MeasureType;
    }
    global class SegregatedCertificationCls{
        global String CertificationTitle;
        global String Authority;
        global String CertificationCode;
        global String IsExpiry;
        global String StartDate;
        global String EndDate;
        global String CertificationUrl;
    }
    global class SegregatedSkillCls{
        global String Type;
        global String Skill;
        global String Ontology;
        global String Alias;
        global String FormattedName;
        global String Evidence;
        global String LastUsed;
        global Integer ExperienceInMonths;
        
    }
    global class SegregatedExperienceCls{
        global EmployerCls Employer;
        global JobProfileCls JobProfile;
        //global List<RelatedSkillsCls> RelatedSkills;
        global LocationCls Location;
        global String JobPeriod;
        global String FormattedJobPeriod;
        global String StartDate;
        global String EndDate;
        global String IsCurrentEmployer;
        global String JobDescription;
        global List<ProjectsCls> Projects;
    }
    global class EmployerCls{
        global String EmployerName;
        global String FormattedName;
        global Integer ConfidenceScore;
    }
    global class JobProfileCls{
        global String Title;
        global String FormattedName;
        global String Alias;
        global List<RelatedSkillsCls> RelatedSkills;
        global Integer ConfidenceScore;
    }
    global class RelatedSkillsCls{
        global String Skill;
        global String ProficiencyLevel;
    }
    global class ProjectsCls{
        global String UsedSkills;
        global String ProjectName;
        global String TeamSize;
    }
    global class WorkedPeriodCls{
        global String TotalExperienceInMonths;
        global String TotalExperienceInYear;
        global String TotalExperienceRange;
    }
    global class SegregatedPublicationCls{
        global String PublicationTitle;
        global String Publisher;
        global String PublicationNumber;
        global String PublicationUrl;
        global String Authors;
        global String Description;
    }
    global class SegregatedAchievementCls{
        global String AwardTitle;
        global String Issuer;
        global String AssociatedWith;
        global String IssuingDate;
        global String Description;
    }
    global class EmailInfoCls{
        global String EmailTo;
        global String EmailBody;
        global String EmailReplyTo; 
        global String EmailSignature; 
        global String EmailFrom;
        global String EmailSubject;
        global String EmailCC;
    }
   
    global class RecommendationCls{
        global String CompanyName;
        global String PersonName;
        global String Relation;
        global String PositionTitle;
        global String Description;
    }
    global class CandidateImageCls{
        global String CandidateImageData;
        global String CandidateImageFormat;
    }
    
    global class TemplateOutputCls{
        global String TemplateOutputFileName;
        global String TemplateOutputData;
    }
    global class ApiInfoCls{
        global String Metered;
        global String CreditLeft;
        global String AccountExpiryDate;
        global String BuildVersion;
    }
    
    @RemoteAction
    global static Map<String,List<Object>> editProfile(String contactId, String type ) {
        List<Contact> cons = SObjectQueryService.SObjectQuery('Contact', new Set<Id>{contactId},'');
        
        Map<String, List<Object>> resumeTypeToWrapper = new Map<String, List<Object>>();
        resumeTypeToWrapper.put('EducationList',new List<EduOrWorkExperienceWrapperClass>());
        resumeTypeToWrapper.put('WorkList',new List<EduOrWorkExperienceWrapperClass>());
        resumeTypeToWrapper.put('LanguageKnownList', new List<Known_Language__c>());
        resumeTypeToWrapper.put('ContactInfo',new List<ContactInfo>{});
        resumeTypeToWrapper.put('PersonalInfo',new List<ContactInfo>{});
        resumeTypeToWrapper.put('SkillInfoList', new List<SkillsWrapperClass>());
        resumeTypeToWrapper.put('NewSkillInfoList',new List<NewSkillsWrapperClass>{});
        resumeTypeToWrapper.put('BookMarkList',new List<BookMark__c>());
        resumeTypeToWrapper.put('ProfPublicationAwardsList',new List<ProfPublicationAwardsClass>());

        
        System.debug('resumeTypeToWrapper::::::'+resumeTypeToWrapper);
        List<Experience__c> expList = ExperienceService.getExperiencesByRecordTypeDeveloperNameAndContactIdset(new Set<String>{'Education_Experience', 'Professional_Work_Experience'}, new Set<Id>{contactId} );           
        for ( Experience__c ex : expList ) {//[SELECT Id,Name,College_School__c,College_School_Type__c,Degree__c,Contact__c,Degree_Level__c,Field_of_Concentration__c,Year_of_Completion__c,Description__c,End_Date__c,Experience_in_Months__c,Name_of_Company__c,Role_Title__c,Start_Date__c,Services__c,City__c,State__c,Country__c,Aggregate__c,RecordTypeId,RecordType.DeveloperName FROM Experience__c WHERE Contact__c =: contactId AND ( RecordType.DeveloperName = 'Education_Experience' OR RecordType.DeveloperName = 'Professional_Work_Experience' )]) 
            if( ex.RecordType.DeveloperName == 'Education_Experience' ) {
                collegeNameWithDegreeMap.put(ex.College_School__c,ex.Degree__c);
                
                if(String.isNotBlank(ex.year_of_completion__c)) {
                    List<String> tempSDList = ex.year_of_completion__c.split('/');
                    if(tempSDList != null && tempSDList.size() > 2) 
                        ex.Year_of_Completion__c = tempSDList[2];
                }
                
                if(resumeTypeToWrapper <> NULL){
                    if(resumeTypeToWrapper.containsKey('EducationList'))
                        resumeTypeToWrapper.get('EducationList').add(new EduOrWorkExperienceWrapperClass(ex,false,true));
                }
            } 
            if( ex.RecordType.DeveloperName == 'Professional_Work_Experience' ) {
                companyNameWithRoleMap.put(ex.Name_of_Company__c,ex.Role_Title__c);
                if(resumeTypeToWrapper <> NULL){
                    if(resumeTypeToWrapper.containsKey('WorkList'))
                        resumeTypeToWrapper.get('WorkList').add(new EduOrWorkExperienceWrapperClass(ex,false,true));
                }    
            }            
        }        
                    
        if(resumeTypeToWrapper.containsKey('ContactInfo') && type == 'Edit') {
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('First Name', cons[0].FirstName,cons[0].FirstName));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Middle Name', cons[0].Middlename,cons[0].Middlename));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Last Name', cons[0].LastName,cons[0].LastName));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Email', cons[0].Email,cons[0].Email));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Phone', cons[0].Phone,cons[0].Phone )); // HomePhone
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Mobile', cons[0].MobilePhone,cons[0].MobilePhone));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Street',string.ValueOf(cons[0].MailingStreet),string.ValueOf(cons[0].MailingStreet)));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('City', cons[0].MailingCity,cons[0].MailingCity));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('State', cons[0].MailingState,cons[0].MailingState));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('Country', cons[0].MailingCountry,cons[0].MailingCountry));
            resumeTypeToWrapper.get('ContactInfo').add(contactInfoFormationStatic('ZipCode', cons[0].MailingPostalCode,cons[0].MailingPostalCode));
        }
        
        if(resumeTypeToWrapper.containsKey('PersonalInfo') && type == 'Edit'){
            resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('Date Of Birth', String.ValueOf(cons[0].Birthdate),String.ValueOf(cons[0].Birthdate)));
            resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('Gender', cons[0].Gender__c,cons[0].Gender__c));
            resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('LicenseNo', cons[0].Driver_s_License__c,cons[0].Driver_s_License__c));
            resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('PassportNo', cons[0].Non_US_Passport_Country__c,cons[0].Non_US_Passport_Country__c));
            resumeTypeToWrapper.get('PersonalInfo').add(contactInfoFormationStatic('VisaStatus', cons[0].Citizenship__c,cons[0].Citizenship__c));
        } 
        
        if(!resumeTypeToWrapper.containskey('LanguageList')) {
            resumeTypeToWrapper.put('LanguageList', new List<Language__c>());
            List<Language__c> langList = LanguageService.getLanguages(' ORDER BY Name');
                        
            for (Language__c l : langList) {
                if(resumeTypeToWrapper <> NULL){
                    if(resumeTypeToWrapper.containsKey('LanguageList'))
                        resumeTypeToWrapper.get('LanguageList').add(l);
                }
            }
        }
        
        List<Known_Language__c> knownLangList = KnownLanguageService.getKnownlanguage(' WHERE Contact__c = \''+contactId+'\' ORDER BY Language__r.Name','');
                
        for(Known_Language__c kl : knownLangList) {
            if(resumeTypeToWrapper <> NULL) {
                if(resumeTypeToWrapper.containsKey('LanguageKnownList'))
                    resumeTypeToWrapper.get('LanguageKnownList').add(kl);
            }
        }
        Set<String> existingSkillSet = new Set<String>();
        List<Skill__c> skills = SkillService.getSkillRecbyId(' WHERE Contact__c',',To_Language_LU__r.Name',new Set<Id>{contactId});
        //for (Skill__c s : [SELECT Id,Skill__c,From_Language__c,Skill_Verification__c,To_Language__c,To_Language_Language_Testing__c,From_Language_LU__c,To_Language_LU__c,To_Language_LU__r.Name FROM Skill__c WHERE Contact__c =: contactId]) {
        for(Skill__c s : skills) {
            if(existingSkillSet <> NULL) 
                existingSkillSet.add(s.Skill__c);
            Boolean disableToLan = false;
            if(s.Skill__c == 'Curriculum Development' || s.Skill__c == 'Language Training' || s.Skill__c == 'Testing'){ // Commented By Dhinesh - 07/08/23 - Fix to language should be disabled // && s.To_Language_LU__r.Name == 'English') {
                disableToLan = true;
            }
            if(resumeTypeToWrapper <> NULL){
                if(resumeTypeToWrapper.containsKey('SkillInfoList'))
                    resumeTypeToWrapper.get('SkillInfoList').add(new SkillsWrapperClass(s,disableToLan));
            }
        }
        
        List<Professional_Publication_and_Award__c> existingProfPublicationAwards = ProfessionalPublicationAwardService.getProfPublicationAwards(' WHERE Contact__c = \''+contactId+'\' ORDER BY CreatedDate','');                                    																	

        for(Professional_Publication_and_Award__c ppa : existingProfPublicationAwards){
            if(resumeTypeToWrapper <> NULL){
                if(resumeTypeToWrapper.containsKey('ProfPublicationAwardsList'))
                    resumeTypeToWrapper.get('ProfPublicationAwardsList').add(new ProfPublicationAwardsClass(ppa));
            }
        }
        
        // To query the Bookmark records
        List<BookMark__c> bm = [SELECT Id,Name,User__c,Contact__c FROM BookMark__c WHERE User__c =: userinfo.getuserid() AND Contact__c =:contactId ];
        if(resumeTypeToWrapper.containsKey('BookMarkList')) {
            if( bm != null && bm.size() > 0 ) {
                resumeTypeToWrapper.get('BookMarkList').add(bm);
            } 
        }
        return resumeTypeToWrapper;
    }
 
}