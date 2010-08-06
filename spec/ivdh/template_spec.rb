require 'spec/spec_helper'


describe IVDH::Template do

  include SpecHelper::Expectations
  include SpecHelper

  Template = IVDH::Template
  TemplateCollection = IVDH::TemplateCollection

  before(:each) do
    path = File.join(SpecHelper::FIXTURES_DIR, "home", "index.rhtml")
    collection = stub(TemplateCollection, :views_dir => SpecHelper::FIXTURES_DIR)
    @template = Template.new(path, collection)
  end
  
  it "#grab_ruby_code should return ruby code of template" do
    tpl = <<-TPL
            <h2><%= @product.title %><h2>
            <% if @product.desc %>
              <p><%= @product.desc %></p>
            <% end %>
          TPL
    File.should_receive(:read).with(@template.full_path).and_return(tpl)
    expected = " @product.title \n" +
               " if @product.desc \n" +
               " @product.desc \n" +
               " end "
    @template.send(:grab_ruby_code).should == expected
  end
  
  it "#define_subtemplates should init @subtemplates using collection#get_subtemplate" do
    @template.partials.should_not be_empty
    @template.partials.each do |partial|
      @template.collection.should_receive(:get_subtemplate).with(@template, partial).and_return(partial)
    end
    @template.define_subtemplates
    @template.subtemplates.should be_same_set_as @template.partials
  end

end
