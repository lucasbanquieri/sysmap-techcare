/**
 * @description       : This class is used to get information about a Case Request giving its ID.
 * @author            : Lucas Banquieri
 * @last modified on  : 2025-05-29
 */
@RestResource(urlMapping='/v1/caserequest/*')
global with sharing class CaseRequestRestResource {
    

    /**
     * @description       : This method is used to get information about a Case Request by ID. 
     * @returns           : A JSON containing the fields: Status__c and SLA_Met__c(If exists in Case_History__c)
     */
    @HttpGet
    global static void getCaseRequestInfoById() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        String id = request.requestURI.substring(request.requestURI.lastIndexOf('/') +1);

        //Checks if provided ID is valid
        if (String.isBlank(id) || id.length() < 15) {
            sendError(response, 400, 'Invalid or missing Case Request ID.');
            return;
        }

        try {
            Case_Request__c caseRequests = [SELECT Id, Status__c, (SELECT SLA_Met__c FROM Case_History__r LIMIT 1) 
                                             FROM Case_Request__c WHERE Id = :id LIMIT 1];

            Boolean slaMet = null;

            //Check if Case_History__r is not empty to avoid exception when SLA_Met__c is null
            if (!caseRequests.Case_History__r.isEmpty()) {
                slaMet = caseRequests.Case_History__r[0].SLA_Met__c;
            }

            CaseRequestRestResponse cResponse = new CaseRequestRestResponse();
            cResponse.Status = caseRequests.Status__c;
            cResponse.SLAMet = slaMet;

            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(cResponse));
        } catch (QueryException qe) {
            sendError(response, 404, 'Case not found.');
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