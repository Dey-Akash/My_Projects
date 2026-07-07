public with sharing class LeadResearchContextAction {
    public class Request {
        @InvocableVariable(required=true
                            description='The Id of the Lead to research')
        public Id leadId;
    }
    public class Result {
        @InvocableVariable(description='Structured context about the Lead')
        public String context;
    }

    @InvocableMethod(label='Get Lead Research Context'
                      description='Returns a summary of the Lead including recent news')
    public static List<Result> getContext(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request r : requests) {
            Lead ld = [SELECT Company, Industry, Rating, LeadSource,
                              News_Summary__c, News_Mention_Count__c, Last_News_Date__c
                       FROM Lead WHERE Id = :r.leadId LIMIT 1];
            Result res = new Result();
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