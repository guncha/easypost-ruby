require 'spec_helper'

describe 'fedex international' do
  before(:all) do
    @rates = {}
  end

  it 'buys a ground label' do
    shipment = EasyPost::Shipment.create(
      :to_address   => ADDRESS[:canada],
      :from_address => ADDRESS[:california],
      :parcel       => PARCEL[:dimensions],
      :customs_info => CUSTOMS_INFO[:shirt]
    )
    shipment.buy(:rate => shipment.lowest_rate("fedex", "FEDEX_GROUND"))
    label = open(shipment.postage_label.label_url)

    expect(shipment).to be_an_instance_of(EasyPost::Shipment)
    expect(shipment.selected_rate).to be_an_instance_of(EasyPost::Rate)
    expect(shipment.selected_rate.service).to eq("FEDEX_GROUND")
    expect(shipment.postage_label.label_url).to end_with(".png")
    expect(shipment.tracking_code).to start_with("8000")
    expect(label.size).to be > 5000

    @rates[:ground] = shipment.selected_rate
  end

   it 'buys an air label' do
    shipment = EasyPost::Shipment.create(
      :to_address   => ADDRESS[:canada],
      :from_address => ADDRESS[:california],
      :parcel       => PARCEL[:dimensions],
      :customs_info => CUSTOMS_INFO[:shirt]
    )
    shipment.buy(:rate => shipment.lowest_rate("fedex", "INTERNATIONAL_PRIORITY"))
    label = open(shipment.postage_label.label_url)

    expect(shipment.selected_rate.service).to eq("INTERNATIONAL_PRIORITY")
    expect(shipment.tracking_code).to start_with("794")
    expect(label.size).to be > 20000

    @rates[:air] = shipment.selected_rate
  end

  it 'returns no rates for an alcohol shipment', focus: true do
    shipment = EasyPost::Shipment.create(
      :to_address   => ADDRESS[:canada],
      :from_address => ADDRESS[:california],
      :parcel       => PARCEL[:dimensions],
      :customs_info => CUSTOMS_INFO[:shirt],
      :options      => {:alcohol => true}
    )

    expect { shipment.lowest_rate("fedex") }.to raise_exception(EasyPost::Error, /No rates found/)
  end

  after(:all) do
    begin
      expect(@rates[:air].rate.to_i).to be > @rates[:ground].rate.to_i
    rescue
    end
  end

end
