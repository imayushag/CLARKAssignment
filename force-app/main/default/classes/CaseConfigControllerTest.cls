@isTest
public class CaseConfigControllerTest {
    @TestSetup
    static void setupTestData() {
       	//Create a test user (Consultant)
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
        
        //Create test case record
        Case caseRecord = new Case(Status = 'Open');
        insert caseRecord;

        // Create related test Case_Config__c records
        List<Case_Config__c> caseConfigs = new List<Case_Config__c>{
            new Case_Config__c(Case__c = caseRecord.Id, Label__c = 'Label 1', Type__c = 'Type 1', Amount__c = 100),
            new Case_Config__c(Case__c = caseRecord.Id, Label__c = 'Label 2', Type__c = 'Type 2', Amount__c = 200)
        };
        insert caseConfigs;
    }

    @isTest
    public static void testGetCaseConfigs(){
        User testUser =[SELECT Id FROM User LIMIT 1];
        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        System.runAs(testUser){
            test.startTest();
            List<Case_Config__c> result=CaseConfigController.getCaseConfigs(caseRecord.Id);
            test.stopTest();
            System.assertEquals(2, result.size(),'Related case config records not equal to 2');
        }
    }
    
    @isTest
    public static void testUpdateCaseStatus() {
        
        User testUser =[SELECT Id FROM User LIMIT 1];
        System.runAs(testUser){
      
            // Test data is already set up in the setupTestData() method
            Case caseRecord = [SELECT Id FROM Case LIMIT 1];
            // Mock HTTP response
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            // Call the method being tested
            Test.startTest();
            Boolean result = CaseConfigController.updateCaseStatus(caseRecord.Id);
            Test.stopTest();
            
            Case updatedCaseRecord = [SELECT Id, Status FROM Case WHERE Id = :caseRecord.Id];
            System.assertEquals('Closed', updatedCaseRecord.Status, 'Case Status not updated to Closed');
        }
    }
}