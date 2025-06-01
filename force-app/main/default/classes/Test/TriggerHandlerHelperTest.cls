/**
 * @description       : Class used to test TriggerHandlerHelper class
 * @author            : Lucas Banquieri
 * @last modified on  : 2025-05-29
 */
@isTest
private class TriggerHandlerHelperTest {

    /**
     * @description : Method used to test the checkForDmlErrors method
     * adding two Case Requests one with no error and one with an error
     */
    @IsTest
    static void testCheckForDmlErrors() {
        List<Case_Request__c> caseRequests = new List<Case_Request__c>();

        Case_Request__c request = new Case_Request__c();
        request.Subject__c = 'Test Subject No Error';
        request.Description__c = 'Test No Error';
        request.Status__c = 'New';
        request.SLA_Deadline__c = Date.today();
        caseRequests.add(request);

        Case_Request__c requestWithError = new Case_Request__c();
        requestWithError.Description__c = 'Test With Error';
        requestWithError.Status__c = 'New';
        requestWithError.SLA_Deadline__c = Date.today();
        caseRequests.add(requestWithError);

        Database.SaveResult[] result = Database.insert(caseRequests, false);
        TriggerHandlerHelper.checkForDmlErrors(result, caseRequests);
        Assert.areEqual(1, result[1].getErrors().size(), 'There should be 1 error.');
    }


}