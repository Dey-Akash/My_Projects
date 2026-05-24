public class PassengerTriggerHandelerClass
{
	public Static Void ValidateEmail(List<Passenger_Details__c> newlist)
    {
        For(Passenger_Details__c ps : newlist)
        {
            if(ps.Passenger_Email_ID__c == null)
            {
                ps.addError('You Must & Should Put Email');
            }
        }
    }
    
    public Static Void ValidateMobile(List<Passenger_Details__c> newlist)
    {
        For(Passenger_Details__c ps : newlist)
        {
            if(ps.Mobile_Number__c == null)
            {
                ps.addError('You Must & Should Put Mobile Number');
            }
        }
    }
}