import { LightningElement, api , wire} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
const fields = [STATUS_FIELD];

export default class ParentConfigComponent extends LightningElement {

    @api recordId;
    handleConfigs(event){
        console.log('event from available configs',event);
        this.template.querySelector("c-case-configs").catchEvent();
    }


    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    get status() {
        return getFieldValue(this.case.data, STATUS_FIELD);
    }
    get isStatusClosed(){
        if(this.status=='Closed'){
            return true;
        }
        return false;
    }
    handleSend(event){
        this.template.querySelector('c-show-available-congig').isCaseClosed=true;
    }

}