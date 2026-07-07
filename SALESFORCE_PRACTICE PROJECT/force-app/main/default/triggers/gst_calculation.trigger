trigger gst_calculation on Booking__c (before insert , before update) 
{
	Cl_GSTCALCULATION_AIRLINE_MANAGEMENT.applygst(Trigger.New);
}