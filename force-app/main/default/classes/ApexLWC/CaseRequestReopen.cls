/**
 * @description      : Class used to reopen a closed Case Request if the user has the correct profile.
 * @author           : Lucas Banquieri
 * @last modified on : 2025-05-29
 */
public with sharing class CaseRequestReopen {

    private static final Set<String> allowedProfiles = new Set<String>{'Support Premium', 'System Administrator'};
    
    /**
     * @description Method used to reopen a Case Request 
     * if the user is assigned the appropriate profile and if the case request is closed.
     */
    @AuraEnabled(cacheable=false)
    public static void reopenCaseRequest(Id caseRequestId) {
        User userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];

        if (!allowedProfiles.contains(userProfile.Profile.Name))
            throw new AuraHandledException('You do not have permission to reopen this case request.');

        Case_Request__c caseRequest = [SELECT Id, Status__c FROM Case_Request__c WHERE Id = :caseRequestId LIMIT 1];

        if (caseRequest.Status__c != 'Closed')
            throw new AuraHandledException('This case request is not closed.');

        caseRequest.Bypass_Status_Validation__c = true;
        caseRequest.Status__c = 'In Progress';
        update caseRequest;
        caseRequest.Bypass_Status_Validation__c = false;
    }
}