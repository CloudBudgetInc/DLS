import { LightningElement, api } from 'lwc';

export default class StaffTimeEntryFilter extends LightningElement {
    @api filter;
    changeRange = false;
    filterKey =  false;
    @api count;
    oldWeekFilterChange;
    oldProjectFilterChange;

    handleFilterChange(event){
        let filterChanges
        if(this.oldWeekFilterChange == undefined) {
            let filter = {'key': "selectedWeek", 'value': this.filter.selectedWeek};
            this.oldWeekFilterChange = filter;
        }

        filterChanges = {'key': event.target.name, 'value': event.detail.value};
        if(filterChanges.key == "selectedProject"){
            this.oldProjectFilterChange = filterChanges;
        } else if (filterChanges.key == "selectedWeek") {
            this.oldWeekFilterChange = filterChanges;
        }
        let oldValues = {'key':event.target.name,'oldProjectFilterChange':this.oldProjectFilterChange,'oldWeekFilterChange': this.oldWeekFilterChange}
        this.dispatchEvent(new CustomEvent('filterchange', { detail: { filterChanges, oldValues }}));
    }

}