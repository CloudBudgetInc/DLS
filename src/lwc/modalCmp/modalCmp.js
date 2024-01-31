import { LightningElement, api } from "lwc";

export default class ModalCmp extends LightningElement {
  @api show = false;
  @api showHeader = false;
  @api showFooter = false;
  @api header;
  @api showCloseButton = false;

  togglemodal() {
    this.show = !this.show;
  }
}