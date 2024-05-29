@RestResource(urlMapping='/zoomwebhook')
global class ZoomWebhookUtil {
    
    global class ZoomRequest{
         @AuraEnabled @InvocableVariable global String event;
         @AuraEnabled @InvocableVariable global payload payload;        
    }
    
    global class payload{
         @AuraEnabled @InvocableVariable global ZoomWebhookObject objects;
         @AuraEnabled @InvocableVariable global String plainToken;
    }
    
    @HttpPost
    global static void doPost() 
    {        
        RestResponse res = RestContext.response;
        Map<String, String> responseMap = new Map<String, String>();
        try
        {
            String secretToken = Label.zoomAppSecretToken;
            String plainToken = '';            
            
            ZoomRequest params = (ZoomRequest)JSON.deserialize(RestContext.request.requestBody.toString().replaceAll('object', 'objects'), ZoomRequest.class);
                        
            if(params.payload.plainToken != null){    
                plainToken = params.payload.plainToken;
                Blob secretBlob = Blob.valueOf(secretToken);
                Blob plainTokenBlob = Blob.valueOf(plainToken);
                Blob encryptedTokenBlob = Crypto.generateMac('HmacSHA256', plainTokenBlob, secretBlob);
                String encryptedToken = EncodingUtil.convertToHex(encryptedTokenBlob);
                responseMap.put('plainToken', plainToken);
                responseMap.put('encryptedToken', encryptedToken);
            }
            insert new Sync_Log__c(Error_Message__c=JSON.serialize(params));
            Map<String, Object> flowParams = new Map<String, Object>();
            if(params.event.contains('user') && (params.event != 'user.updated' || String.isNotBlank(String.valueOf(params.payload.objects.type)))){
                flowParams.put('ZoomUser',params.payload.objects);
                flowParams.put('ZoomEvent',params.event);
                flowParams.put('SyncLog',new Sync_Log__c(Error_Message__c=RestContext.request.requestBody.toString()));
                flowParams.put('ZoomUserStatus',(params.event == 'user.deactivated' || params.event == 'user.deleted' || params.event == 'user.disassociated' ? 'In-Active' : 'Active'));
                Flow.Interview.Zoom_User_Sync zoomUserflow = new Flow.Interview.Zoom_User_Sync(flowParams);
                zoomUserflow.start();
            }else if(params.event.contains('meeting.deleted')){ //Modified By Dhinesh - 10/1/2024 - W-007957 - Prevent Duplicate Zoom Event Creation
                flowParams.put('ZoomObject',params.payload.objects);
                flowParams.put('SyncLog',new Sync_Log__c(Error_Message__c=RestContext.request.requestBody.toString()));
                Flow.Interview.Zoom_Meeting_Sync zoomMeetingflow = new Flow.Interview.Zoom_Meeting_Sync(flowParams);
                zoomMeetingflow.start();
            }
            
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.statusCode = 200;
        }
        catch (Exception e) 
        {
            insert new Sync_Log__c(Error_Message__c=RestContext.request.requestBody.toString()+'---'+e.getMessage()+'---at line no.---'+e.getLineNumber());
            res.addHeader('Content-Type', 'text/plain');
            res.responseBody = Blob.valueOf('Incorrect account id');
            res.statusCode = 400;
        }
    }    
}