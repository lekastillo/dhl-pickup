
```ruby

require 'dhl-pickup'

request=Dhl::Pickup::Request.new(:site_id => "MOVISADECV", :password => "a23M9jH1DC", :test_mode => true)

requestor_params = {}

requestor_params['account_number'] = '123123123123'
requestor_params['requestor_contact_person_name']='Luis Castillo'
requestor_params['requestor_contact_phone']='+5037990098'

request.set_requestor(requestor_params)
request.pickup_action_cancel!
request.confirmation_number='12312312'
request.requestor_name='Luis Castillo'
request.country_code='SV'
request.reason='002'
request.cancel_time='14:20'


```