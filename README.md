Clark Assignment Solution - Ayush Agarwal

============================================
Tasks:
============================================

Task 0-> Create a Profile e.g. Consultant which will be our end user profile.

Task 1-> Setup Data Model. Create Config and Case Config objects and its fields. Make Case Config Name field as Auto Number type to help in identifying. Assign Object, Field level permissions to Consultant and System Admin profiles. 

Task 2-> Create Client side (LWC) and Server Side (Apex classes) as per the requirement. I have used a Parent component on top of two expected components (Available Configs and Case Configs). Expose both child components(Available Configs and Case Configs) on UI. For Apex controllers, verify field level, object level permissions.

Task 3-> Apply best practices in the code base.

Task 4-> Add Parent LWC component on the Case Record Page, Assign it to App/Record Page across App and/or Profile. This will make the Component visible to the end users.

Task 5-> Use Lightning Datatable with multi select checkbox on Available Configs to get data from the Server side(Apex classes). Add button will enable automatically once a record is selected.

Task 6-> Apply sorting based on column click. Both Ascending and descending order.

Task 7-> Apply Pagination on Available Configs with default records per page, total records, first, last, previous, next buttons.

Task 8-> Implement Communication between the 2 components. For that, I have used my Parent component majorly to pass data between the components. Have used api variables and custom events for this.

Task 9-> Update Case Config component when a Config is added. Make sure it gets added to the database as a Case Config record related to current Case. If it is already added then show an error message event.

Task 10-> Create a Named Credential with Endpoint url of Request Catcher custom endpoint.

Task 11-> Send Case Configs. When there are 1 or more than 1 records in Case Config datatable, Send button gets enabled. When User clicks on Send button, a callout is made to an external service with Named credential as an endpoint and POST request with below JSON format:

{
"caseId": "50068000005QOhbAAG",
"status": "Closed",
"caseConfigs": [{
"label": "Test Label",
"type": "Test Type",
"amount": 10.00 }]
}

On 200 Response, Record gets refreshed and Case Status changes to "Closed". Also, the Request Catcher gets the POST request from our side. This shows we got 200 Response from RequestCatcher.

Task 12-> Prevent further addition of Configs and disable Sending Case Configs when Case is closed.  

Task 13-> Do cosmetic changes on the UI. Make it more presentable.

Task 14-> Creating Test Class. Achieved 96.5% code coverage. No Errors, with System.assertequals statements. 

Task 15-> Do an end-to-end unit testing with positive and negative scenarios in mind.

Task 16-> Make a demo presentation/walkthrough of the assignment design solution.

Task 16-> Deploy the code using git and sfdx commands to my git repository. Ensure it is deployable using sfdx commands.

Task 17-> Update ReadMe.md file.

============================================
Screen recording: https://drive.google.com/file/d/18YH81DStthHKwenpitS7t_ITGrhGv8xo/view?usp=share_link
============================================

============================================
Steps to Test:
============================================

1. Create your playground/Developer Org. Set your login credentials to access it.
2. Fork the repository. Use the forked repository in Visual Studio Code.
3. Authorise the org with your login credentials (from step 1) using => sfdx force:auth:web:login -a <alias>.
4. Push everything on the org using => sfdx force:source: deploy
5. Go to the Playground/Dev org and go to Clark Assignment App. You can create a user with Consultant profile too and test, but for simplicity lets assume you are doing through System Admin User.
6. On Clark Assignment App, you can see 3 tabs - Case, Configs and Case Configs.
7. Create atleast 7-10 records of Configs. Create 2-3 open cases.
8. Go to any open case and you will see List of Available configs(from step 7). You can select >=1 and add them to Case Configs.
9. Switch to Case Configs tab to see a record also created when you add on Case record page. 
10. For a case, if there is one or more than 1 case config record present, and Case is not closed, then User can send the Case Configs to external service and the component will update current case status to close if a response was OK.
11. Once the Case Status is closed, both Send and Add button will be disabled. Also, the user won't be able to change the status of case due to Validation rule.
12. You can verify on Request Catcher with endpoint url mentioned in Named Credential that if a successful POST call was made from Salesforce side.
13. Some preventive measures you can test:
a) If no records selected in Available configs then Add button is disabled
b) If no records in Case Configs then Send button is disabled
c) If already some Available config records present in Case Configs then they won't be added again


============================================
Assumptions:
============================================
1. I have used a brand new Playground to handle this assignment. 
2. All 3 columns of Available Configs and Case Configs (Label, Type and Amount) have sorting enabled.
3. By default Add and Send button will be disabled for a fresh case.
4. If a user tries to Add already added Config records (Label is checked for that related case record), an error message will be shown to the user. If a new record is present with existing records, than a success toast msg will be displayed and the new Config record will be added to Case configs.
5. If a Config record is already added as Case Config on another Case record, the user won't be allowed to add it to the current case even if it doesn't show on the Case Config table. We can resolve this issue if Label Field of Case Config object doesn't have Unique constraint.
6. A Named credential has been created for sending callout to external system. This Named credential will be valid for 48 hours, post that it has to be updated with the New URL before using it.
7. When Case Status is updated to Closed after 200 Response from RequestCatcher external service, record will be refreshed and Case will be Closed. Also, the user will see disabled Add and Send buttons. Even if he selects available config, the button won't be enabled.
8. For Pagination, the default records per page is taken as 5.