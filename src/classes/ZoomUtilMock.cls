@isTest
global class ZoomUtilMock{
    global class ZoomUserCreationMock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();        
            if(req.getEndpoint() == 'https://api.zoom.us/v2/users'){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"id":"testId1234"}');
                res.setStatusCode(201);
            }else{
                
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"code":1001}');
                res.setStatusCode(200);
            }
            return res;
        }
    }
    
    global class ZoomUserUpdationAndMeetingCreationandDeletionMock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();        
            if(req.getEndpoint() == 'https://api.zoom.us/v2/users'){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"id":"testId1234"}');
                res.setStatusCode(201);
            }else if(req.getEndpoint().contains('/users') && req.getMethod() == 'DELETE'){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('');
                res.setStatusCode(204);
            }else if(req.getEndpoint().endsWith('/meetings')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"join_url":"https://zoom.us/meetingId1234", "encrypted_password":"12345","id":"meetingId1234"}');
                res.setStatusCode(201);
            }else if(req.getEndpoint().contains('/meetings') && req.getMethod() == 'PATCH'){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"join_url":"https://zoom.us/meetingId1234", "encrypted_password":"12345","id":"meetingId1234"}');
                res.setStatusCode(201);
            }else if(req.getEndpoint().endsWith('/schedule_for_reminder=false')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"join_url":"https://zoom.us/meetingId1234", "encrypted_password":"12345","id":"meetingId1234"}');
                res.setStatusCode(204);
            }else{
                
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"type":"1","id":"testId1234","status":"active"}');
                res.setStatusCode(200);
            }
            return res;
        }
    }

	global class ZoomUserExceptionMock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();        
            if(req.getEndpoint().contains('/users') && req.getMethod() == 'DELETE'){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('');
                res.setStatusCode(401);
            }
            return res;
        }
    }    
}