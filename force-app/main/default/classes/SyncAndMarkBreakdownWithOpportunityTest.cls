@isTest
private class SyncAndMarkBreakdownWithOpportunityTest {
    @testSetup static void setupRecords() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Engineering_Unit').getRecordTypeId();
        Account acct = new Account(Name='TestAccount', RecordTypeId = accRecordTypeId);
        insert acct;
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Worker').getRecordTypeId();
        Contact con = new Contact(LastName='TestContact', Email = 'vip.nepochelovich@gmail.com', RecordTypeId = conRecordTypeId, Level__c='E', 	AccountId=acct.Id);
        insert con;
        
        Id consRecordTypeId = Schema.SObjectType.Construction__c.getRecordTypeInfosByDeveloperName().get('Building').getRecordTypeId();
        Construction__c cons = new Construction__c(Name='TestConstruction',
                                                   Billing_Company__c = acct.Id,
                                                   Owner_Company__c = acct.Id,
                                                  RecordTypeId = consRecordTypeId);
        insert cons;
        
        Opportunity opp = new Opportunity(Name='NewOpportunity',
                                          StageName='New',
                                          CloseDate=System.today().addMonths(1),
                                          Decision_Maker__c = con.id);
        insert opp;
        
        Work_Breakdown_Structure__c wbs = new Work_Breakdown_Structure__c(Name='TestBreakdown',
                                                                          Status__c = 'Draft',
                                                                          Opportunity__c = opp.Id,
                                                                         Construction__c = cons.Id,
                                                                         Account__c = acct.Id);
        insert wbs;
        
        Product2__c prod = new Product2__c(Name='TestProduct',Type__c='Work',Price__c = 70);
        insert prod;
        
        Work_Breakdown_Structure_Item__c wbsi = new Work_Breakdown_Structure_Item__c(Name='TestItem',
                                                                                    Work__c=prod.id,
                                                                                    Unit_Of_Measure__c='Hours',
                                                                                    Quantity__c = 4,
                                                                                    Work_Breakdown_Structure__c=wbs.Id,
                                                                                    Account__c=acct.id,
                                                                                    Work_Assignment__c= con.id);
        insert wbsi;
        wbs.Status__c = 'Sent';
        update wbs;
	}
    @isTest static void testMarkSyncedBreakdownTrue() {
        Work_Breakdown_Structure__c wbs = [SELECT Status__c, IsSynced__c FROM Work_Breakdown_Structure__c WHERE Name='TestBreakdown'];
        System.assertEquals(true, wbs.IsSynced__c);
    }
}