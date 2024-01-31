/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 02/01/2023
 * @last modified by  : Dhinesh Kumar
**/
public with sharing class LessonPlanBoxUtil {
    public static String JWTToken(){
        
        //replace with your app client id
        String clientId = System.Label.Box_Client_Id; 
        //replace with your app client secret
        String clientSecret = System.Label.Box_Client_Secret;
        String endpoint = 'https://api.box.com/oauth2/token';
        String iss = clientId;
        String aud = endpoint;
        String sub = System.Label.Box_Subject_Id; //replace Enterprise Id
        //Long exp = DateTime.now().addhours(-8).addSeconds(30).getTime(); // Datetime.now is returning fiff time than what need JWT token 
        Auth.Jwt jwt = new Auth.Jwt();
        jwt.setValidityLength(60);
        String jwtRequestd = jwt.toJSONString();
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jwtRequestd);
        Long exp = (Long)m.get('exp');
        system.debug(jwtRequestd);
        system.debug(jwt.getValidityLength());
        // Start constructing the header and claims
        String jwtHeader = '{"typ":"JWT","alg":"RS256"}';
        String jwtClaims = '{"iss":"' + iss +'","jti":"'+String.valueof((math.random() * 60))+'","box_sub_type":"enterprise","sub":"' + sub + '","aud":"' + aud + '","exp":' + exp + '}';
        system.debug(jwtClaims);
        String jwtRequest = System.encodingUtil.base64Encode(Blob.valueOf(jwtHeader)).replace('+', '-').replace('/', '_') + '.' + System.encodingUtil.base64Encode(Blob.valueOf(jwtClaims)).replace('+', '-').replace('/', '_');
        String signature = System.encodingUtil.base64Encode(Crypto.signWithCertificate('RSA-SHA256', Blob.valueOf(jwtRequest), 'Box')).replace('+', '-').replace('/', '_');
        String signedJwtRequest = jwtRequest + '.' + signature;
        // The JWT is fully constructed, now it's time to make the call to get the access token.
        String payload = 'grant_type=' + System.EncodingUtil.urlEncode('urn:ietf:params:oauth:grant-type:jwt-bearer', 'UTF-8');
        payload += '&client_id='+clientId+'&client_secret='+clientSecret;
        payload += '&assertion=' + signedJwtRequest;
        System.debug(payload);
        return payload;
    }
    
    public static string getAccessToken(){
        String payload = JWTToken();
        Http httpObj = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint('https://api.box.com/oauth2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(payload);
        res = httpObj.send(req);
        System.debug('res::'+res.getStatusCode());
        accessTokenReponse resBody = (accessTokenReponse)JSON.deserialize(res.getBody(), accessTokenReponse.class);
        System.debug('res body::>'+resBody.access_token);
        System.debug('res body::>'+resBody.expires_in);
        return resBody.access_token;
    }
    
    public class accessTokenReponse{
        public string access_token;
        public string expires_in;
    }
    @AuraEnabled
    public static String createFolder(String folderName , String lessonPlanRecordId){
        String parentFolderId = '';
        List<box__Folder_Details__c> boxDetails = [SELECT box__FolderId__c FROM box__Folder_Details__c WHERE Name = 'Lesson Plans'];
        if(boxDetails.size() > 0){
            parentFolderId = boxDetails[0].box__FolderId__c;
        }
        String accessToken = getAccessToken();
        System.debug(accessToken);
        String body = '{ "name": "' + folderName + '", "parent": { "id": "' + parentFolderId + '" } }';
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
            String folderId = String.valueOf(untypedMap.get('id'));
            return getSharedLink(folderId , lessonPlanRecordId);
        }else if(res.getStatusCode() == 409){
            BoxUtilDomain.BodyWrapper wrapperList = (BoxUtilDomain.BodyWrapper)System.JSON.deserialize(res.getBody(),BoxUtilDomain.BodyWrapper.class);
            String folderId = wrapperList.context_info.conflicts[0].id;
            return getSharedLink(folderId , lessonPlanRecordId);
        }
        else{
            createErrorLog('createFolder',res.getBody());
            throw new AuraHandledException('Error while creating folder ' + res.getStatusCode() );
        }
    }
    public static String getSharedLink(String folderId , String lessonPlanRecordId){
        BoxUtilDomain.BoxFolderWrapper wrapperInstance = new BoxUtilDomain.BoxFolderWrapper();
        String accessToken = getAccessToken();
        String body = '{ "shared_link": { "access": "open" , "unshared_at" : null} } ';
        String endpoint = 'https://api.box.com/2.0/folders/' + folderId + '?fields=shared_link'; 
        // define transaction variables
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
 
        req.setEndpoint(endpoint);
        req.setMethod('PUT');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setBody(body);
        res = h.send(req);
        System.debug('res: '+res);
        System.debug('res.getBody(): '+res.getBody());
        if ((res.getStatusCode() == 200) && res.getBody() != null && res.getBody() != null) {
            Map<String, Object> untypedMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object> untypedMap2 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(untypedMap.get('shared_link')));
            String url = String.valueOf(untypedMap2.get('url'));
            wrapperInstance.boxFolderId = folderId;
            wrapperInstance.boxSharedURL = url;
            updateLessonPlanRecord(wrapperInstance , lessonPlanRecordId);
            List<String> stringList = url.split('/');
        }
        else{
            createErrorLog('getSharedLink',res.getBody());
            throw new AuraHandledException('Error while creating shared link for folder ' + res.getStatusCode() );
        }
        return JSON.serialize(wrapperInstance);
        //return '';
    }
 
   //code to upload files to BOX.COM
   
    @AuraEnabled
    public static String uploadFile(String base64, String fileName, String folderId){
        String accessToken = getAccessToken();
        String result = '';
        if(base64!=null){
            blob base64EncodeFile = base64EncodeFileContent(EncodingUtil.base64Decode(base64), fileName);
            String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+folderId;
            String boundary = '----------------------------741e90d31eff';
            String body = '{"name":"' + fileName + '", "parent":{"id":"' + folderId + '"}}';
            HttpRequest req = new HttpRequest();
            req.setBody(body);
            req.setBodyAsBlob(base64EncodeFile);
            req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setMethod('POST');
            req.setEndpoint(uploadEndPointURL);
            req.setTimeout(120000);
            Http ht = new Http();
            HTTPResponse res = ht.send(req);
            
            System.debug('res: '+res);
            System.debug('res.getBody(): '+res.getBody());
            if(res.getStatusCode()==201){
                result =  'File uploaded successfully.';
            }else{
                createErrorLog('uploadFile',res.getBody());
                throw new AuraHandledException('Error while uploading file ' + res.getStatusCode() );
            }
        }else{
            throw new AuraHandledException('Please select file.');
        }
        return result;
    }

    @AuraEnabled
    @Future(callout=true)
    public static void uploadFilesAsync(String filesDetails , String folderId){
            List<BoxUtilDomain.FilesWrapper> filesWrapper = (List<BoxUtilDomain.FilesWrapper>)JSON.deserialize(filesDetails , List<BoxUtilDomain.FilesWrapper>.class);
            System.debug('filesMap: '+filesWrapper);
            for(BoxUtilDomain.FilesWrapper wrapperInstance : filesWrapper){
                uploadFile(wrapperInstance.base64 , wrapperInstance.fileName , folderId);
            }
    }
    @AuraEnabled
    public static String getItemsFromFolder(String folder_id){
        String accessToken = getAccessToken();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        req.setMethod('GET');
        String endpoint = 'https://api.box.com/2.0/folders/'+folder_id+'/items?fields=,name,type,size,created_at,content_created_at';
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        res = h.send(req);
        
        String body = JSON.serialize(res.getBody());
        if(res.getStatusCode() == 200){
            BoxUtilDomain.FileListWrapper wrapperList = (BoxUtilDomain.FileListWrapper)System.JSON.deserialize(res.getBody(),BoxUtilDomain.FileListWrapper.class);
            return JSON.serialize(wrapperList);
        }
        else{
            createErrorLog('getItemsFromFolder',res.getBody());
            throw new AuraHandledException('Error while creating shared link for folder ' + res.getStatusCode() );
        }
    }
    @AuraEnabled
    @Future(callout=true)
    public static void deleteFilesAsync(List<String> fileIds){
        for(String fileId : fileIds){
            deleteFile(fileId);
        }
    }
    public static void deleteFile(String fileId){
        String result = '';
        String accessToken = getAccessToken();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        req.setMethod('DELETE');
        String endpoint = 'https://api.box.com/2.0/files/'+fileId;
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        res = h.send(req);
        
        if(res.getStatusCode() == 204){
            result = 'success';            
        }
        else{
            createErrorLog('deleteFile',res.getBody());
            throw new AuraHandledException('Error while creating shared link for folder ' + res.getStatusCode() );
        }
    }
    public static blob base64EncodeFileContent(Blob file_body, String file_name){
        Blob bodyBlob;
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());        
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        System.debug('bodyBlob: '+bodyBlob);
        return bodyBlob;
    }
    public static void updateLessonPlanRecord(BoxUtilDomain.BoxFolderWrapper boxWrapper , String lessonPlanRecordId){
        Lesson_Plan__c lessonPlan = new Lesson_Plan__c();
        lessonPlan.Id = lessonPlanRecordId;
        lessonPlan.Box_Folder_Id__c = boxWrapper.boxFolderId;
        lessonPlan.Box_File_Shared_URL__c = boxWrapper.boxSharedURL;
        lessonPlan.Status__c = 'Completed';
        update lessonPlan;
                
        GenericUrlLaunch_Ctrl.createBoxFRUPRecs(JSON.serialize(new box__FRUP__c(box__Folder_ID__c=boxWrapper.boxFolderId, box__Record_ID__c=lessonPlanRecordId, box__Permission__c='Read/Write', box__Object_Name__c='Lesson_Plan__c')));
    }
    @Future
    public static void createErrorLog(String methodName , String resBody){
        ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('LessonPlanBoxUtil',methodName,'','',JSON.serialize(resBody),'Apex Class')});
    }
}