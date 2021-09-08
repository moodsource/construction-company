@isTest
private class ThrowExceptionIfOppStageIsInvalidTest {
    @testSetup static void setupRecords() {
        Account acct = new Account(Name='TestAccount');
        insert acct;
		Opportunity oppNew = new Opportunity(Name= 'NewOpportunity',
                                       StageName='New',
                                       CloseDate=System.today().addMonths(1),
                                       AccountId=acct.Id);
        insert oppNew;
        Opportunity oppNegotiation = new Opportunity(Name= 'NewOpportunity2',
                                       StageName='Negotiation',
                                       CloseDate=System.today().addMonths(1),
                                       AccountId=acct.Id);
        insert oppNegotiation;
	}
    @isTest static void testOppStageChangeFalse() {
        Opportunity opp = [SELECT StageName FROM Opportunity Where Name = 'NewOpportunity2'];
        try
        {
            opp.StageName = 'Closed Won';
            update opp;
            throw new IvalidStageException('An exception should have been thrown by the trigger but was not.');
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot change Quote Sent and Negotiation status on Closed Won.') ? true : false;
            System.AssertEquals(true, expectedExceptionThrown);
        }
    }    
    @isTest static void testOppStageChangeTrue() {
        Opportunity opp = [SELECT StageName FROM Opportunity Where Name = 'NewOpportunity'];
        opp.StageName = 'Closed Won';
        update opp;
        System.assertEquals(True, Database.update(opp).isSuccess());
    } 
}