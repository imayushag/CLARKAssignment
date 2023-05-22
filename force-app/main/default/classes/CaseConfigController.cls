
public with sharing class CaseConfigController {
    @AuraEnabled
    public static List<Case_Config__c> getCaseConfigs(String caseId){
        System.debug('Case Id=====>>  '+caseId);
        return [SELECT Id, Label__c, Type__c, Amount__c FROM Case_Config__c where Case__c=:caseId WITH SECURITY_ENFORCED];    
    }
    @AuraEnabled
    public Static Boolean updateCaseStatus(String caseId){
        
        Case caseRec = [Select id, Status from Case where id=: caseId WITH SECURITY_ENFORCED];
        Boolean isSuccessful= false;
        try{
            if(caseRec.Status!='Closed'){
                
                List<CaseConfigs> caseConfigsList = new List<CaseConfigs>();

                for(Case_Config__c caseConfigRec : [Select Id, Label__c, Type__c, Amount__c from Case_Config__c where Case__c=:caseId WITH SECURITY_ENFORCED]){
                    CaseConfigs caseConfigWrapper = new CaseConfigs();
                    caseConfigWrapper.label= caseConfigRec.Label__c;
                    caseConfigWrapper.type= caseConfigRec.Type__c;
                    caseConfigWrapper.amount= (Integer)caseConfigRec.Amount__c;
                    caseConfigsList.add(caseConfigWrapper);
                }
                SendConfigWrapper requestPayload = new SendConfigWrapper(caseRec.Id, 'Closed',caseConfigsList);
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Send_Case_Configs');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(requestPayload));

                System.debug('JSON request====>>>'+requestPayload);

                HttpResponse res = new Http().send(req);
                System.debug('Response====>>>>>>'+res);
                if (res.getStatusCode() != 200) {
                    throw new CalloutException('Error: ' + res.getStatus() + ' ' + res.getStatusCode());
                }
                else{
                    isSuccessful =true;
                }
            }
            if(isSuccessful){
                caseRec.Status='Closed';
                if(Case.SObjectType.getDescribe().isUpdateable()){
                    Database.update(caseRec);
                }
            }
            System.debug('Status returned====>>>>'+isSuccessful);
            return isSuccessful;
        }
            catch(Exception e) {
                throw new CalloutException('Error: ' + e.getMessage());
            }
    }
    public class SendConfigWrapper{
        public String caseId{get;set;}
        public String status{get;set;}
        public List<CaseConfigs> caseConfigs{get;set;}
        public SendConfigWrapper(String caseId, String status, List<CaseConfigs> caseConfigs) {
            this.caseId = caseId;
            this.status = status;
            this.caseConfigs = caseConfigs;
        }
    }
    public class CaseConfigs{
        public String label{get;set;}
        public String type{get;set;}
        public Integer amount{get;set;}
    }
    
}
