/**
* @description       :This class is used for DLS carrier community page
* @author            : Siva Prasanth
* @last modified on  : 06/20/2023
* @last modified by  : Siva Prasanth
**/

// Get the initial job details informations
public without sharing class JobCommunityHomePage_Ctrl { 
    
    @AuraEnabled(cacheable = true)
    public static List<bpats__Job__c> getJobDetails(String jobId){
        List<bpats__Job__c> jobList = new List<bpats__Job__c>();
        String jobQueryStr;
        
        try{
            jobQueryStr = 'SELECT Id,Name,bpats__Job_Title__c,bpats__Posted_Date__c,bpats__Job_Description__c,Location__c FROM bpats__Job__c';
            jobQueryStr += ' WHERE bpats__Job_Title__c != null AND bpats__Status__c =\'Open\''; 
            
            if(String.isNotBlank(jobId)){
                jobQueryStr += ' AND Id = \''+jobId+'\'';
            }
            jobList = Database.query(jobQueryStr);
            return jobList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Create the appicant and contacts along with file uploadss
    @AuraEnabled
    public static void createJobAndContacts(String conJSON, String fileUploadInfoJSON, String jobId){
        List<Contact> cons = (List<Contact>) JSON.deserialize(conJSON, List<Contact>.class);
        List<bpats__ATS_Stage__c> stage = new List<bpats__ATS_Stage__c>();
        List<Contact> existingCon = new List<Contact>();
        List<Account> dlsCandidateAccs = new List<Account>();
        Map<Id,String> boxRecIdsMap = new Map<Id,String>();
        String folderId = null;
        String folderName = null;
        
        try{
            if(cons.size() > 0 && String.isNotBlank(jobId)){
                stage = [SELECT Id FROM bpats__ATS_Stage__c WHERE bpats__Job__c = :jobId AND Name = 'Application' ORDER BY CreatedDate DESC LIMIT 1];
                existingCon = [SELECT Id,AccountId FROM Contact WHERE FirstName = :cons[0].FirstName AND LastName = :cons[0].LastName AND Email = :cons[0].Email];
                dlsCandidateAccs = [SELECT Id,Name FROM Account WHERE Name = 'DLS - Candidate' LIMIT 1];
                Id conRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
                
                
                if(cons[0].FirstName != null && cons[0].LastName != null){
                    folderName = cons[0].FirstName+' '+ cons[0].LastName;
                    
                    /* Resume File upload for Folder Creation */
                    if(folderName != null){
                        folderId = createFolder(folderName);
                    }
                }
                
                if(conRecTypeId != null){// Upsert contact with Candidate Record Type 
                    cons[0].RecordTypeId = conRecTypeId;
                }
                
                if(dlsCandidateAccs.size() > 0){
                    if((existingCon.size() > 0 && existingCon[0].AccountId != dlsCandidateAccs[0].Id) || existingCon.size() == 0){
                        cons[0].AccountId = dlsCandidateAccs[0].Id;
                    }
                }
                
                if(existingCon.size() > 0){// Contact Upsertion
                    cons[0].Id = existingCon[0].Id;
                }else{
                    cons[0].Last_Availability_Update__c = System.Today();
                }
                
                upsert cons;
                
                if(cons[0].Id != null){
                    Id appRecId = null;
                    if(!boxRecIdsMap.containsKey(cons[0].Id)){
                        boxRecIdsMap.put(cons[0].Id,'Contact');
                    }
                    
                    List<bpats__ATS_Applicant__c> existingJobApp = [SELECT Id FROM bpats__ATS_Applicant__c WHERE bpats__ATS_Applicant__c = :cons[0].Id AND bpats__Job__c = :jobId];
                    
                    // Job Applicant insertion
                    if(existingJobApp.size() == 0){
                        bpats__ATS_Applicant__c applicant = new bpats__ATS_Applicant__c();
                        applicant.bpats__ATS_Applicant__c = cons[0].Id;
                        applicant.bpats__Job__c = jobId;
                        
                        if(stage.size() > 0){
                            applicant.bpats__Stage__c = stage[0].Id;
                        }
                        insert applicant;
                        if(applicant.Id != null){
                            appRecId = applicant.Id;
                        }
                    }else{
                        appRecId = existingJobApp[0].Id;
                    }
                    
                    // Upload the Resume file to salesforce
                    uploadfilesToSalesforce(fileUploadInfoJSON,appRecId,cons[0].Id);

                    if(!boxRecIdsMap.containsKey(appRecId)){
                        boxRecIdsMap.put(appRecId,'bpats__ATS_Applicant__c');
                    }

                    if(folderId != null && boxRecIdsMap.size() > 0){// Insertion of Box FRUP Record
                        Set<Id> boxRecIds = new Set<Id>();
                        
                        for(box__FRUP__c frup : [SELECT Id,box__Record_ID__c FROM box__FRUP__c WHERE box__Folder_ID__c = :folderId AND box__Record_ID__c IN :boxRecIdsMap.keySet() AND box__Object_Name__c IN :boxRecIdsMap.values()]){
                            boxRecIds.add(frup.box__Record_ID__c); 
                        }
                        
                        for(Id boxId : boxRecIdsMap.keySet()){
                            if(!boxRecIds.contains(boxId)){
                                GenericUrlLaunch_Ctrl.createBoxFRUPRecs(JSON.serialize(new box__FRUP__c(box__Folder_ID__c = folderId, box__Record_ID__c = boxId, box__Permission__c = 'Read/Write', box__Object_Name__c = boxRecIdsMap.get(boxId))));
                            }
                        }
                        
                        //File upload to Box folder in future call
                        LessonPlanBoxUtil.uploadFilesAsync(fileUploadInfoJSON ,folderId);
                    }
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    // Get the folderId from box folder
    @AuraEnabled
    public static String createFolder(String folderName){
        String parentFolderId = '';
        String folderId = '';
        List<box__Folder_Details__c> boxDetails = [SELECT box__FolderId__c FROM box__Folder_Details__c WHERE Name = 'contacts'];
        
        if(boxDetails.size() > 0){
            parentFolderId = boxDetails[0].box__FolderId__c;
        }
        String accessToken = LessonPlanBoxUtil.getAccessToken();
        System.debug(accessToken);
        System.debug('parentFolderId'+parentFolderId);
        String body = '{ "name": "' +folderName+ '", "parent": { "id": "' +parentFolderId+ '" }}';
        System.debug('body'+body);
        String endpoint = 'https://api.box.com/2.0/folders';
        
        // define transaction variables
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setBody(body);
        //req.setTimeout(120000);
        res = h.send(req);
        System.debug('res: '+res);
        System.debug('res.getBody(): '+res.getBody());
        
        if ((res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
            Map<String, Object> untypedMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            folderId = String.valueOf(untypedMap.get('id'));
        }else if(res.getStatusCode() == 409){
            BoxUtilDomain.BodyWrapper wrapperList = (BoxUtilDomain.BodyWrapper)System.JSON.deserialize(res.getBody(),BoxUtilDomain.BodyWrapper.class);
            folderId = wrapperList.context_info.conflicts[0].id;
        }else{
            LessonPlanBoxUtil.createErrorLog('createFolder',res.getBody());
            throw new AuraHandledException('Error while creating folder ' + res.getBody());
        }
        return folderId;
    }
    @AuraEnabled
    public static void uploadfilesToSalesforce(String filesDetails,String applicantId,String contactId){
        List<ContentVersion> conVer = new List<ContentVersion>();
        List<ContentDocumentLink> conDocs = new List<ContentDocumentLink>();
        List<BoxUtilDomain.FilesWrapper> filesWrapper = (List<BoxUtilDomain.FilesWrapper>)JSON.deserialize(filesDetails , List<BoxUtilDomain.FilesWrapper>.class);
        Set<Id> conVerIds = new Set<Id>();        
        
        for(BoxUtilDomain.FilesWrapper wrapperInstance : filesWrapper){
            String[] fileNameInfo = (wrapperInstance.fileName).split('\\.');
            String fileName = null;
            
            if(fileNameInfo.size() > 0){
                fileName = fileNameInfo[0];
                if(!(fileNameInfo[0].contains('Resume') || fileNameInfo[0].contains('resume'))){
                    fileName = fileName + '_Resume';
                }
            }
            
            if(wrapperInstance.isResumeType == true){
                ContentVersion v = new ContentVersion();
                v.versionData = EncodingUtil.base64Decode(wrapperInstance.base64);
                v.title = fileName;
                v.pathOnClient = wrapperInstance.fileName;
                conVer.add(v);
            }
        }
        
        if(conVer.size() > 0){
            insert conVer;
            
            for(ContentVersion cv : conVer){
                conVerIds.add(cv.Id);
            }
            System.debug('::applicantId::'+applicantId);
            // First get the content document Id from ContentVersion
            for(ContentVersion cv : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :conVerIds]){
                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink(); 
                cDe.ContentDocumentId = cv.ContentDocumentId;
                cDe.ShareType = 'V';
                cDe.LinkedEntityId = applicantId; // you can use objectId,GroupId etc
                cDe.Visibility = 'AllUsers';
                conDocs.add(cDe); 
                
                ContentDocumentLink cDe2 = new ContentDocumentLink(); 
                cDe2.ContentDocumentId = cv.ContentDocumentId;
                cDe2.ShareType = 'V';
                cDe2.LinkedEntityId = contactId; // you can use objectId,GroupId etc
                cDe2.Visibility = 'AllUsers';
                conDocs.add(cDe2); 
            }
            
            if(conDocs.size() > 0){
                insert conDocs;  
            }
        }
    }
    /* Get Community Name*/
    @AuraEnabled
    public static string getCommunityName(){
        return EventCalendarController.getCommunityPathPrefix();
    }
}