/**
 * @description      : Factory class used to create Case_Request__c records for testing
 * @author           : Lucas Banquieri
 * @last modified on : 2025-05-29
 */
public with sharing class CaseRequestTestFactory {
    
    public static Map<Id, Case_Request__c> createCaseRequestBulk(Integer recordQuantity) {
        List<Case_Request__c> caseRequests = new List<Case_Request__c>();

        //Loop to create a set number of Case_Request__c records for testing
        for (Integer i = 0; i < recordQuantity; i++) {
            Case_Request__c request = new Case_Request__c();
            request.Subject__c = 'Test Subject ' + i;
            request.Description__c = 'Test Description ' + i;
            request.Status__c = 'New';
            request.SLA_Deadline__c = Date.today().addDays(1);
            caseRequests.add(request);
        }
        insert caseRequests;
        return new Map<Id, Case_Request__c>(caseRequests);
    }

}