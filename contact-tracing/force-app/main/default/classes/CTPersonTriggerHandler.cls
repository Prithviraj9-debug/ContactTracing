public with sharing class CTPersonTriggerHandler {

    /** before insert operation for person object
     * make sure the health status is green
     * generate unique token for each record
     */
    
    public static void beforeInsert(List<Person__c> newRecords){
        for(Person__c person : newRecords){
            //update person status to green
            person.Health_Status__C = 'Green';
            //genetate unique token
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }
// Before Update operson for Person__C object

    public static void beforeUpdate(List<Person__c> newRecords, Map<id, Person__c> oldRecordsMap){

        for(Person__c person : newRecords){

            //check if status changed in this trancation 
            // also upate Status_Update_Date__c

            if( person.Health_Status__C != oldRecordsMap.get(person.id).Health_Status__C){

                person.Status_Update_Date__c = Date.Today();
            }
        }
    }
}