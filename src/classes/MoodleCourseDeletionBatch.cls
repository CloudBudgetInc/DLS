/***********************
    - W-007955 : Adjust Moodle Course Delete to Fit OpenLMS Requirements
    - To perform moodle course delete action
    - This batch class is invoked from MoodleCourseDeletion_Scheduler
    **************************/
public class MoodleCourseDeletionBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

    public List<AcctSeed__Project__c> updateAllProjects = new List<AcctSeed__Project__c>();
    public List<ErrorHandler.ErrorLogUtilDomain> errorlogs  = new List<ErrorHandler.ErrorLogUtilDomain>();
    public List<Sync_Log__c> createSyncLogs = new List<Sync_Log__c>(); 

    public Database.QueryLocator start(Database.BatchableContext bc){
        
        Date endDate = Date.Today().addYears(-1);
        
        // Query the projects with end date less than one year
        String projQuery = 'SELECT Id, Name, AcctSeed__Status__c, Course_Name__c, Course_Start_Date__c, DLS_Ref__c, End_Date__c, Language_Name__c, Materials_Request__c, Moodle_Course_Id__c, Moodle_Sync_Status__c, Start_Date__c';
        projQuery += ' FROM AcctSeed__Project__c';
        projQuery += ' WHERE End_Date__c <= : endDate AND Moodle_Course_Id__c != null AND Moodle_Sync_Status__c NOT IN (\'Deleted\') AND AcctSeed__Status__c IN (\'Canceled\', \'Ended\')';
        
        if(Test.isRunningTest()){
            projQuery += ' LIMIT 1';
        }
        return Database.getQueryLocator(projQuery);
    }

    public void execute(Database.BatchableContext bc, List<AcctSeed__Project__c> projects){
       
        if(!projects.isEmpty()){          
            // Should process one record per execution
            makeCallout(projects[0]);
        }
    }

    public void finish(Database.BatchableContext bc){
        
        try{
            // Project's Moodle Sync Status updation
            if(!updateAllProjects.isEmpty()){
                update updateAllProjects;
            }
            // Sync Log records creation for both Success and Failure responses
            if(!createSyncLogs.isEmpty()){
                insert createSyncLogs;
            }
            // Publish Platform Events
            if(!errorlogs.isEmpty()){
                ErrorHandler.publishErrorLog(errorlogs);
            }
        }catch(Exception ex){
            String result = ex.getMessage() + ' at line number '+ ex.getLineNumber();  
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('MoodleCourseDeletiontBatch','finish','',result,'','Batch')});
        }   
    }
    
    public void makeCallout(AcctSeed__Project__c projRec){
        
        try{
        
            String endpointUrl = 'https://lms.dlsdc.com/webservice/rest/server.php?wstoken=' + Label.MoodleCourseDeletionKey + '&wsfunction=core_course_delete_courses&moodlewsrestformat=json&courseids[0]=' + projRec.Moodle_Course_Id__c; 
            
            Http http = new Http();
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setTimeout(120000);
    
            HttpResponse res = http.send(req);
                          
            String moodleSyncStatus;
            String syncLogStatus;
            String errorMessage;
            
            if(res.getStatusCode() == 200){
                
                if(res != null){
                    
                    ResponseWrapper res_Wrap = (ResponseWrapper)JSON.deserialize(res.getBody(), ResponseWrapper.class);
                    
                    List<warnings_Wrap> warning_Wrap = res_Wrap.warnings;
                    
                    if(res_Wrap.errorcode == null && res_Wrap.message == null){
                        
                        if(res_Wrap.warnings != null){
                            
                            if(res_Wrap.warnings.isEmpty()){
                                
                                // Sample Response Body: {"warnings":[]}
                                moodleSyncStatus = 'Deleted';
                                syncLogStatus = 'Success'; 
                            }else if(!res_Wrap.warnings.isEmpty() && warning_Wrap[0].message != null){
                                
                                // Course deleted in moodle but in salesforce receiving an error like "Response Code: 504 Response Status: Gateway Time-out"
                                // @ 1'st time project's moodle sync status updated as Delete (Sync log will be created with Failed status) "Response Code: 504 Response Status: Gateway Time-out"
                                // @ 2'nd time project's moodle sync status updated as Deleted (Sync log will be created with Success status) when the Delete Status Course receives "unknownCourseId" exception
                                if(projRec.Moodle_Sync_Status__c == 'Delete' && warning_Wrap[0].warningcode == 'unknowncourseidnumber' && warning_Wrap[0].message.toLowerCase().contains('unknown course id')){
                                    moodleSyncStatus = 'Deleted';
                                    syncLogStatus = 'Success';
                                }else{
                                    // Sample Response Body: {"warnings":[{"item":"course","itemid":3176,"warningcode":"unknowncourseidnumber","message":"Unknown course ID 3176"}]}
                                    moodleSyncStatus = 'Failure';
                                    syncLogStatus = 'Failed';
                                    errorMessage = 'Warning Code: ' + warning_Wrap[0].warningcode + ' Warning Message: ' + warning_Wrap[0].message;
                                }
                            }
                        }
                    }else{  
                        // Sample Response Body: {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected"}
                        moodleSyncStatus = 'Failure';
                        syncLogStatus = 'Failed';
                        errorMessage = 'Error Code: ' + res_Wrap.errorcode + ' Error Message: ' + res_Wrap.message;
                    }
                }
            }else{
                // Added on Feb 09 2024 : To exclude this record being processed for Moodle Course Archieve or Delete when status is updated to Failure on Delete process on getting Gateway Timeout Exception
                // In next run the delete status will be processed only for Course Deletion and on getting "unknown Course Id", the course is considered as Deleted and status updated as Deleted
                // When Course deletion action takes more time, salesforce receives an following error "Response Code: 504 Response Status: Gateway Time-out"
                // @ 1'st time project's moodle sync status updated as Delete (Sync log will be created with Failed status) 
                if(res.getStatusCode() == 504 && res.getStatus().toLowerCase().contains('gateway time-out')){
                    moodleSyncStatus = 'Delete';
                    syncLogStatus = 'Failed';
                }else{
                    moodleSyncStatus = 'Failure';
                    syncLogStatus = 'Failed';
                    errorMessage = 'Response Code: ' + res.getStatusCode() + ' Response Status: ' + res.getStatus();
                }
            }
            
            AcctSeed__Project__c updateProj = new AcctSeed__Project__c(Id = projRec.Id, Moodle_Sync_Status__c = moodleSyncStatus);
            updateAllProjects.add(updateProj);
            
            Sync_Log__c syncLog = new Sync_Log__c(Action__c = 'Delete Course', Error_Message__c = errorMessage, Project__c = projRec.Id, Status__c = syncLogStatus, Timestamp__c = System.Now());
            createSyncLogs.add(syncLog);
            
        }catch(Exception ex){
           String result = ex.getMessage() + ' at line number '+ ex.getLineNumber();  
           errorlogs.add(new ErrorHandler.ErrorLogUtilDomain('MoodleCourseDeletiontBatch','makeCallout','',result,'','Batch'));
        }     
    }
    
    public class ResponseWrapper{

        public List<warnings_Wrap> warnings;
        public String errorcode;       
        public String message;      
    }
    
    public class warnings_Wrap{
        public String item;     
        public Integer itemid;      
        public String warningcode;     
        public String message;      
    }
}