public with sharing class IterationInLwcController {  
  @AuraEnabled(cacheable = true)
  public static List<Account> fetchAllAccounts(String actName){
    if (actName != 'All Types') 
    {
      return [
        SELECT Id,Name,Type,Budget__c,OwnerId,NumberOfEmployees 
        FROM Account 
        WHERE Type = :actName
      ];
    }
    else 
    {
      return [
        SELECT Id,Name,Type,Budget__c,OwnerId,NumberOfEmployees 
        FROM Account 
        LIMIT 10
      ];
    }
  }
}