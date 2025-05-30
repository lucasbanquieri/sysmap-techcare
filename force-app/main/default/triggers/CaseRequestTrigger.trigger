trigger CaseRequestTrigger on Case_Request__c (before update) {

    CaseRequestTriggerHandler handler = new CaseRequestTriggerHandler();
    
    if (Trigger.isUpdate) {
        handler.beforeUpdate(Trigger.new);
    }

}