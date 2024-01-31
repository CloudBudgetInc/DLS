import { LightningElement  , api} from 'lwc';

export default class IconWithNotificationCmp extends LightningElement {

    @api iconName;
    @api pendingCount;
    @api iconSize;
    @api iconVariant;
    @api alternativeText;
    @api recordId;

    cssClass;

    @api
    get iconClass() { 
        console.log(this.cssClass);
        return this.cssClass;
    }
    set iconClass(value) {
        this.setAttribute('cssClass', value);
        this.cssClass = value;
      }
      handleIconClick(){
        this.dispatchEvent(new CustomEvent('btnclick',{detail : 
          {
            whatId : this.recordId
          },
      }));
      }
      get isSingleDigit(){
        if(this.pendingCount < 9 && this.pendingCount > 0){
          return true;
        }
      }
      get isTwoDigit(){
        if(this.pendingCount > 9){
          return true;
        }
      }
}