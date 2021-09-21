@isTest
private class OpportunityTriggerTest {
	public class IvalidStageException extends Exception {
	}
	@testSetup
	static void setupRecords() {
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

		Id consRecordTypeId = Schema.SObjectType.Construction__c.getRecordTypeInfosByDeveloperName()
			.get('Building')
			.getRecordTypeId();
		Construction__c cons = new Construction__c(
			Name = 'TestConstruction',
			Billing_Company__c = acct.Id,
			Owner_Company__c = acct.Id,
			RecordTypeId = consRecordTypeId
		);
		insert cons;

		Opportunity oppNew = new Opportunity(
			Name = 'OpportunityNew',
			StageName = Constants.OPP_STAGE_NEW,
			CloseDate = System.today().addMonths(1),
			Decision_Maker__c = con.id
		);
		insert oppNew;

		Opportunity oppQuoteSent = new Opportunity(
			Name = 'OpportunityQuoteSent',
			StageName = Constants.OPP_STAGE_QUOTE_SENT,
			CloseDate = System.today().addMonths(1),
			Decision_Maker__c = con.id
		);
		insert oppQuoteSent;

		Work_Breakdown_Structure__c wbs = new Work_Breakdown_Structure__c(
			Name = 'TestBreakdown',
			Status__c = 'Draft',
			Opportunity__c = oppNew.Id,
			Construction__c = cons.Id,
			Account__c = acct.Id
		);
		insert wbs;
		wbs.Status__c = Constants.WBS_STATUS_SENT;
		update wbs;

		Work_Breakdown_Structure__c wbsSynced = new Work_Breakdown_Structure__c(
			Name = 'TestBreakdownSynced',
			Status__c = 'Draft',
			Opportunity__c = oppQuoteSent.Id,
			Construction__c = cons.Id,
			Account__c = acct.Id,
			IsSynced__c = true
		);
		insert wbsSynced;

		oppQuoteSent.Work_Breakdown_Structure__c = wbsSynced.id;
		update oppQuoteSent;

		Product2__c prod = new Product2__c(Name = 'TestProduct', Type__c = 'Work', Price__c = 70);
		insert prod;

		Work_Breakdown_Structure_Item__c wbsi = new Work_Breakdown_Structure_Item__c(
			Name = 'TestItem',
			Work__c = prod.id,
			Unit_Of_Measure__c = 'Hours',
			Quantity__c = 4,
			Work_Breakdown_Structure__c = wbs.Id,
			Account__c = acct.id,
			Work_Assignment__c = con.id
		);
		insert wbsi;
	}

	@isTest
	static void testChangeOnQuoteSentStageTrue() {
		Opportunity opp = [SELECT StageName FROM Opportunity WHERE Name = 'OpportunityQuoteSent'];
		opp.StageName = 'Draft Quote';
		update opp;
		Work_Breakdown_Structure__c wbs = [
			SELECT Status__c
			FROM Work_Breakdown_Structure__c
			WHERE Name = 'TestBreakdownSynced'
		];

		System.assertEquals(Constants.WBS_STATUS_REJECTED, wbs.Status__c);
	}

	@isTest
	static void testOppStageChangeTrue() {
		Opportunity opp = [SELECT StageName FROM Opportunity WHERE Name = 'OpportunityQuoteSent'];
		opp.StageName = Constants.OPP_STAGE_CLOSED_WON;

		System.assertEquals(true, Database.update(opp).isSuccess());
	}

	@isTest
	static void testOppStageChangeFalse() {
		Opportunity opp = [SELECT StageName FROM Opportunity WHERE Name = 'OpportunityNew'];
		try {
			opp.StageName = Constants.OPP_STAGE_CLOSED_WON;
			update opp;
			throw new IvalidStageException('An exception should have been thrown by the trigger but was not.');
		} catch (Exception e) {
			Boolean expectedExceptionThrown = e.getMessage()
				.contains('You can only change Quote Sent and Negotiation status on Closed Won.');

			System.assertEquals(true, expectedExceptionThrown);
		}
	}
}
