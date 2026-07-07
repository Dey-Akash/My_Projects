public class BookingTriggerHandelerClass
{
	public Static void validetEmail(List<Booking__c> newlist)
    {
        For(Booking__c bk : newlist)
        {
            if(bk.Passenger_Email__c == null)
            {
                bk.addError('Email Should Not Be Empty');
            }
        }
    }
}