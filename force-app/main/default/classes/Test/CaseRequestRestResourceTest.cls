/**
 * @description       : Class used to test CaseRequestRestResource class
 * @author            : Lucas Banquieri
 * @last modified on  : 2025-05-29
 */
@isTest
private class CaseRequestRestResourceTest {

    /**
     * @description  : Method used to test getCaseRequestInfoById when the Case Request is found but doesn't have history
     */
    @isTest
    static void testGetCaseRequestInfoByIdOKWithoutHistory() {
        Case_Request__c cr = new Case_Request__c();
        cr.Subject__c = 'Test Subject';
        cr.Priority__c = 'Medium';
        cr.Status__c = 'In Progress';
        cr.Resolution_Notes__c = 'Test';
        cr.Description__c = 'Case Request created for testing purposes.';
        
        insert cr;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1/caserequest/' + cr.Id;
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CaseRequestRestResource.getCaseRequestInfoById();
        Test.stopTest();
        
        String response = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.debug(responseMap);
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('In Progress', responseMap.get('Status'));
        System.assertEquals(null, responseMap.get('SLAMet'));
    }

    /**
     * @description  : Method used to test getCaseRequestInfoById when the Case Request is found and has history
     */
    @isTest
    static void testGetCaseRequestInfoByIdOKWithHistory() {
        Case_Request__c cr = new Case_Request__c();
        cr.Subject__c = 'Test Subject';
        cr.Priority__c = 'Medium';
        cr.Status__c = 'In Progress';
        cr.Resolution_Notes__c = 'Test';
        cr.Description__c = 'Case Request created for testing purposes.';       
        insert cr;

        Case_History__c ch = new Case_History__c();
        ch.Case_Request__c = cr.Id;
        ch.Time_Closed__c = Date.today()+5;
        ch.SLA_Met__c = false;
        insert ch;
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/v1/caserequest/' + cr.Id;
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CaseRequestRestResource.getCaseRequestInfoById();
        Test.stopTest();
        
        String response = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('In Progress', responseMap.get('Status'));
        System.assertEquals(false, responseMap.get('SLAMet'));
    }

    /**
    * @description  : Method used to test getCaseRequestInfoById when the Case Request is not found
    */
    @isTest
    static void testGetCaseRequestInfoByIdNotFound() {        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caserequest/' + '111111111111111';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CaseRequestRestResource.getCaseRequestInfoById();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Case not found'));
    }

    /**
    * @description  : Method used to test getCaseRequestInfoById when the Id is bot valid.
    */
    @isTest
    static void testGetCaseRequestInfoByIdInvalidId() {        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caserequest/' + 'TESTE1234';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CaseRequestRestResource.getCaseRequestInfoById();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Invalid or missing Case Request ID'));
    }
}