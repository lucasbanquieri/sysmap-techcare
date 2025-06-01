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
        req.requestUri = '/services/apexrest/caserequest/' + cr.Id;
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CaseRequestRestResource.getCaseRequestInfoById();
        Test.stopTest();
        
        String response = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('In Progress', responseMap.get('Status__c'));
        System.assertEquals(null, responseMap.get('SLA_Met__c'));
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
        req.requestUri = '/services/apexrest/caserequest/' + cr.Id;
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CaseRequestRestResource.getCaseRequestInfoById();
        Test.stopTest();
        
        //All the mapping below were necessary to get the SLA_Met__c field in the response when its originally a Blob
        //START OF MAPPING
        String response = RestContext.response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> caseHistory = (Map<String, Object>) responseMap.get('Case_History__r');
        List<Object> historyRecords = (List<Object>) caseHistory.get('records');
        Map<String, Object> firstHistoryRecord = (Map<String, Object>) historyRecords[0];
        //END OF MAPPING

        Boolean slaMet = (Boolean) firstHistoryRecord.get('SLA_Met__c');

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('In Progress', responseMap.get('Status__c'));
        System.assertEquals(false, slaMet);
    }

    /**
    * @description  : Method used to test getCaseRequestInfoById when the Case Request is not found
    */
    @isTest
    static void testGetCaseRequestInfoByIdNotFound() {        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/caserequest/' + '1234TEST';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        CaseRequestRestResource.getCaseRequestInfoById();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Case not found'));
    }
}