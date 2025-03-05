public with sharing class CTLocationTracingController {

    /**
     * Get last 30 days visitor
     * @param locationid
     * @return List<Location_Tracing__c>
     */
    
    public static List<Location_Tracing__c> getVistors(string locationId){
        return [SELECT Id, Person__c, Location__c, Visit_Date__c, Person__r.Token__C, Person__r.Health_Status__c 
        FROM Location_Tracing__c 
        WHERE Id = :locationId
        ORDER BY Visit_Date__c DESC];
    }
    /**
     * Get all location ids from visitor
     * @param personids
     * @return List<Location_Tracing__c>ocation_Tracing__c
     */

    public static List<Location_Tracing__c> getLocationsByPersonId(Set<Id> personIds){
        return [SELECT Id, Person__c, Location__c
        FROM Location_Tracing__c 
        WHERE Person__c IN :personIds
        AND Visit_Date__c = LAST_N_DAYS:10];
    }
    
    /**
     * Get all visitors ids from location
     * @param personids
     * @return List<Location_Tracing__c>
     */

    public static List<Location_Tracing__c> getLocationByLocationIds(set<Id> locationIds){
    return [SELECT Id, Person__c, Location__c
    FROM Location_Tracing__c 
    WHERE Location__c IN :locationIds
    AND Person__r.Health_Status__c = 'Green'
    AND Visit_Date__c = LAST_N_DAYS:10];
}

public static List<Location_Tracing__c> checkDuplicates (List<Location_Tracing__c> newLocationTraces){
   // store unique location ids
    set<Id> locationIds = new set<Id>();
    //store unique person ids
    set<Id> personIds = new set<Id>();  

    for(Location_Tracing__c Traces : newLocationTraces ){
        locationIds.add(Traces.Location__c);
        personIds.add(Traces.Person__c);
    }

      Map<Id, set<Id>> mapOfExistingRecords = new Map<Id, set<Id>>();
       List<Location_Tracing__c> existingRecords =[SELECT Id, Person__c, Location__c
                                                        FROM Location_Tracing__c 
                                                        WHERE Location__c IN :locationIds
                                                        AND Person__c IN :personIds];

    //list of duplicate records

    List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        if(existingRecords != null && existingRecords.size()>0){
            for(Location_Tracing__c Trace : existingRecords){
                 string locationId = Trace.Location__c;
                 string personId = Trace.Person__c;

    //check if map already has locationId key

            if(! mapOfExistingRecords.containsKey(locationId)){

    //map do not have this key
    // add this new item into the map using locationId key
    // add blank set as value
                mapOfExistingRecords.put(locationId, new set<Id>());
            }
    //get map item using locationId key
        set<Id> personIdss = mapOfExistingRecords.get(locationId);
        // add personId to set 
        personIdss.add(personId);
        // overwrite the exisiting map values
        mapOfExistingRecords.put(locationId, personIdss );
            }
    // loop over new location_tracing record
        for(Location_Tracing__c Trace : newLocationTraces ){
            // first check for locationId 
            // if item found in map check for personId
            if(mapOfExistingRecords.containsKey(Trace.Location__c) 
                && mapOfExistingRecords.get(Trace.Location__c).contains(Trace.Person__c)){
                    duplicates.add(Trace);
                }
            }
        }
        return duplicates;
        }
    }
    






