@isTest
private Class TestAccountController{
    @isTest static void CheckAccountSearch(){
        String name = 'United Oil & Gas, UK';
        List<Account> Value1 = [
          SELECT Id,OwnerId,Type,Name,Industry,Budget__c
          FROM Account 
          WHERE Name=:name
        ];
        List<Account> Value2 = AccountController.findAccountById(name);
        System.assertEquals(Value1,Value2);
    }
}