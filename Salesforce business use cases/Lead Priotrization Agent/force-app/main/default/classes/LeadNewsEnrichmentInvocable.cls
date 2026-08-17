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
        List<Id> leadIds = new List<Id>();
        List<String> companyNames = new List<String>();

        for (Request req : requests)
        {
            if (req.leadId == null) continue;
            leadIds.add(req.leadId);
            companyNames.add(req.companyName);
        }

        // One job for the whole batch. Enqueueing per record breaks the moment more
        // than 50 leads are inserted in a single transaction, because Apex allows
        // only 50 queueable jobs per transaction.
        if (!leadIds.isEmpty())
        {
            System.enqueueJob(new LeadNewsEnrichmentQueueable(leadIds, companyNames));
        }
    }
}
