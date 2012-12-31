# Ajax filtering on a partially completed form

Originally written by Bryan Larsen on 2009-08-03.

This is a neat trick I picked up reading some of Tom's code.

This is useful when you've got a form that renders differently depending on the state of some of the values in the form.   For example, when the user selects "United States" as the country, you may wish to add a "state" field, rename "Postal Code" to "Zip Code", and modify the list of shipping options in a select box.

You could use lifecycles to make this a two stage form, but this is a neat trick you can use if you want to keep it all in a single form.

Write your view normally using one of the many different options Hobo gives you.  In this example, I'm going to extend the form:

    <extend tag="form" for="Order">
      <do part="order-part">
        <old-form>
          <field-list: fields="salutation, first_name, last_name, suffix, email_address, phone_number, country, shipping_method">
            <shipping-method-view:>
              <select-one include-none="&false" options="&(this_parent.country.nil? ? [] :  ShippingMethod.find_all_by_country_id(this_parent.country.id))"/>
            </shipping-method-view:>
          </field-list:>
        </old-form>
      </do>
    </extend>

In this case, I've created an order that varies the options available in the shipping-method drop down depending on the country.  You'll also see that I've wrapped the whole form in a part.

In your controller (replace Order with your model):

    def edit
      self.this = Order.new(params[:order]) if params[:order]
      hobo_show do
        hobo_ajax_response if request.xhr?
      end
    end

    def new
      hobo_create(Order.new(params[:order])) do
        hobo_ajax_response if request.xhr?
      end
    end

In your application.js (replace order-part with your part and order\_country with your select's class):

    Event.addBehavior({
        "select.order_country:change": function(ev) {
             Hobo.ajaxRequest(window.location.href, ['order-part'], {
                 params: Form.serialize(this.up('form')),
                 method: 'get',
                 message: 'Please wait...'
             });
         }
    });

There you go: fancy custom AJAX, without really writing any AJAX code.

### How it works:

Normally, when you hit submit on a new item, it POSTs to a URL like /orders.  We've added a lowpro javascript watcher that triggers on the CSS selector "select.order\_country:change" that submits the form as a ajax request to the current location (ie, /orders/new).

In the edit controller action, instead of looking up the current value in the database, we create it from the parameters passed in.   We don't save it, though!  Then we invoke the standard hobo ajax mechanism that renders our part.   Most standard hobo actions will do this automatically for you, but the standard hobo\_show and hobo_\new do not, so we add it in ourselves.

