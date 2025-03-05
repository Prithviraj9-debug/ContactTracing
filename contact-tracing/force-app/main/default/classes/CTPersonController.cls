public with sharing class CTPersonController {
    
    public static String getToken(String MobileNo){

        Blob value = blob.valueof(MobileNo);
        Blob hash = Crypto.generateDigest('MD5',value);

    // get string value of hash blob
        return EncodingUtil.base64Encode(hash);
   }

   public static List<Person__c> getRecentHealthChanges(){
    
   /** Get 100 contact with recent helth status chage
    * @return List<Person__c>
    */
   
      return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
      FROM Person__c 
      ORDER BY Status_Update_Date__c DESC NULLs LAST LIMIT 100 ];
    }

    /** search a peron by name , token or mobileNO
    * @return List<Person__c>
    */

    public static List<Person__c> searchPeople(string searchTerm){
       searchTerm = searchTerm + '%';
       return  [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
       FROM Person__c 
       WHERE Name LIKE :searchTerm 
          OR Mobile__c LIKE :searchTerm  
          OR Token__c  LIKE :searchTerm  
       ORDER BY Status_Update_Date__c DESC NULLs LAST];
    }

    /** Search a person by Id
    * @return Person__c
    */

    public static Person__c getPersonById(string personId){
       List<Person__c> people =  [SELECT Name, Id, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
       FROM Person__c 
       WHERE Id = :personId];

       if(people != null && people.size()>0){
        return people[0];
       }
       return null;

    }

    /**
     * Get count of people in each health status
     * @return map<string, integer>
     */

    public static Map<String, Integer> getHealthStstusCount() {
      Map<String, Integer> healthCountMap = new Map<String, Integer>();
      for(AggregateResult ar : [SELECT Health_Status__C, COUNT(Id) total
                                 FROM Person__c
                                 GROUP BY Health_Status__C]){
      
         String HealthStatus =String.valueof(ar.get('Health_Status__C'));
         Integer count = Integer.valueof(ar.get('total'));

         healthCountMap.put(HealthStatus, count);
    }
         return healthCountMap;
   }

   public static set<Id> getCohabitants(set<Id> personids){
      
      List<String> HealthStatuses = new List<String> {'Green', 'Yellow'};

      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                        WHERE (Person_1__c IN : personids OR Person_2__c IN : personids) 
                                        AND Contact_Type__c = 'Cohabitant'
                                        AND Person_1__r.Health_Status__C IN : HealthStatuses OR Person_2__r.Health_Status__C IN :HealthStatuses];
      
      set<ID> Cohabitants = new set<ID>();
      
      for(People_Tracing__c pt : peopleTraces){
         if(!personids.contains(pt.Person_1__c)){
            Cohabitants.add(pt.Person_1__c);
         }
         if(!personids.contains(pt.Person_2__c)){
            Cohabitants.add(pt.Person_2__c);
         }
         return Cohabitants;
      }
   }

   public static set<Id> getNeighbours(set<Id> personids){
      
      

      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                        WHERE (Person_1__c IN : personids OR Person_2__c IN : personids) 
                                        AND Contact_Type__c = 'Neighbour'
                                        AND Person_1__r.Health_Status__C = 'Green' OR Person_2__r.Health_Status__C = 'Green'];
      
      set<ID> neighbours = new set<ID>();
      
      for(People_Tracing__c pt : peopleTraces){
         if(!personids.contains(pt.Person_1__c)){
            neighbours.add(pt.Person_1__c);
         }
         if(!personids.contains(pt.Person_2__c)){
            neighbours.add(pt.Person_2__c);
         }
         return neighbours;
      }
   }

   public static set<Id> getPrimaryContact(set<Id> personids){
      
      List<String> HealthStatuses = new List<String> {'Green', 'Yellow'};

      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                        WHERE (Person_1__c IN : personids OR Person_2__c IN : personids) 
                                        AND Contact_Type__c = 'Other'
                                        AND COntact_Date__c = LAST_N_DAYS:10
                                        AND Person_1__r.Health_Status__C IN : HealthStatuses OR Person_2__r.Health_Status__C IN :HealthStatuses];
      
      set<ID> primaryContacts = new set<ID>();
      
      for(People_Tracing__c pt : peopleTraces){
         if(!personids.contains(pt.Person_1__c)){
            primaryContacts.add(pt.Person_1__c);
         }
         if(!personids.contains(pt.Person_2__c)){
            primaryContacts.add(pt.Person_2__c);
         }
         return primaryContacts;
      }
   }

   public static set<Id> getSecondaryContacts(set<Id> primaryContactsIDs){
      
      

      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                        WHERE (Person_1__c IN : primaryContactsIDs OR Person_2__c IN : primaryContactsIDs) 
                                        AND Contact_Type__c = 'Neighbour'
                                        AND COntact_Date__c = LAST_N_DAYS:10
                                        AND Person_1__r.Health_Status__C = 'Green' OR Person_2__r.Health_Status__C = 'Green'];
      
      set<ID> secondaryContacts = new set<ID>();
      
      for(People_Tracing__c pt : peopleTraces){
         if(!primaryContactsIDs.contains(pt.Person_1__c)){
            secondaryContact.add(pt.Person_1__c);
         }
         if(!primaryContactsIDs.contains(pt.Person_2__c)){
            secondaryContact.add(pt.Person_2__c);
         }
         return secondaryContact;
      }
   }


}
