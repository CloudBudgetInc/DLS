@isTest
global class HttpResponseMockGenerator {
    
    global class ZapierUtilMock1 implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"User_Id__c":"122", "Record_Id__c":"12345"}');
            response.setStatusCode(200);
            return response; 
        }
    }
}