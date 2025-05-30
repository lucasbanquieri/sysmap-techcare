/**
 * @description       : Class used to test CaseRequestTriggerHandler class
 * @author            : Lucas Banquieri
 * @last modified on  : 2025-05-29
 */
@isTest
private class CaseRequestTriggerHandlerTest {

    /**
     * @description : Method used to test if the trigger is fired when 
     * the Status__c field is changed to something other than 'Closed'.
     */
    @IsTest
    static void testStatusChangedToClosedWhenDifferentStatus() {
        Case_Request__c request = new Case_Request__c();
        request.Subject__c = 'Test Subject';
        request.Status__c = 'In Progress';
        request.SLA_Deadline__c = Date.today().addDays(1);
        insert request;

        //Change the Status__c to 'Escalated'
        request.Status__c = 'Escalated';
        update request;

        //Select the Case_History__c record to see if the SLA_Met__c field was updated to true
        List<Case_History__c> history = [SELECT Id, SLA_Met__c FROM Case_History__c WHERE Case_Request__c = :request.Id];
        System.assert(history.isEmpty(), 'Case_History should not be inserted when Status is not Closed.');
    }

    /**
     * @description : Method used to test if the trigger inserts a Case_History__c record 
     * with the SLA_Met__c field set to TRUE when the Status__c is changed to 'Closed' and
     * the SLA_Deadline__c is in the future.
     */
    @IsTest
    static void testStatusChangedToClosedSLAMet() {
        Case_Request__c request = new Case_Request__c();
        request.Subject__c = 'Test Subject';
        request.Status__c = 'In Progress';
        request.SLA_Deadline__c = Date.today().addDays(1);
        insert request;

        //Change the Status__c to 'Closed' and add Resolution_Notes to simulate a closing request
        request.Resolution_Notes__c = 'Test Resolution Notes';
        request.Status__c = 'Closed';
        update request;

        //Select the Case_History__c record to see if the SLA_Met__c field was updated to true
        List<Case_History__c> history = [SELECT Id, SLA_Met__c FROM Case_History__c WHERE Case_Request__c = :request.Id];
        System.assertEquals(true, history.get(0).SLA_Met__c, 'SLA_Met__c should be true.');
    }

    /**
     * @description : Method used to test if the trigger inserts a Case_History__c record 
     * with the SLA_Met__c field set to FALSE when the Status__c is changed to 'Closed' and
     * the SLA_Deadline__c is in the past.
     */
    @IsTest
    static void testStatusChangedToClosedSLANotMet() {
        Case_Request__c request = new Case_Request__c();
        request.Subject__c = 'Test Subject';
        request.Status__c = 'In Progress';
        request.SLA_Deadline__c = Date.today().addDays(-1);
        insert request;

        //Change the Status__c to 'Closed' and add Resolution_Notes to simulate a closing request
        request.Resolution_Notes__c = 'Test Resolution Notes';
        request.Status__c = 'Closed';
        update request;

        //Select the Case_History__c record to see if the SLA_Met__c field was updated to true
        List<Case_History__c> history = [SELECT Id, SLA_Met__c FROM Case_History__c WHERE Case_Request__c = :request.Id];
        System.assertEquals(false, history.get(0).SLA_Met__c, 'SLA_Met__c should be false.');
    }

    /**
     * @description : Method used to bulk test the trigger 
     * and check if the SLA_Met__c field are updated correctly to TRUE
     */
    @IsTest
    static void bulkTestStatusChangedToClosedSLAMet() {
        //Use the factory class to create 200 Case Requests
        Map<Id, Case_Request__c> cRequests = CaseRequestTestFactory.createCaseRequestBulk(200);

        for (Case_Request__c cRequest : cRequests.values()) {
            cRequest.Resolution_Notes__c = 'Test Resolution Notes';
            cRequest.Status__c = 'Closed';
        }
        update cRequests.values();

        //Select for Case_History__c to see if it returns any records with SLA not met
        List<Case_History__c> caseHistoriesSLANotMet = [SELECT Id, SLA_Met__c 
                                                         FROM Case_History__c 
                                                        WHERE Case_Request__c IN :cRequests.keySet() AND SLA_Met__c = false];
        System.assertEquals(true, caseHistoriesSLANotMet.isEmpty(), 'There should not be any records with SLA not met.');
    }

    /**
     * @description : Method used to bulk test the trigger 
     * and check if the SLA_Met__c field are updated correctly to FALSE
     */
    @IsTest
    static void bulkTestStatusChangedToClosedSLANotMet() {
        //Use the factory class to create 200 Case Requests
        Map<Id, Case_Request__c> cRequests = CaseRequestTestFactory.createCaseRequestBulk(200);

        //Change the SLA_Deadline__c to be in the past
        for (Case_Request__c cRequest : cRequests.values()) {
            cRequest.SLA_Deadline__c = Date.today().addDays(-1);
            cRequest.Resolution_Notes__c = 'Test Resolution Notes';
            cRequest.Status__c = 'Closed';
        }
        update cRequests.values();

        //Select for Case_History__c to see if it returns any records with SLA met
        List<Case_History__c> caseHistoriesSLAMet = [SELECT Id, SLA_Met__c 
                                                         FROM Case_History__c 
                                                        WHERE Case_Request__c IN :cRequests.keySet() AND SLA_Met__c = true];
        System.assertEquals(true, caseHistoriesSLAMet.isEmpty(), 'There should not be any records with SLA met.');
    }
}