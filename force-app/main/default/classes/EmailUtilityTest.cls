@isTest
private class EmailUtilityTest {
	@testSetup
	static void setupRecords() {
		Contact con = new Contact(LastName = 'TestEmail', Email = 'vip.nepochelovich@gmail.com');
		insert con;

		Contact conWithoutEmail = new Contact(LastName = 'conWithoutEmail');
		insert conWithoutEmail;

		Lead myLead = new Lead(LastName = 'Fry', Company = 'Fry And Sons');
		insert myLead;

		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(myLead.id);
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
		lc.setConvertedStatus(convertStatus.MasterLabel);
		lc.isDoNotCreateOpportunity();
		lc.setOpportunityName('NewOpportunity');
	}

	@isTest
	static void testToSendEmailWithTemplateContactTrue() {
		Test.startTest();
		EmailUtility.toSendEmailWithTemplate('TestEmail', Contact.SObjectType);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, invocations, 'An email has been sent');
	}

	@isTest
	static void testToSendEmailWithTemplateContactWrongName() {
		Test.startTest();
		EmailUtility.toSendEmailWithTemplate('notexistinglastname', Contact.SObjectType);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(0, invocations, 'An email has not been sent');
	}

	@isTest
	static void testToSendEmailWithTemplateOpportunityWrongEmail() {
		Test.startTest();
		EmailUtility.toSendEmailWithTemplate('conWithoutEmail', Contact.SObjectType);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(0, invocations, 'An email has not been sent');
	}

	@isTest
	static void testToSendEmailWithTemplateOpportunityFalse() {
		Test.startTest();
		EmailUtility.toSendEmailWithTemplate('NewOpportunity', User.SObjectType);
		Integer invocations = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(0, invocations, 'An email has not been sent');
	}
}
