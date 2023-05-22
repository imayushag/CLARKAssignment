import { LightningElement , api, wire} from 'lwc';
import getCaseConfigs from '@salesforce/apex/CaseConfigController.getCaseConfigs';
import updateCaseStatus from '@salesforce/apex/CaseConfigController.updateCaseStatus';
import { getRecord, updateRecord , refreshRecord} from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Label', fieldName: 'Label__c' , type:'text', sortable:"true"},
    { label: 'Type', fieldName: 'Type__c', type:'text' , sortable:"true"},
    { label: 'Amount', fieldName: 'Amount__c', type:'Currency', sortable:"true" }
  ];
export default class CaseConfigs extends LightningElement {

    data=[];
    columns = columns;
    
    totalCaseConfigs=0;
    pageSize =2;
    error;
    sortBy;
    sortDirection;
    @api isCaseClosed;
    @api recordId;

    @wire(getRecord,{ recordId: '$recordId', layoutTypes: ['Full'] })
    caseConfigs;

    connectedCallback(){
       this.catchEvent();
    }

    @api catchEvent(){
        getCaseConfigs({caseId:this.recordId}).then(result=>{
            this.data=result;
            console.log('Data retrieved ===>>',this.data.length);
        })
        .catch(error => {
            this.error = error;
            console.log('Caught error');
        });
    }

    get disableButton(){
        console.log('Disable value+++++',this.data.length);
        return this.data.length===0||this.isCaseClosed;
    }

    handleClick(){
        if(this.data.length>0){
            updateCaseStatus({caseId:this.recordId}).then(result=>{
                if(result){

                    const event = new ShowToastEvent({
                        title: 'Successfully Sent Case Configs',
                        message:'Case has been successfully closed',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    window.location.reload();
                }
                else{
                    const event = new ShowToastEvent({
                        title: 'Cannot Update Case',
                        message:'Unable to process Send request',
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                }
            }).catch(error=>{
                this.error=error;

            })
           
        }
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }    
}