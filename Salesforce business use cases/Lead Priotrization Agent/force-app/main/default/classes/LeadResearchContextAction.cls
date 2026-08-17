public with sharing class LeadResearchContextAction 
{
    public class Request
    {
        @InvocableVariable(required=true
                            description='The Id of the Lead to research')
        public Id leadId;
    }
    public class Result
    {
        @InvocableVariable(description='Structured context about the Lead')
        public String context;
    }

    @InvocableMethod(label='Get Lead Research Context'
                      description='Returns a summary of the Lead including recent news')

    public static List<Result> getContext(List<Request> requests)
    {
        // Collect the ids first: one query for the whole batch, rather than one query
        // per request, which would hit the 100-SOQL governor limit at 100 leads.
        Set<Id> leadIds = new Set<Id>();
        for (Request r : requests) {
            if (r.leadId != null) leadIds.add(r.leadId);
        }

        Map<Id, Lead> leadsById = new Map<Id, Lead>(
            [SELECT Id, Company, Industry, Rating, LeadSource,
                    News_Summary__c, News_Mention_Count__c, Last_News_Date__c
             FROM Lead WHERE Id IN :leadIds]);

        List<Result> results = new List<Result>();
        for (Request r : requests) {
            Lead ld = leadsById.get(r.leadId);
            Result res = new Result();

            // The agent may pass an id that has been deleted or is not visible to
            // the running user; return a usable message instead of throwing.
            if (ld == null) {
                res.context = 'No Lead found for Id ' + r.leadId;
                results.add(res);
                continue;
            }

            res.context = 'Company: ' + ld.Company
                + '\nIndustry: ' + (ld.Industry == null ? 'unknown' : ld.Industry)
                + '\nExisting rating: ' + (ld.Rating == null ? 'not set' : ld.Rating)
                + '\nLead source: ' + (ld.LeadSource == null ? 'unknown' : ld.LeadSource)
                + '\nRecent news mentions: ' + ld.News_Mention_Count__c
                + '\nLast mentioned on: ' + ld.Last_News_Date__c
                + '\nHeadlines: ' + (ld.News_Summary__c == null ? 'none' : ld.News_Summary__c);
            results.add(res);
        }
        return results;
    }
}