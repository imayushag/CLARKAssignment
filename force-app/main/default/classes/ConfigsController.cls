public with sharing class ConfigsController {
    
    @AuraEnabled
    public static List<Config__c> getConfigs() {
        return [SELECT Id, Label__c, Type__c, Amount__c FROM Config__c WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static Boolean addConfigs(List<Config__c> availableConfig, String caseRecordId) {
        Set<String> labels = new Set<String>();
        List<Case_Config__c> addCaseConfig = new List<Case_Config__c>();
        
        for (Case_Config__c config : [SELECT Label__c FROM Case_Config__c WHERE Case__c = :caseRecordId WITH SECURITY_ENFORCED]) {
            if (config.Label__c != null) {
                labels.add(config.Label__c);
            }
        }
        
        for (Config__c configAdd : availableConfig) {
            if (!labels.contains(configAdd.Label__c)) {
                addCaseConfig.add(
                    new Case_Config__c(
                        Label__c = configAdd.Label__c,
                        Type__c = configAdd.Type__c,
                        Amount__c = configAdd.Amount__c,
                        Case__c = caseRecordId
                    )
                );
            }
        } 

        if (!addCaseConfig.isEmpty()) {
            if (Case_Config__c.SObjectType.getDescribe().isCreateable()) {
                Database.insert(addCaseConfig);
                return true;
            }
        }
        
        return false;
    }
}
