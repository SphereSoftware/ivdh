require 'spec/spec_helper'

describe IVDH::TemplateCollection do

  include SpecHelper::Expectations

  before(:each) do
    @collection = TemplateCollection.new(SpecHelper::FIXTURES_DIR)
  end

  it "#find_parents_for should return parent templates of passed template" do
    tpl = @collection.find{|tpl| tpl.path =~ %r{products/_item} }
    got =  @collection.find_parents_for(tpl).map(&:path)
    expected = ['products/index.html.erb', 'home/index.rhtml']
    got.should be_same_set_as expected
  end

  it "#get_subtemplate should find and return a subtemplate by partial name and parent template" do
    index_tpl = @collection.find{|tpl| tpl.path =~ %r{home/index} }
    partials = {'head' => 'home/_head.rhtml',
                'products/item' => 'products/_item.rhtml'}
    partials.each do |partial_name, partial_path|
      subtpl = @collection.get_subtemplate(index_tpl, partial_name)
      subtpl.should be_an_instance_of IVDH::Template
      subtpl.path.should == partial_path
    end
  end

end

