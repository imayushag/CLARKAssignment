@isTest
public class ConfigsControllerTest {

     @TestSetup
    static void setupTestData() {
        //Create a test User (Consultant profile)
        Profile userProfile = [SELECT Id FROM Profile where Name='Consultant'];
        User objUser = new User(FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'Consultant'+String.valueOf(System.today())+'@test.com',
            Alias = 'tuser',
            ProfileId = userProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US');
        insert objUser;
        
        // Create a test Case record
        Case caseRecord = new Case();
        insert caseRecord;

        // Create sample Config__c records
        List<Config__c> configList = new List<Config__c>{
            new Config__c(Label__c = 'Config 1', Type__c = 'Type 1', Amount__c = 100),
            new Config__c(Label__c = 'Config 2', Type__c = 'Type 2', Amount__c = 200),
            new Config__c(Label__c = 'Test', Type__c = 'TestType', Amount__c = 2000)
        };
        insert configList;

        // Create sample Case_Config__c records associated with the test Case record
        List<Case_Config__c> caseConfigList = new List<Case_Config__c>{
            new Case_Config__c(Case__c = caseRecord.Id, Label__c = 'Test', Type__c = 'TestType', Amount__c = 2000)
        };
        insert caseConfigList;
    }
    
    @isTest
    public static void testGetConfigs() {
        User testUser = [SELECT Id FROM User LIMIT 1];
            System.runAs(testUser){
            test.startTest();
            // Get Configs test
            List<Config__c> result = ConfigsController.getConfigs();
            test.stopTest();
            // Assert the expected results
            System.assertEquals(3, result.size(), 'Size of records not equal to 3');
        }
    }

    @isTest
    public static void testAddConfigsTrue() {
        
        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser){
            Case caseRecord = [SELECT Id FROM Case LIMIT 1];
            List<Config__c> availableConfigs = [Select Id, Label__c, Type__c, Amount__c from Config__c];
            test.startTest();
            // Add Configs to case for Case record Id
            Boolean result = ConfigsController.addConfigs(availableConfigs, caseRecord.Id);
            test.stopTest();
            // Assert the expected results
            System.assertEquals(true,result,'Result came as false, expecting true');
        }
        
    }
    
    @isTest
    public Static void testAddConfigsFalse(){
        User testUser = [Select Id from User LIMIT 1];
        System.runAs(testUser){
            Case caseRecord = [SELECT Id FROM Case LIMIT 1];
            List<Config__c> availableConfigs = [SELECT Id, Label__c, Type__c, Amount__c FROM Config__c WHERE Label__c='Test'];
            test.startTest();
            // Call the method being tested
            Boolean result = ConfigsController.addConfigs(availableConfigs, caseRecord.Id);
            test.stopTest();
            System.assertEquals(false, result, 'Result came as true, expecting false');
        }
    }
}