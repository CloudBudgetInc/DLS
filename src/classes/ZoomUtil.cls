/*******************************************************************************
- class for Zoom util methods for creating users, meeting etc.
- This will be called from apex class, Trigger
- Created by Dhinesh - W-006013 - Zoom Integration
*******************************************************************************/
public class ZoomUtil {
    
    public static String getJWT(){
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://zoom.us/oauth/token?grant_type=account_credentials&account_id='+ Label.zoomAccountId); 
        req2.setMethod('POST');        
        req2.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(Label.zoomClientId + ':' + Label.zoomClientSecret))); 
        req2.setTimeout(120000);         
        HttpResponse res = http.send(req2);
        String resultBody = res.getBody();
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultBody);        
        return String.valueOf(result.get('access_token'));
        
    }
    
    @auraEnabled
    public static String createUser(String requestJson){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/users'); 
        req2.setMethod('POST');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept', 'application/json');
        req2.setBody(requestJson);
        req2.setTimeout(120000);
        
        HttpResponse res = http.send(req2);
        result = res.getBody();
        
        if(res.getStatusCode() == 201){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }

    @auraEnabled
    public static String updateUser(String userId, String requestJson){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/users/'+userId);
        req2.setMethod('PATCH');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept', 'application/json');
        req2.setBody(requestJson);
        req2.setTimeout(120000);
        
        HttpResponse res = http.send(req2);
        result = res.getBody();
        
        if(res.getStatusCode() == 204){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }
    
    public static String unlinkUser(String userEmail){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/users/'+userEmail); 
        req2.setMethod('DELETE');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept', 'application/json');
        req2.setBody(JSON.serialize(new Map<String, String>{'transfer_email' => userEmail}));
        req2.setTimeout(120000);
        
        HttpResponse res = http.send(req2);
        result = res.getBody();
        
        if(res.getStatusCode() == 204){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }
    
    /*@auraEnabled
    public static String changeUserStatus(String userEmailId, String requestJson){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/users/'+userEmailId+'/status');
        req2.setMethod('PUT');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setBody(requestJson);
        
        HttpResponse res = http.send(req2);
        
        result = res.getBody();
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 204){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }*/
    
    @auraEnabled
    public static String getUserDetails(String userEmailId){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/users/'+userEmailId); 
        req2.setMethod('GET');
        req2.setHeader('Authorization', 'Bearer ' + getJWT()); 
        req2.setTimeout(120000);       
        
        HttpResponse res = http.send(req2);
        result = res.getBody();
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 404){
                        
            return result;
        }
        else{
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }
    
    /*@auraEnabled
    public static String getUsers(String requestJson){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/users?status=inactive&page_size=300');
        req2.setMethod('GET');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
       
        HttpResponse res = http.send(req2);
        
        result = res.getBody();
        System.debug(result );
        return result;
    }*/    
    
    @auraEnabled
    public static String createMeeting(String userEmailId, String requestJson){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/users/'+userEmailId+'/meetings');
        req2.setMethod('POST');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept', 'application/json');
        req2.setBody(requestJson);
        req2.setTimeout(120000);
        
        HttpResponse res = http.send(req2);
        
        result = res.getBody();
        if(res.getStatusCode() == 201){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }
    
    public static String deleteZoomMeeting(String meetingId){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId +'?schedule_for_reminder=false');
        req2.setMethod('DELETE');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept', 'application/json');
        req2.setTimeout(120000);
        
        HttpResponse res = http.send(req2);
        
        result = res.getBody();
        if(res.getStatusCode() == 204){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }
    
    public static String updateZoomMeeting(String meetingId, String requestJson){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId);
        req2.setMethod('PATCH');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept', 'application/json');
        req2.setBody(requestJson);
        req2.setTimeout(120000);
        
        HttpResponse res = http.send(req2);
        
        result = res.getBody();
        if(res.getStatusCode() == 204){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new ZoomException(JSON.serialize(resBody.get('message')));
        }
    }
    
    /*@auraEnabled
    public static String addRegistrantToMeeting(String meetingId, String requestJson){
         
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId+'/registrants');
        req2.setMethod('POST');
        req2.setHeader('Authorization', 'Bearer ' + getJWT());        
        req2.setHeader('Content-Type','application/json');
        req2.setBody(requestJson);
        
        HttpResponse res = http.send(req2);
        
        result = res.getBody();
        if(res.getStatusCode() == 201){
                        
            return result;
        }
        else{
            System.debug(result);
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(result);
            throw new AuraHandledException(JSON.serialize(resBody.get('message')));
        }
    }*/    
        
    public static void createZoomUserAndUpdateContact(String zoomUser, String contactId){
        ZoomDomain.zoomUserWrap  zoomuserwrap =  new ZoomDomain.zoomUserWrap();
        ZoomDomain.zoomUser zoomUserObj = (ZoomDomain.zoomUser) JSON.deserialize(zoomUser, ZoomDomain.zoomUser.Class);
        zoomuserwrap.user_info = zoomUserObj;
        try{
            String resultStr = createUser(JSON.serialize(zoomuserwrap));            
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultStr);
            Contact con = new Contact(Id = contactId, Zoom_Id__c = String.valueOf(result.get('id')), Virtual_Conference_License__c = ZoomDomain.zoomUserTypeMap.get(Integer.valueOf(zoomUserObj.type)), Zoom_User_Status__c = 'Pending');
            update con;
        }catch(Exception exe){
            System.debug('exe::>'+exe);
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomUtil','createZoomUserAndUpdateContact','',exe.getMessage()+' at line number '+exe.getLineNumber(),zoomUser,'Trigger')});
        }        
    }
    
    public static void updateZoomUserLicenseAndUpdateContact(String zoomUserId, String zoomUserStr){
        ZoomDomain.zoomUser zoomUser = (ZoomDomain.zoomUser) JSON.deserialize(zoomUserStr, ZoomDomain.zoomUser.Class);
        try{
            String resultStr = updateUser(zoomUserId, zoomUserStr);            
        }catch(Exception exe){
            System.debug('exe::>'+exe);
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomUtil','updateZoomUserLicenseAndUpdateContact','',exe.getMessage()+' at line number '+exe.getLineNumber(),zoomUserStr,'Trigger')});
        }        
    }
    
    /*@future (callout=true) 
    public static void createMeetingAndUpdateMeetingURLEvent(String zoomMeeting, String eventId, String scheduledFor){
        
        try{
            String resultStr = createMeeting(scheduledFor, JSON.serialize(zoomMeeting));            
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultStr);
            //Events__c event = new Events__c(Id = eventId,Meeting_URL__c= String.valueOf(result.get('join_url')), Instructor_Meeting_URL__c = String.valueOf(result.get('start_url')));
            //update event;
        }catch(Exception exe){
            System.debug('exe::>'+exe);
        }        
    }
    
    @future (callout=true) 
    public static void deleteMeeting(String meetingId){
        
        try{
            
            String resultStr = deleteZoomMeeting(meetingId);            
        }catch(Exception exe){
            System.debug('exe::>'+exe);
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomMeetingDeletionBatch','ZoomMeetingDeletionBatch','',exe.getMessage()+' at line number '+exe.getLineNumber(),meetingId,'Aura Component')});
        }        
    }*/
    
    public static void checkContactForZoomUserAndLicenseType(Set<Id> instructorIds, Set<Id> instructorsNeedsProZoomUser){
        
        for(Contact con : [SELECT Id, FirstName, LastName, Email, Zoom_ID__c, Virtual_Conference_License__c, RecordType.DeveloperName FROM Contact WHERE Id IN :instructorIds AND (Active_DLS_Online_User__c = true OR RecordType.DeveloperName = 'DLS_Employee')]){
            if(con.Zoom_ID__c == null){
                ZoomUtil.getUserDetailsAndUpdateDetailsFuture(con.Email, JSON.serialize(new ZoomDomain.zoomUser(con.FirstName, con.LastName, con.Email, ((instructorsNeedsProZoomUser.contains(con.Id) || con.RecordType.DeveloperName == 'DLS_Employee') ? '2' : '1'))), con.Id, true);
            }else if(instructorsNeedsProZoomUser.contains(con.Id) && con.Virtual_Conference_License__c != 'Zoom - Pro' && con.RecordType.DeveloperName != 'DLS_Employee'){
                ZoomUtil.getUserDetailsAndUpdateDetailsFuture(con.Zoom_ID__c, JSON.serialize(new ZoomDomain.zoomUser('2'), true), con.Id, false);
            }else if(!instructorsNeedsProZoomUser.contains(con.Id) && con.Virtual_Conference_License__c == 'Zoom - Pro' && con.RecordType.DeveloperName != 'DLS_Employee'){
                ZoomUtil.getUserDetailsAndUpdateDetailsFuture(con.Zoom_ID__c, JSON.serialize(new ZoomDomain.zoomUser('1'), true), con.Id, false);
            }
        }
    }
    
    @future(callout = true)
    public static void getUserDetailsAndUpdateDetailsFuture(String zoomId, String zoomUserStr, String contactId, Boolean checkZoomUserAvailable){
        try{
            ZoomUtil.getUserDetailsAndUpdateDetails(zoomId, zoomUserStr, contactId, checkZoomUserAvailable, true);
        }catch(Exception exe){
            
            String result = exe.getMessage();            
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomUtil','getUserDetailsAndUpdateDetailsFuture','',result+' at line number '+exe.getLineNumber(),zoomUserStr,'Aura Component')});
        }       
    }
    
    @future(callout = true)
    public static void updateZoomMeetings(String eventsStr){
        
        List<Events__c> events = (List<Events__c>) JSON.deserialize(eventsStr, List<Events__c>.class);
        for(Events__c eve : events){
            try{
                Map<String, String> meetingMap = new Map<String, String>();
                meetingMap.put('start_time', eve.Start_Date_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss', eve.Timezone__c));
                Decimal duration = ((decimal.valueOf(eve.End_Date_Time__c.getTime() - eve.Start_Date_Time__c.getTime()))/1000/60);
                meetingMap.put('duration', String.valueOf(duration));                
                updateZoomMeeting(eve.Meeting_Id__c, JSON.serialize(meetingMap));
            }catch(Exception exe){
                String result = exe.getMessage();            
                ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomUtil','updateZoomMeetings','',result+' at line number '+exe.getLineNumber(),JSON.serialize(eve),'Trigger')});
            }
        }
    }
    
    public static ZoomDomain.userReponseWrap getUserDetailsAndUpdateDetails(String zoomId, String zoomUserStr, String contactId, Boolean checkZoomUserAvailable, Boolean isFromFutureMethod){
        String userDetailStr = getUserDetails(zoomId);
        Map<String, Object> userDetailObj = (Map<String, Object>) JSON.deserializeUntyped(userDetailStr);
        ZoomDomain.userReponseWrap resWrap = new ZoomDomain.userReponseWrap();
        
        system.debug('::::::::::userDetailObj::::::::'+userDetailObj);
        
        if(userDetailObj.get('code') != null && (userDetailObj.get('code') == 1001 || userDetailObj.get('code') == 1120)){
            createZoomUserAndUpdateContact(zoomUserStr, contactId);
            resWrap.isZoomUserAvailable = false;
        }else{
            ZoomDomain.zoomUser zoomUserObj = (ZoomDomain.zoomUser) JSON.deserialize(zoomUserStr, ZoomDomain.zoomUser.class);
            Contact con;
            if(checkZoomUserAvailable){
                con = new Contact(Id = contactId, Zoom_Id__c = String.valueOf(userDetailObj.get('id')), Virtual_Conference_License__c = ZoomDomain.zoomUserTypeMap.get(Integer.valueOf(zoomUserObj.type)), Zoom_User_Status__c = ZoomDomain.zoomUserStatusMap.get(String.valueOf(userDetailObj.get('status'))));                        
            }
            
            if(userDetailObj.get('type') != zoomUserObj.type){
                ZoomUtil.updateZoomUserLicenseAndUpdateContact(zoomId, zoomUserStr);
            }else if(!checkZoomUserAvailable){
                con = new Contact(Id = contactId, Virtual_Conference_License__c = ZoomDomain.zoomUserTypeMap.get(Integer.valueOf(zoomUserObj.type)), Zoom_User_Status__c = ZoomDomain.zoomUserStatusMap.get(String.valueOf(userDetailObj.get('status'))));                        
            }
            
            if(con != null && isFromFutureMethod){
                
                update con;                     
            }
            
            resWrap.con = con;
            resWrap.isZoomUserAvailable = true;
            resWrap.zoomUser = zoomUserObj;
        } 
        
        return resWrap;
    }
    
    public static Id getOnlineRoomId(){
        Id onlineRoomId;
            
        for(Room__c room : [SELECT Id,Name FROM Room__c WHERE Name = 'Zoom - Online']){
            onlineRoomId = room.Id;
        }
        
        return onlineRoomId;
    }
    
    public static Id getSoftsquareAccId(){
        Id accId;
            
        for(Account acc: [SELECT Id,Name FROM Account WHERE Name = 'Softsquare ELT']){
            accId = acc.Id;
        }
        
        return accId;
    }
    
    @AuraEnabled
    public static string createMeetingForEvent(Id eventId){
        String result = 'success';
        Id onlineRoomId = ZoomUtil.getOnlineRoomId();
        
        List<Events__c> events = [SELECT Id, Duration__c, Date__c, Timezone__c, Start_Date_Time__c, Instructor__c, Instructor__r.Zoom_Id__c, Project__r.DLS_Ref__c FROM Events__c  
                           WHERE Id = :eventId AND Room__c = :onlineRoomId AND Status__c = 'Scheduled' AND  Is_Meeting_Created__c = false
                           AND Instructor__r.Zoom_Id__c != null AND Instructor__r.Zoom_User_Status__c = 'Active'];
        
        try{
           
            if(events != null && events.size() > 0){
                if(events[0].Date__c == System.today()){
                    Set<Id> instructorIds = new Set<Id>{events[0].Instructor__c};
                    checkContactForZoomUserAndLicenseType(instructorIds, instructorIds);
                }
                Events__c event = createMeetingForEvent(events[0]);                  
                update event; 
            }else{
                result = 'Meeting can\'t be created';
            }
        }catch(Exception exe){
            
            result = exe.getMessage();            
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomMeetingCreationBatch','createMeetingForEvent','',result+' at line number '+exe.getLineNumber(),JSON.serialize(events),'Aura Component')});
        }  
        
        return result;
    }
    
    public static Events__c createMeetingForEvent(Events__c event){
        
        ZoomDomain.zoomMeeting zoomMeeting = new ZoomDomain.zoomMeeting();
        zoomMeeting.topic = event.Project__r.DLS_Ref__c;
        zoomMeeting.duration = Integer.valueOf( event.Duration__c * 60 );
        zoomMeeting.timezone = event.Timezone__c;
        zoomMeeting.start_time = event.Start_Date_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss', event.Timezone__c);
        zoomMeeting.type = 2;
        zoomMeeting.schedule_for = event.Instructor__r.Zoom_Id__c;
        zoomMeeting.password = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
        zoomMeeting.settings = new ZoomDomain.zoomMeetingSettings();
        String resultStr = createMeeting(zoomMeeting.schedule_for, JSON.serialize(zoomMeeting));
        
        Map<String, Object> apiresult = (Map<String, Object>) JSON.deserializeUntyped(resultStr);        
        event.Meeting_URL__c= String.valueOf(apiresult.get('join_url'))+'?pwd='+String.valueOf(apiresult.get('encrypted_password')); 
        event.Is_Meeting_Created__c = true;
        event.Meeting_Id__c = String.valueOf(apiresult.get('id'));
        
        return event;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        
        List<sObject> lookupRecords = new List<sObject>();
        
        String searchQry = 'FIND {'+searchString+'} IN NAME Fields Returning '+objectName+' (Id,Name';
        
        if(condition != null && condition != '') {
            searchQry = searchQry + ' WHERE '+condition;
        }
        
        if(selectedIds != null && selectedIds.size() > 0){
            if(condition != null && condition != '') {
                searchQry += ' AND Id NOT IN :selectedIds';
            } else {
                searchQry += ' WHERE Id NOT IN :selectedIds';
            }
        }
        
        searchQry = searchQry + ')';
        
        searchQry += ' LIMIT 10';
        system.debug('sosl is '+searchQry);
        if(searchString != null) {
            lookupRecords = search.query(searchQry)[0];
        }
        
        return lookupRecords;
    }  
    
    @AuraEnabled
    public static string checkAndCreateZoomUsers(String instructorIdStr){
        String result = 'success';
        
        try{
            Set<Id> instructorIds = (Set<Id>) JSON.deserialize(instructorIdStr, Set<Id>.class);            
            ProjectTrigger_Handler.checkZoomUserLicenseTypesForInstructor(instructorIds);
        }catch(Exception exe){
            
            result = exe.getMessage();            
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('ZoomUtil','checkAndCreateZoomUsers','',result+' at line number '+exe.getLineNumber(),instructorIdStr,'Aura Component')});
        }
        
        return result;
    }                 
    
    public class ZoomException extends Exception{}    
}