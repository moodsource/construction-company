public with sharing class AccountController {
    @AuraEnabled(cacheable = true)
  public static List<Account> findAccountById(String accountId){
      return [
        SELECT Id,OwnerId,Type,Name,Industry,Budget__c
        FROM Account 
        WHERE Name=:accountId];
  }
}