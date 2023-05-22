import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getConfigs from '@salesforce/apex/ConfigsController.getConfigs';
import addConfigs from '@salesforce/apex/ConfigsController.addConfigs';

const PAGE_SIZE = 5;

const columns = [
    { label: 'Label', fieldName: 'Label__c', type: 'text', sortable: true },
    { label: 'Type', fieldName: 'Type__c', type: 'text', sortable: true },
    { label: 'Amount', fieldName: 'Amount__c', type: 'currency', sortable: true }
  ];

export default class AvailableConfigs extends LightningElement {

    @api recordId;
    @api isCaseClosed;
    @track selectedRows = [];
    
    data = [];
    columns = columns;
    totalConfigs;
    visibleConfigs;
    totalRecords = 0;
    pageSize;
    totalPages;
    pageNumber = 1;
    recordsToDisplay = [];

    pageSizeOptions = [
        { label: '5', value: '5' },
        { label: '10', value: '10' },
        { label: '25', value: '25' },
        { label: '50', value: '50' }
    ];

    sortBy;
    sortDirection;
   
    connectedCallback() {
        getConfigs().then(result => {
                this.data = result;
                this.totalRecords = result.length; //update count of total records
                this.pageSize = String(PAGE_SIZE); //set page size with default value
                this.paginationHelper(); // calling helper method to execute pagination 
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleRowSelection(event){
        this.selectedRows=event.detail.selectedRows;
    }

    handleClick(){
        if(this.selectedRows.length>0){
            addConfigs({availableConfig:this.selectedRows, caseRecordId:this.recordId})
                .then(result=>{
                    if(result){
                            const event = new ShowToastEvent({
                                title: 'Successfully Added Configs',
                                message:'Selected Configs have been added to Case Config.',
                                variant: 'success'
                            });
                            this.dispatchEvent(event);
                            const sendconfigs= new CustomEvent("sendconfigs");
                            this.dispatchEvent(sendconfigs);
                        
                    }
                    else{
                        const event = new ShowToastEvent({
                            title: 'Error in Adding Configs',
                            message:'Cannot process the records.',
                            variant: 'error'
                        });
                        this.dispatchEvent(event);
                    }
                }).catch(error=>{
                    const event = new ShowToastEvent({
                        title: 'Cannot Add selected Configs',
                        message:'Got an exception/ Label is/are already present on other case',
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                })
                .finally(()=>{
                    this.template.querySelector('lightning-datatable').selectedRows=[];
                })
        }
    }

    get disableButton(){
        return this.selectedRows.length===0|| this.isCaseClosed;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.recordsToDisplay = parseData;
    }   
    
    get disableFirst() {
        return this.pageNumber == 1;
    }
    get disableLast() {
        return this.pageNumber == this.totalPages;
    }


    handleRecordsPerPage(event) {
        this.pageSize = event.detail.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    
    paginationHelper() {
        this.recordsToDisplay = [];
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.data[i]);
        }
    }

}