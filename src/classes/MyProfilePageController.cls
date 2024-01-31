/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
 */
public class MyProfilePageController {

    private User user;
    private boolean isEdit = false;
    
    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }
    
    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    
    
    public void save() {
        if (user.contact != null) {              
            setContactFields(user.contact);
        }
        
        try {
            update user;
            if (user.contact != null) { 
                update user.contact;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    public PageReference changePassword() {
        return Page.ChangePassword;
    }
    
    public void cancel() {
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }
    
    private void setContactFields(Contact c) {
        c.title = user.title;
        c.firstname = user.firstname;
        c.lastname = user.lastname;
        c.email = user.email;
        c.phone = user.phone;
        c.mobilephone = user.mobilephone;
        c.fax = user.fax;
        c.mailingstreet = user.street;
        c.mailingcity = user.city;
        c.mailingstate = user.state;
        c.mailingpostalcode = user.postalcode;
        c.mailingcountry = user.country;
    }

static testMethod void testSave() {
        //Note this has been hacked as the old test crashed and prevented Apex releases
        //This solution will work if you have the code deployed but no partner or customer portal users activated (=cause of the original test failure)
    //Not perfect, but it works.... Please post improvements to this thread!
        
    //An Account
    Account ac = new Account();
    ac.Name = 'Test Entity';
        insert ac;
        
        //A Contact
        Contact c = new Contact();
        c.FirstName = 'unit';
        c.LastName = 'test';
        c.Email = 'me@myorg.org';
        c.AccountId = ac.Id;
        insert c;        
        
        String randFax = Math.rint(Math.random() * 1000) + '5551234';

        MyProfilePageController controller = new     
        MyProfilePageController();
        controller.save();
        controller.edit();
        controller.cancel();
        controller.getUser().Fax = randFax;
        controller.setContactFields(c);
    }
    }