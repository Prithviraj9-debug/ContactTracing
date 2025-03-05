public with sharing class CTLocationController {

    /**
     * Get 100 location with recent status change 
     * @return List<location__c>
     */

    public static List<Location__c> getRecentStatusChanges(){
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
        FROM Location__c 
        ORDER BY Status_Update_Date__c DESC NULLs LAST LIMIT 100];
    }

    /**
     * search location by name, zip, and address
     * @return List<Location__c>
     */

    public static List<Location__c> searchLoaction(string searchTerm){
        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
        FROM Location__c 
        WHERE Name LIKE :searchTerm 
            OR Pincode__c LIKE :searchTerm
            OR Address__c LIKE :searchTerm
        ORDER BY Status_Update_Date__c DESC NULLs LAST ];
    }

    /**
     * search location by Id
     * @return Location__c
     */

    public static Location__c getLocationById(string locationId){

       List<Location__c> locations = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
       FROM Location__c 
       WHERE Id =:locationId];

       if(locations != null && locations.size()>0){
        return locations[0];

       }
       return null;
    }

    /**
     * get count of location in each status
     * @return Map<String, Integer>
     */

    public static Map<String, Integer> HealthStatusCount() {
        Map<String, Integer> HeathStatusCountMap = new  Map<String, Integer>();

        for(AggregateResult ar : [SELECT Status__c, COUNT(Id) total
                                    FROM Location__c
                                    GROUP BY Status__c ]) {
        String HealthStatus = String.valueof(ar.get('Status__c'));
        Integer count = Integer.valueof(ar.get('total'));
        
        HeathStatusCountMap.put(HealthStatus, count);
     }
         return HeathStatusCountMap;
        
    }

       
    }
