
```ruby

require 'dhl-pickup'

request=Dhl::Pickup::Request.new(:site_id => "MOVISADECV", :password => "a23M9jH1DC", :test_mode => true)

requestor_params = {}

requestor_params[:account_number] = '958341468'
requestor_params[:requestor_contact_person_name]='Luis Castillo'
requestor_params[:requestor_contact_phone]='+5037990098'

requestor_params[:country_code]='SV'
requestor_params[:city]='San Salvador'
requestor_params[:address1]='Col San Benito, # 411 Av La Capilla'

request.set_requestor(requestor_params)

place_params = {}

place_params[:location_type] = 'B'
place_params[:company_name]='HOME COMPANY'
place_params[:address1]=requestor_params[:address1]
place_params[:package_location]='En recepcion'
place_params[:country_code]='SV'
place_params[:city]='San Salvador'
place_params[:suburb]='San Salvador'


request.set_place(place_params)

pickup_params = {}

pickup_params[:pickup_date] = '2019-08-12'
pickup_params[:pickup_type_code] = 'A'
pickup_params[:ready_by_time] = '09:00'
pickup_params[:close_time] = '17:00'
pickup_params[:after_hours_closing_time] = '21:00'
pickup_params[:after_hours_location] = 'Porton principal'
pickup_params[:pieces] = '1'
pickup_params[:weight] = '1'
pickup_params[:weight_unit] = 'K'
pickup_params[:special_instructions] = 'Preguntar por Roxy en recepcion'
pickup_params[:remarks] = 'El paquete contiene un utencilio fragil'



request.set_pickup(pickup_params)

pickup_contact_params = {}

pickup_contact_params[:pickup_contact_person_name] = 'Luis Castillo'
pickup_contact_params[:pickup_contact_phone] = '50379900988'
request.set_pickup_contact(pickup_contact_params)


request.to_xml

response = request.post

request.pickup_action_cancel!
request.confirmation_number='12312312'
request.requestor_name='Luis Castillo'
request.country_code='SV'
request.reason='002'
request.cancel_time='14:20'


```