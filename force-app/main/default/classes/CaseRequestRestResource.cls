/**
 * @description       : This class is used to get information about a Case Request giving its ID.
 * @author            : Lucas Banquieri
 * @last modified on  : 2025-05-29
 */
@RestResource(urlMapping='/caserequest/*')
global with sharing class CaseRequestRestResource {
    

    /**
     * @description       : This method is used to get information about a Case Request by ID. 
     * @returns           : A Blob containing the serialized JSON of Status__c and SLA_Met__c(If exists in Case_History__c)
     */
    @HttpGet
    global static void getCaseRequestInfoById() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String id = request.requestURI.substring(request.requestURI.lastIndexOf('/') +1);

        try {
            Case_Request__c caseRequests = [SELECT Id, Status__c, (SELECT SLA_Met__c FROM Case_History__r LIMIT 1) 
                                             FROM Case_Request__c WHERE Id = :id LIMIT 1];

            Boolean slaMet = null;

            //Check if Case_History__r is not empty to avoid exception when SLA_Met__c is null
            if (!caseRequests.Case_History__r.isEmpty()) {
                slaMet = caseRequests.Case_History__r[0].SLA_Met__c;
            }
    
            Map<String, Object> result = new Map<String, Object>{
                'Status__c' => caseRequests.Status__c,
                'SLA_Met__c' => slaMet
            };

            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(caseRequests));
        } catch (QueryException qe) {
            sendError(response, 404, 'Case not found.');
        } catch (Exception e) {
            sendError(response, 500, 'An unexpected error occurred: ' + e.getMessage());
        }
    }

    //Method that creates a JSON containing the error message
    private static void sendError(RestResponse res, Integer statusCode, String message) {
        res.statusCode = statusCode;
        res.responseBody = Blob.valueOf(
            JSON.serialize(new Map<String, String>{
                'error' => message
            })
        );
    }
}