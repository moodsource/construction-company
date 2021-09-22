@isTest
private class OpportunityCalloutTest {
	@TestSetup
	static void createRecords() {
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
			.get('Engineering_Unit')
			.getRecordTypeId();
		Account acct = new Account(Name = 'TestAccount', RecordTypeId = accRecordTypeId);
		insert acct;

		Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
			.get('Worker')
			.getRecordTypeId();
		Contact con = new Contact(
			LastName = 'TestContact',
			Email = 'vip.nepochelovich@gmail.com',
			RecordTypeId = conRecordTypeId,
			Level__c = 'E',
			AccountId = acct.Id
		);
		insert con;

		Partner__c par = new Partner__c(Address__c = 'http://jsonplaceholder.typicode.com/posts', Name = 'testPartner');
		insert par;

		Opportunity oppNew = new Opportunity(
			Name = 'OpportunityNew',
			StageName = 'New',
			CloseDate = System.today().addMonths(1),
			Decision_Maker__c = con.id,
			Type = 'New Customer',
			Partner__c = par.Id,
			Amount = 60
		);
		insert oppNew;
	}
	@isTest
	static void testPostInfo() {
		Opportunity opp = [
			SELECT StageName, Partner__c, Name, Amount, Type
			FROM Opportunity
			WHERE Name = 'OpportunityNew'
		];

		Partner__c par = [SELECT Name, Address__c FROM Partner__c WHERE id = :opp.Partner__c];
		Test.setMock(HttpCalloutMock.class, new OpportunityCalloutMock());
		Test.startTest();
		opp.StageName = 'Shared';
		update opp;
		Test.stopTest();
	}
}
