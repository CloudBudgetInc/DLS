// Mock Class for LibraryContentSearchTest Class
// Developed by E.Keerthika on 14th, August 2018
@isTest
global class LibraryContentSearchMockClass{
    
    global class MockHttpResponse implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            
            // Create a fake response
            
            Map<String, Object> testResponseMap = new Map<String, Object>();
            String str = '{"controllerValues":{},'+
                         '"defaultValue":null,'+
                         '"eTag":"e573887ea747cd6f7844c9c4ba33fa14",'+
                         '"url":"/services/data/v42.0/ui-api/object-info/Contact_Assignments__c/picklist-values/01232000000DwmaAAC/Status__c",'+
                         '"values":[{"attributes":null, "label":"Active", "validFor":{}, "value":"Active"}, {"attributes":null, "label":"Ended",'+
                         '"validFor":{}, "value":"Ended"}, {"attributes":null, "label":"On Hold", "validFor":{}, "value":"On Hold"}, {"attributes":null,'+
                         '"label":"Planned", "validFor":{}, "value":"Planned"}]}';
                         
            HttpResponse res = new HttpResponse();
            res.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId()); //'Content-Type', 'application/json');
            res.setBody(str);
            res.setStatusCode(200);
            return res;
        }
    } 
}