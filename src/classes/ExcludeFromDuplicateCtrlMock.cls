@isTest
global class ExcludeFromDuplicateCtrlMock {
	global Class MockHttpResponseGenerator implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "Success","message": "Non Duplicate Data Removed from Potential Dup Checker"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global Class MockHttpResponseGenerator1 implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"created_at":"2020-03-20T00:00:00.000Z","file_type":"pdf","item_id":"637902071808","item_name":"$10.77-03.17.2020-Uber-Nikita Koves.pdf","item_type":"File","itemname_size":"$10.77-03.17.2020-Uber-Nikita Koves.pdf - 20889.6","owner_login":"lweaver@dlsdc.com","parent_id":"75776863020","size":20889.6}');
            res.setStatusCode(200);
            return res;
        }
    }
}