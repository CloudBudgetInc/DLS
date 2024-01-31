global class LessonPlanBoxUtilMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('https://api.box.com/oauth2/token')){
            res.setBody('{"access_token" : "1a2b3c4d5e"}');
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('https://api.box.com/2.0/folders')){
            res.setBody('{"id" : "123abc45de" , "shared_link" : {"url" : "https://app.box.com/s/1a2b3c4d5e6f7g"}}');
            res.setStatusCode(201);
        }
        if(req.getEndpoint().contains('https://upload.box.com/api/2.0/files/content?parent_id=')){
            res.setBody('{}');
            res.setStatusCode(201);
        }
        if(req.getEndpoint().contains('?fields=shared_link')){
            res.setBody('{"id" : "123abc45de" , "shared_link" : {"url" : "https://app.box.com/s/1a2b3c4d5e6f7g"}}');
            res.setStatusCode(200);
        }
        if(req.getEndpoint().contains('items?fields=,name,type,size,created_at,content_created_at')){
            //res.setBody('{"id" : "123abc45de" , "shared_link" : {"url" : "https://app.box.com/s/1a2b3c4d5e6f7g"}}');
            res.setBody('{ "entries": [ { "id": 12345, "etag": 1, "type": "file", "sequence_id": 3, "name": "Contract.pdf", "sha1": "85136C79CBF9FE36BB9D05D0639C70C265C18D37", "file_version": { "id": 12345, "type": "file_version", "sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc" } } ], "limit": 1000, "offset": 2000, "order": [ { "by": "type", "direction": "ASC" } ], "total_count": 5000 }');
            res.setStatusCode(200);
        }
        if(req.getMethod() == 'DELETE'){
            res.setStatusCode(204);
        }
        return res;
    }
}