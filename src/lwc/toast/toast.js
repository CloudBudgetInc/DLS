import { LightningElement, api } from 'lwc';

export default class Toast extends LightningElement {
    @api type; //type values are error, success, warning, info
    @api message; //message to show in toast

    _showTypeIcon = true;
    _dismissibleDuration = 5000;
    _mode = 'dismissible';

    connectedCallback(){
        if(this._mode == 'dismissible'){
            setTimeout(function() {
                this.closeToast();
            }.bind(this), this._dismissibleDuration);
        }
    }

    get showTypeIcon(){
        return this._showTypeIcon;
    }
    @api
    set showTypeIcon(value){
        this._showTypeIcon = value == 'false' ? false : true;
    }

    get dismissibleDuration(){
        return this._dismissibleDuration;
    }
    @api
    set dismissibleDuration(value){ //default - 5000 ms
        this._dismissibleDuration = value;
    }

    get mode(){
        return this._mode;
    }
    @api set mode(value){   //mode values are dismissible - default, sticky 
        this._mode = value;
    }

    get showAnyMsg()
    {
        return this.type !== undefined && this.message !== undefined;
    }

    get notificationThemeClass() {
        return "slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_" +this.type;
    }

    get notificationContainerClass() {
        return (
            "slds-icon_container slds-icon-utility-" +this.type +" slds-m-right_x-small"
        );
    }

    get iconName(){
        return 'utility:'+this.type;
    }

    get iconClass() {
        return (
            "/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#" + this.type
        );
    }

    closeToast(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}