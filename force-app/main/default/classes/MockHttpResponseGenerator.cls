@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    private static final String CONTENT_TYPE = 'application/json';
    private static final String RESPONSE_BODY = '{"success": true}';
    private static final Integer RESPONSE_STATUS_CODE = 200;

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', CONTENT_TYPE);
        res.setBody(RESPONSE_BODY);
        res.setStatusCode(RESPONSE_STATUS_CODE);
        return res;
    }
}