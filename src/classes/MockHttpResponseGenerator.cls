@isTest
global class MockHttpResponseGenerator  {
    global Class MockHttpResponseGenerator1 implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            //System.assertEquals('https://api.zoom.us/v1/meeting/create', req.getEndpoint());
            //System.assertEquals('POST', req.getMethod());
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"uuid": "9zwMEBhGRfyP5Dl7IjU8+A==","id": 275552545,"host_id": "DCk4D5k8QfCESSiFH9q_8Q","error": {"code": "null","message": "null"},"topic": "Test Meeting","password": "","h323_password": "","status": 0,"option_jbh": false,"option_start_type": "video","option_host_video": true,"option_participants_video": true,"option_cn_meeting": false,"option_audio": "both","type": 3,"start_time": "","duration": 0,"timezone": "","start_url": "https://zoom.us/s/275552545?zpk=Amtaokn4M8BOGdPNJp0erxPBZq1fNESbPj626qnvDE0.BwYAAAFSh6gY6gAAHCAkMTU4NWZkYTUtZjIwYi00NGMwLTg4OGEtY2ZiODFhYmM5ODc1FkRDazRENWs4UWZDRVNTaUZIOXFfOFEWRENrNEQ1azhRZkNFU1NpRkg5cV84UQxMZWFuYXMgTml4b25kALN2YVhsQUJhNTVvbEQwOEI4eW9CeDd0UW91ZHJIcEdyZnhSMHk3TUZfMnJVLkJnSWdkREZHVUVsM0wxVjFZVEUxTTJSMmRtcGlTRVZHY25WdVRtTkNjbkJOUnpWQVlqYzNOV1ExTWpGaVpURmtZMkUwTlRVd1pXTTVZemMxTjJNNE5qWmtaREV5TVRSbU1XRmhZamhoTnpNeVpHRTBOamd6T1RJNE1EazRNR1EyWW1FeE53QQAAFjdSVXY4UW1vU1ZtUXBBci1TWTI2WXcBAgE","join_url": "https://zoom.us/j/275552545","created_at": "2016-01-28T09:54:46Z"}');
            res.setStatusCode(200);
            return res;
        }
    }
    global Class MockHttpResponseGenerator2 implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            //System.assertEquals('https://api.zoom.us/v1/meeting/create', req.getEndpoint());
            //System.assertEquals('POST', req.getMethod());
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "lOa6zZmLSHu4TR1eIY4r2w","email": "Muthulakshmi@softsquare.biz","first_name": "Muthu Sugan","last_name": "Mari","error": {"code": "null","message": "null"},"pic_url": "","type": 1,"disable_chat": false,"disable_private_chat": false,"enable_e2e_encryption": false"enable_silent_mode": false,"disable_group_hd": false,"disable_recording": false,"enable_large": false,"large_capacity": 0,"enable_webinar": false,"webinar_capacity": 0,"disable_feedback": false,"disable_jbh_reminder": false,"enable_cmr": false,"enable_auto_recording": false,"enable_cloud_auto_recording": false,"verified": 1,"pmi": 9535889361,"meeting_capacity": 0,"dept": "","timezone": "Asia/Calcutta","created_at": "2016-01-27T06:57:04Z","token": ""}');
            res.setStatusCode(200);
            return res;
        }
    }
    global Class MockHttpResponseGenerator3 implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            //System.assertEquals('https://api.zoom.us/v1/meeting/create', req.getEndpoint());
            //System.assertEquals('POST', req.getMethod());
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"uuid": "9zwMEBhGRfyP5Dl7IjU8+A==","id": 275552545,"host_id": "DCk4D5k8QfCESSiFH9q_8Q","topic": "Test Meeting","error": {"code": 1001,"message": "Meeting not exist:Test"},"password": "","h323_password": "","status": 0,"option_jbh": false,"option_start_type": "video","option_host_video": true,"option_participants_video": true,"option_cn_meeting": false,"option_audio": "both","type": 3,"start_time": "","duration": 0,"timezone": "","start_url": "https://zoom.us/s/275552545?zpk=Amtaokn4M8BOGdPNJp0erxPBZq1fNESbPj626qnvDE0.BwYAAAFSh6gY6gAAHCAkMTU4NWZkYTUtZjIwYi00NGMwLTg4OGEtY2ZiODFhYmM5ODc1FkRDazRENWs4UWZDRVNTaUZIOXFfOFEWRENrNEQ1azhRZkNFU1NpRkg5cV84UQxMZWFuYXMgTml4b25kALN2YVhsQUJhNTVvbEQwOEI4eW9CeDd0UW91ZHJIcEdyZnhSMHk3TUZfMnJVLkJnSWdkREZHVUVsM0wxVjFZVEUxTTJSMmRtcGlTRVZHY25WdVRtTkNjbkJOUnpWQVlqYzNOV1ExTWpGaVpURmtZMkUwTlRVd1pXTTVZemMxTjJNNE5qWmtaREV5TVRSbU1XRmhZamhoTnpNeVpHRTBOamd6T1RJNE1EazRNR1EyWW1FeE53QQAAFjdSVXY4UW1vU1ZtUXBBci1TWTI2WXcBAgE","join_url": "https://zoom.us/j/275552545","created_at": "2016-01-28T09:54:46Z"}');
            res.setStatusCode(200);
            return res;
        }
    }
    global Class MockHttpResponseGenerator4 implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
            //System.assertEquals('https://api.zoom.us/v1/meeting/create', req.getEndpoint());
            //System.assertEquals('POST', req.getMethod());
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "lOa6zZmLSHu4TR1eIY4r2w","email": "test@dev.com","first_name": "test test","last_name": "Mari","pic_url": "","type": 1,"disable_chat": false,"disable_private_chat": false,"error": {"code": 1001,"message": "User not exist: Test"},"enable_e2e_encryption": false"enable_silent_mode": false,"disable_group_hd": false,"disable_recording": false,"enable_large": false,"large_capacity": 0,"enable_webinar": false,"webinar_capacity": 0,"disable_feedback": false,"disable_jbh_reminder": false,"enable_cmr": false,"enable_auto_recording": false,"enable_cloud_auto_recording": false,"verified": 1,"pmi": 9535889361,"meeting_capacity": 0,"dept": "","timezone": "Asia/Calcutta","created_at": "2016-01-27T06:57:04Z","token": ""}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    //For Latitude and Langitude callout
    global class LatLongCalloutMock implements HttpCalloutMock{
    
        global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        string resp = '{"results" : [{"address_components" : [{"long_name" : "1600","short_name" : "1600","types" : [ "street_number" ]},{"long_name" : "Amphitheatre Pkwy","short_name" : "Amphitheatre Pkwy","types" : [ "route" ]},{"long_name" : "Mountain View","short_name" : "Mountain View","types" : [ "locality", "political" ]},{"long_name" : "Santa Clara County","short_name" : "Santa Clara County","types" : [ "administrative_area_level_2", "political" ]},{"long_name" : "California","short_name" : "CA","types" : [ "administrative_area_level_1", "political" ]},{"long_name" : "United States",'
                +'"short_name" : "US","types" : [ "country", "political" ]},{"long_name" : "94043","short_name" : "94043","types" : [ "postal_code" ]}],"formatted_address" : "1600 Amphitheatre Parkway, Mountain View, CA 94043, USA","geometry" : {"location" : {"lat" : 37.4224764,"lng" : -122.0842499},"location_type" : "ROOFTOP",'
                +'"viewport" : {"northeast" : {"lat" : 37.4238253802915,"lng" : -122.0829009197085},"southwest" : {"lat" : 37.4211274197085,"lng" : -122.0855988802915}}},"place_id" : "ChIJ2eUgeAK6j4ARbn5u_wAGqWA","types" : [ "street_address" ]}],"status" : "OK"}';
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(resp);
        return res;
    }
}
}