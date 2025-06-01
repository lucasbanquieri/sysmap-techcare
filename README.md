# TechCare

This is a project of an app called TechCare for the Salesforce platform, which is essentially a support ticketing system.

## Functionalities
- Trigger that fires when Case Request status changes to "Closed" and creates a Case_History__c object containing the closed date and if SLA was met or not;
- LWC component used to show a countdown timer for the SLA and a "Reopen Case" button on its record page. This component only displays for users with "Support Premium" profile;
- REST Resource API with the /caserequest/* endpoint where given a Case Request Id it returns a JSON containing the object's status and if SLA was met or not, when applied.

## Installation

1. The following custom objects/fields need to be created beforehand:  

    **Case_request__c**  
    |__ Subject__c(Text,255)  
    |__ Description__c(Long Text)  
    |__ Priority__c(Picklist: Low/Medium/High)  
    |__ Status__c(Picklist: New, In Progress, Escalated, Closed)  
    |__ SLA_Deadline__c(DateTime)  
    |__ Resolution_Notes__c(Long Text Area)  
    
    **Case_History__c**  
    |__ Time_Closed__c(DateTime)  
    |__ SLA_Met__c(Checkbox)
    |__ Case_Request__c(Master-Detail)


3. The following user profiles and record types are also needed:  
   -Support Standard  
   -Support Premium  


4. In order for the field SLA_Deadline__c be set properly, a Record-Triggered Flow is needed for newly created Case Requests,
   using the formula NOW()+1/1 for the Support Standard record type and NOW()+8/24 for the Support Premium;

5. Import the project to your local machine and deploy source to Org:  
```git clone https://github.com/lucasbanquieri/sysmap-techcare/```  
```cd yourlocalfolder```  
```npm install```  

## Testing

Testing the Apex Trigger:  
1. Edit an existing Case Request(If none exists, create a new one) and change its status to "Closed";  
2. Perform a SOQL to see if the trigger inserted(**its supposed to**) the Case_History__c record for the Case Request you edited:  
   ```sql
   SELECT Id, Status__c, (SELECT Time_Closed__c FROM Case_History__r)FROM Case_Request__c WHERE Id = 'REPLACE WITH CASE REQUEST ID'
   ```
   **OR**  
    ```sql
    SELECT Id, Time_Closed__c, SLA_Met__c FROM Case_History__c WHERE Case_Request__c = 'REPLACE WITH CASE REQUEST ID'
    ```
3. You can also run the tests for the CaseRequestTriggerHandlerTest class.  

Testing the LWC component:  
1. Open the record page for any Case Request record;  
2. If you are **System Administrator** or has the **Support Premium** profile you should be able to see the **SLA Remaining** component displayed;  
3. To test the **"Reopen Case"** button you need to access the record page of a Case Request where the Status is "Closed";  
4. When clicked the status will be updated to "In Progress" and the timer will be displayed again.

## REST API

### GET /caserequest/{id}

Returns the Status__c and SLA_Met__c for a given Case Request ID.  

**Method:** `GET`  
**URL:** `/caserequest/{caseid}`  
**Auth Required:** Yes  
**Headers:**  
```http
Authorization: Bearer <token>
Content-Type: application/json
```

| Name | Type   | Description                       |
| ---- | ------ | --------------------------------- |
| `id` | string | The unique ID of the case request |  


**Response Body Example**  
```json
{
   "attributes":{
      "type":"Case_Request__c",
      "url":"/services/data/v63.0/sobjects/Case_Request__c/XXXXXXXXXXXXXXXXXXXX"
   },
   "Id":"XXXXXXXXXXXXXXXXXXXX",
   "Status__c":"In Progress",
   "Case_History__r":{
      "totalSize":1,
      "done":true,
      "records":[
         {
            "attributes":{
               "type":"Case_History__c",
               "url":"/services/data/v63.0/sobjects/Case_History__c/YYYYYYYYYYYYYYYYY"
            },
            "Case_Request__c":"XXXXXXXXXXXXXXXXXXXX",
            "Id":"YYYYYYYYYYYYYYYYY",
            "SLA_Met__c":true
         }
      ]
   }
}
```
**Possible Status Codes:**  
- 200 OK - Success  
- 404 Not Found - Case Request not found  
- 500 Internal Server Error - Something unexpected happened

**Example request:**  
```bash
curl -X GET https://yourdomain.com/caserequest/{caseid} \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json"
```
