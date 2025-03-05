public with sharing class CTPeopleTracingController {

    public static List<People_Tracing__c> getTraces(string PersonId){

        return [SELECT Id, Contact_Date__c, Person_1__c, Person_1__r.Health_Status__C, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__C, Person_2__r.Token__c 
                   FROM People_Tracing__c 
                   WHERE Person_1__c = :PersonId 
                   OR Person_2__C = :PersonId
                  ORDER BY Contact_Date__c DESC];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){
          
      Set<Id> personIds = new Set<Id>();
    for(People_Tracing__c Trace : newPeopleTraces){
      personIds.add(Trace.Person_1__c);
      personIds.add(Trace.Person_2__c);
    }
    
    //List of duplicate records

    List<People_Tracing__c> duplicate = new List<People_Tracing__c>();

    // map id and set id

    Map<Id, set<Id>> mapOfExistingRecords = new Map<Id, set<Id>>();
    
    // query existing records
    List<People_Tracing__c> existingRecords = [ Select Id, Person_1__C, Person_2__c 
                                                 FROM People_Tracing__c
                                                 WHERE Person_1__c IN :personIds 
                                                 OR PErson_2__c IN :personIds];
     
     if(existingRecords != null && existingRecords.size()>0){
        for(People_Tracing__c Traces : existingRecords){
            if(!mapOfExistingRecords.containsKey(Traces.Person_1__c)){

                mapOfExistingRecords.put(Traces.Person_1__c, new set<Id>());
            }
            mapOfExistingRecords.get(Traces.Person_1__C).add(Traces.Person_2__c);

            //build map for person 2
            if(!mapOfExistingRecords.containsKey(Traces.Person_2__c)){

                mapOfExistingRecords.put(Traces.Person_2__c, new set<Id>());
            }
            mapOfExistingRecords.get(Traces.Person_2__C).add(Traces.Person_1__c);
        }
       // loop over existring record to find duplicates
        for(People_Tracing__c Trace : newPeopleTraces)
       
        //check for duplicates in map
        if(
            (mapOfExistingRecords.containsKey(Trace.Person_1__c) && mapOfExistingRecords.get(Trace.Person_1__c).contains(Trace.Person_2__c))
            ||
            (mapOfExistingRecords.containsKey(Trace.Person_2__c) && mapOfExistingRecords.get(Trace.Person_2__c).contains(Trace.Person_1__c))
          )
        {
            duplicate.add(Trace);
        }
    }


     return duplicate;
}
     



    }
