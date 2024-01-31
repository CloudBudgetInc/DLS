@isTest
public class ZoomWebhookUtilTest {
    @isTest
    public static void testDoPost() {
        // Create a mock HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/zoomwebhook';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"event":"test_event","payload":{"objects":null,"plainToken":"test_token"}}');

        // Set up a mock response
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        // Perform the callout by invoking the doPost method
        Test.startTest();
        ZoomWebhookUtil.doPost();
        Test.stopTest();

        // Assert the response status code and content
        System.assertEquals(200, response.statusCode);
        //Map<String, String> responseMap = (Map<String, String>) JSON.deserializeUntyped(response.responseBody.toString());
        //System.assertEquals('test_token', responseMap.get('plainToken'));
        // Add more assertions as needed
    }
    
    @isTest
    public static void testUserPost() {
        // Create a mock HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/zoomwebhook';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"event":"user.event","payload":{"objects":{"id":"fsjnvoisdj","type":"2"},"plainToken":"test_token"}}');

        // Set up a mock response
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        // Perform the callout by invoking the doPost method
        Test.startTest();
        ZoomWebhookUtil.doPost();
        Test.stopTest();

        // Assert the response status code and content
        System.assertEquals(200, response.statusCode);
        //Map<String, String> responseMap = (Map<String, String>) JSON.deserializeUntyped(response.responseBody.toString());
        //System.assertEquals('test_token', responseMap.get('plainToken'));
        // Add more assertions as needed
    }
    
    @isTest
    public static void testMeetingPost() {
        // Create a mock HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/zoomwebhook';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"event":"meeting.event","payload":{"objects":{"id":"fsjnvoisdj","type":"2"},"plainToken":"test_token"}}');

        // Set up a mock response
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        // Perform the callout by invoking the doPost method
        Test.startTest();
        ZoomWebhookUtil.doPost();
        Test.stopTest();

        // Assert the response status code and content
        System.assertEquals(200, response.statusCode);
        //Map<String, String> responseMap = (Map<String, String>) JSON.deserializeUntyped(response.responseBody.toString());
        //System.assertEquals('test_token', responseMap.get('plainToken'));
        // Add more assertions as needed
    }

    @isTest
    public static void testDoPostWithException() {
        // Create a mock HTTP request that will trigger an exception
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/zoomwebhook';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"event":"test_event"}');

        // Set up a mock response
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        // Perform the callout by invoking the doPost method
        Test.startTest();
        ZoomWebhookUtil.doPost();
        Test.stopTest();

        // Assert the response status code and error message
        System.assertEquals(400, response.statusCode);
        System.assertEquals('Incorrect account id', response.responseBody.toString());
        // Add more assertions as needed
    }
}