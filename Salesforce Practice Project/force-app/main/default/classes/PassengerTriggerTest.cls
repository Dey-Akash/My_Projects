@istest
public class PassengerTriggerTest 
{
	@istest
    public static void EmailTest()
    {
        Passenger_Details__c P = New Passenger_Details__c();
        P.FirstName__c = 'Test';
        P.LastName__c = 'testtt';
        P.Mobile_Number__c = '99656412';
        P.Passenger_Email_ID__c = 'no@email.com';
        Insert P;
        
        System.AssertEquals('no@email.com',P.Passenger_Email_ID__c);
        System.AssertEquals('99656412', P.Mobile_Number__c);
     }
}