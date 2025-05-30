/**
 * @description      : Handler class for the CaseRequestTrigger
 * @author           : Lucas Banquieri
 * @last modified on : 2025-05-29
 */
public with sharing class CaseRequestTriggerHandler {
    
    public void beforeUpdate(List<Case_Request__c> caseRequestList) {
        handleStatusChangedToClosed(caseRequestList);
    }

    //Method used to insert Case_History__c records when the Status__c is changed to 'Closed'
    private void handleStatusChangedToClosed(List<Case_Request__c> caseRequestList) {
        List<Case_History__c> historyToUpdate = new List<Case_History__c>();

        for (Case_Request__c request : caseRequestList) {
            if (request.Status__c != 'Closed')
                continue;

            Case_History__c history = new Case_History__c();
            history.Case_Request__c = request.Id;
            history.Time_Closed__c = DateTime.now();
                
            if (request.SLA_Deadline__c <= Date.today())
                history.SLA_Met__c = false;
            else
                history.SLA_Met__c = true;
            
            historyToUpdate.add(history);
        }

        //Cancel method execution if there are no records to insert
        if (historyToUpdate.isEmpty())
            return;
        
        Database.SaveResult[] insertResult = Database.insert(historyToUpdate, false);
        TriggerHandlerHelper.checkForDmlErrors(insertResult, historyToUpdate);
    }
}