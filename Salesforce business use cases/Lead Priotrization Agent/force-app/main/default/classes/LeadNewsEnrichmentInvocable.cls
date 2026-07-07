public with sharing class LeadNewsEnrichmentInvocable 
{
    public class Request 
    {
        @InvocableVariable(required=true)
        public Id leadId;
        @InvocableVariable(required=true)
        public String companyName;
    }

    @InvocableMethod(label='Enqueue Lead News Enrichment'
                      description='Queues an async job to fetch news for a Lead')
    public static void enqueueEnrichment(List<Request> requests) 
    {
        for (Request req : requests) 
        {
            System.enqueueJob(new LeadNewsEnrichmentQueueable(req.leadId, req.companyName));
        }
    }
}
