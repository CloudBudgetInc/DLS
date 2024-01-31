/* Global */
body {
	font-size: 0.875rem;
	color: #37474F;
	font-family: "Lato",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
}
/* Tables */
.table th {
	border-top: none;
}
.table-bordered thead  {
	color: #055E89;
}
.table td  a:hover {
  text-decoration: underline !important;
}
.table-bordered thead th {
	font-weight: 400;
	text-transform: uppercase;
}
.table-bordered thead th:not(:last-child) {
	border-right: 1px solid #979797;
}
.table-bordered tbody td {
	border-color: #DDDDDD;
}
.table .thead-light th {
	color: #055E89;
	background-color: rgba(5,94,137,0.1);
	border: 1px solid #055E89 !important;
    font-size: 1rem;
}
/*Table Bordered*/
.table-bordered tbody td:not(:last-child) {
	border-right: 1px solid #979797;
}
/*Table Striped*/
.table-striped tbody tr:nth-of-type(odd) {
    background-color: transparent;
}
.table-striped tbody tr:nth-of-type(even) {
    background-color: #F9F9F9;
}

/* Tabs section */
.nav-tabs {
	width: fit-content;
}

/* Ratings */
.fa-star,
.fa-heart {
	color: #D8D8D8;
}

.star {
	color: #FFEB73;
}

.heart {
	color: #F86262;
}

/* Card Title Underline */

.card-title:after {
	content: '';
	display: block;
	margin-top: 10px;
	width: 60px;
	height: 3px;
	background: #055E89;
}

/* Card box shadow */

.card {
	box-shadow: 0 2px 4px 0 rgba(193,193,193,0.5);
}

/* Vertical Tabs Section */

.vertical-tabs {
	border: 1px solid #DDDDDD;
}

.vertical-tabs .nav-tabs {
	border-right: 1px solid #DDDDDD;
	background: #f8f8f8;
}

/*Custom CSS*/
/*Custom CSS for Card Mobile View */
@media (max-width: 48em) {

.responsive-card-table thead tr {
	position: absolute;
	top: -9999em;
	left: -9999em;
}

.responsive-card-table tr {
	display: block;
	border-top: 2px solid #dddbda;
}

 .responsive-card-table th {
	display: block;
	max-width: 100%;
	width: 100%;
	clear: both;
	white-space: normal;
	text-align: left;
	padding: 0.75rem;
	overflow: hidden;
}
   .responsive-card-table td{
	display: block;
	max-width: 100%;
	width: 100%;
	clear: both;
	white-space: normal;
	overflow: hidden;
	text-align: right;
}

.responsible-card-table thead {
	position: absolute !important;
	width: 1px !important;
	height: 1px !important;
	clip: rect(0px, 0px, 0px, 0px) !important;
	margin: -1px !important;
	border-width: 0px !important;
	border-style: initial !important;
	border-color: initial !important;
	border-image: initial !important;
	padding: 0px !important;
	overflow: hidden !important;
	
}

  .responsive-card-table td:before {
	float: left;
	margin-top: 0.125rem;
	font-size: 0.875rem;
	line-height: 1.25;
	color: rgb(105, 105, 105);
	text-transform: uppercase;
	letter-spacing: 0.0625rem;
	display: block;
	padding-bottom: 0.25rem;
	content: attr(data-label);
}
.responsive-card-table tr > td:last-child {
	padding: 0.75rem;
}
.responsive-card-table tr > td:first-child {
	padding: 0.75rem;
}
}
/*Custom CSS for ldt Table to override boostrap style*/
.ldtTableCls table{
    font-size:0.875rem !important;
}
.ldtTableCls table th {
    border-top: none !important;
    padding: 0.40rem !important;
    vertical-align: top !important;
}
.ldtTableCls thead  {
    color: #055E89 !important;
}
.ldtTableCls thead th {
    text-transform: uppercase !important;
    color: #055E89  !important;
    font-size:1rem !important;
    background-color: rgba(5,94,137,0.1)  !important;
    border: 1px solid #055E89  !important;
}
.ldtTableCls thead th:not(:last-child) {
    border-right: 1px solid #979797 !important;
}
.ldtTableCls td {
    border-color: #DDDDDD !important;
    padding: 0.75rem !important;
    vertical-align: top !important;
    border: 1px solid #dee2e6 !important;
}

/*Table Bordered*/
.ldtTableCls tbody td:not(:last-child) {
    border-right: 1px solid #979797 !important;
}
/*Table Striped*/
.ldtTableCls tbody tr:nth-of-type(odd) {
    background-color: transparent !important;
}
.ldtTableCls  tbody tr:nth-of-type(even) {
    background-color: #F9F9F9 !important;
}
 .ldtTableCls .slds-th__action:hover {
    background-color: #e6eff3 !important;
}
 .ldtTableCls .slds-th__action:focus {
    background-color: #e6eff3 !important;
}

.ldtTableCls  .slds-is-sortable{
    background-color: #e6eff3 !important;
}

.ldtTableCls .ldtdev .slds-card {
    border:white !important;
    box-shadow: 0 2px 2px 0 rgba(0,0,0,0)!important;
}
.ldtTableCls .slds-card {
    border:white !important;
    box-shadow: 0 2px 2px 0 rgba(0,0,0,0)!important;
}
.ldtTableCls td a {
    color: #055e89 !important;
    text-decoration: none !important;
}
.ldtTableCls table td a:hover {
    text-decoration: underline !important;
}
.ldtdev .slds-button_brand {
    border: 1px solid transparent !important;
    padding: 0.75rem 1.5rem !important;
    color: #fff !important;
    border-radius: 0 !important;
    line-height: 1 !important;
    font-size:0.875!important;
    background-color: #055e89 !important;
    
}
.ldtdev .slds-select[size] {
    min-height: calc(2.875rem + (1px * 2)) !important;
	 border-radius:0rem !important;
}

.ldtdev .slds-button_brand:hover {
    color:  #055e89 !important;
    background-color: #fff !important;
    border-color:#055e89 !important;
}
.ldtdev .slds-button[disabled] {
    background-color: #dddbda !important;
    color:  #fff !important;
    border-color:#dddbda !important;
}
/*Custom CSS for Lightning Select to override boostrap Select style*/
.slds-form-element__label {
    color: black!important;
    font-size: .875rem!important;
}
.slds-select{
    display: inline-block ;
    width: 100%;
    height: calc(1.25em + 1.5rem + 2px);
    font-size: 0.875rem;
    font-weight: 400;
    line-height: 1.5;
    color: #495057;
    vertical-align: middle;
    border: 1px solid #ced4da;
    border-radius: 0;
    appearance: none;
    transition: background-color 0.15s ease-in-out, border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
    -webkit-appearance: none;
}
select {
    
    text-transform: none !important;
    margin: 0 !important;
    font-family: inherit !important;
}

.slds-select_container::after{
    display : none !important;
}
.slds-select_container::before{
    display : none !important;
}
.slds-select_container .slds-select { -webkit-appearance : menuList}
 input[type=text]{
    display: block;
    width: 100%;
    padding: 0.70rem 0.75rem;
    font-size: 0.875rem;
    font-weight: 400;
    line-height: 1.5;
    color: #495057;
    background-clip: padding-box;
    border: 1px solid #ced4da;
    border-radius: 0;
    transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
   
}

input[type="search"] {
    height: 45px;
}
/*Custom CSS for wrap the text in table*/

.wrap {
    white-space:normal !important;
    word-break: break-word;
}
.btn {
    padding: 0.50rem 1.5rem !important;
}