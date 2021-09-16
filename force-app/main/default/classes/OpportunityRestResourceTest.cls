@isTest
private class OpportunityRestResourceTest {
	@TestSetup
	private static void testSetup() {
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
	private static void testUpsertOpportunityAndPartner() {
		Opportunity opp1 = [
			SELECT StageName, Partner__c, Name, Amount, Type, id
			FROM Opportunity
			WHERE Name = 'OpportunityNew'
		];
		Partner__c par = [SELECT Name, Address__c FROM Partner__c WHERE id = :opp1.Partner__c];
		System.assert(opp1 != null);
		System.assertEquals(opp1.Amount, 60);
		ID opp2Id = OpportunityRestResource.upsertOpportunityAndPartner(
			'testPartner',
			'OpportunityNew',
			100,
			'New Customer'
		);
		System.assertEquals(opp1.Id, opp2Id);
		Opportunity opp2 = [SELECT Amount FROM Opportunity WHERE Id = :opp2Id];
		System.assert(opp2 != null);
		System.assertEquals(opp2.Amount, 100);
	}
}
