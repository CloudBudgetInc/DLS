@isTest
public class MoodleCourseDeletionMock{
    
    // Return error code and error message
    public class MoodleCourseDeletionMock1 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
        
            HttpResponse res = new HttpResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Return warning code and warning message
    public class MoodleCourseDeletionMock2 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
        
            HttpResponse res = new HttpResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"warnings":[{"item":"course","itemid":3176,"warningcode":"unknowncourseidnumber","message":"Unknown course ID 3176"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Return empty warnings for success callout
    public class MoodleCourseDeletionMock3 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
        
            HttpResponse res = new HttpResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"warnings":[]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Return "Response Code: 504 Response Status: Gateway Time-out
    public class MoodleCourseDeletionMock4 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
        
            HttpResponse res = new HttpResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setStatusCode(504);
            res.setStatus('Gateway Time-out');
            return res;
        }
    }
    
    // Return some other response code
    public class MoodleCourseDeletionMock5 implements HttpCalloutMock{
        
        public HTTPResponse respond(HTTPRequest req){
        
            HttpResponse res = new HttpResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Accept', 'application/json');
            res.setStatusCode(400);
            return res;
        }
    }
}