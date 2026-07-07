public class Cl_GSTCALCULATION_AIRLINE_MANAGEMENT 
{
	public static void applygst(List<Booking__c> NBL)
    {
        List<GST__c> GST = [select Flying_Class__c,GST_VALUE__c from GST__c];
        
        Map<String,Decimal> GSTMAP = New Map<String,Decimal>();
        
        For(GST__c EG : GST)
        {
            GSTMAP.put(EG.Flying_Class__c , EG.GST_VALUE__c);
        }
        For(Booking__c EB : NBL)
        {
            EB.Paying_Fare_With_Gst__c = (GSTMAP.get(EB.Seat_Class__c)/100*EB.Total_Fare__c)+EB.Total_Fare__c;
        }
    }
}