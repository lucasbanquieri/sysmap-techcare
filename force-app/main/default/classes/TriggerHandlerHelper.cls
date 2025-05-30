/**
 * @description      : Helper class containing methods to be commonly used in TriggerHandlers
 * @author           : Lucas Banquieri
 * @last modified on : 2025-05-29
 */
public with sharing class TriggerHandlerHelper {
    
    /**
     * @description      : Method used to check for DML errors and display them in the logs
     */
    public static void checkForDmlErrors(Database.SaveResult[] results, List<SObject> records) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error err : results[i].getErrors()) {
                    System.debug('Error on record ' + records[i].Id + ': ' + err.getMessage());
                }
            }
        }
    }

}