require 'spec/spec_helper'
require 'logger'

require "ruby_parser"

describe IVDH::Template::SexpHandler do

  include SpecHelper
  include SpecHelper::Expectations

  SexpHandler = IVDH::Template::SexpHandler

  before(:each) do
    @template = stub(Template, 
                    :full_path => "/rails_project/app/views/home/index.rhtml",
                    :path      => 'home/index.rhtml',
                    :ruby_code => '',
                    :logger    => stub(Logger))
    @sexp_handler = SexpHandler.new(@template)
    @parser = RubyParser.new
  end

  def stub_node_root(code)
    node = @parser.parse(code)
    @sexp_handler.stub!(:root_node => node)
  end


  it "#new should write to log if template's ruby code is not valid" do
    invalid_codes = ["def method_name; ",
                     "string = %{hello{world}"]
    @template.logger.should_receive(:warn).twice
    invalid_codes.each do |code|
      @template.stub!(:ruby_code => code)
      SexpHandler.new(@template)
    end
  end

  
  it "#grab_partial_template_names should grab partial template if it's only one" do
    stub_node_root("render :partial => 'body'")
    @sexp_handler.grab_partial_template_names.should == ['body']
  end
  
  it "#grab_partial_template_names should grab names of all used partial templates" do
    stub_node_root <<-RUBY_CODE
      something = 10
      render :partial => :first_template
      x = 10 + something
      render :partial => 'controller/second_template'
    RUBY_CODE

    @sexp_handler.grab_partial_template_names.should == ['first_template', 'controller/second_template']
  end

  it "#grab_partial_template_names should work correct if code has blocks" do
    stub_node_root <<-CODE
      @products.each do |product| 
        product.title 
        render :partial => 'products/item' 
      end
    CODE

    @sexp_handler.grab_partial_template_names.should == ['products/item']
  end



  it "#grab_ivar_names should grab all instance variable names which not in comments" do
    stub_node_root("@a = 10\n" +
                   "@b # it is a comment. @not_var1\n" +
                   "=begin  \n" +
                   "@not_var2\n" +
                   "=end \n" +
                   "puts @c")
    @sexp_handler.grab_ivar_names.should be_same_set_as ["@a", "@b", "@c"]
  end

  it "#grab_ivar_names should return an empty array if there no instance variables" do
    stub_node_root " puts 10;  x = 10 * 20 "
    @sexp_handler.grab_ivar_names.should == []
  end

  it "#grab_ivar_names should return only unique instance variables" do
    stub_node_root "@var = 10; x = @var + 2"
    @sexp_handler.grab_ivar_names.should == ["@var"]
  end



  it "#find_render_call_nodes should find only one render call" do
    stub_node_root "render :partial => 'body'"
    expected = Sexp.from_array(
      [:call,
       nil,
       :render,
        [:arglist,
          [:hash,
            [:lit, :partial],
            [:str, 'body']
          ]
        ]
      ]
    )
    @sexp_handler.send(:find_render_call_nodes).should == [expected]
  end

  it "#find_render_call_nodes should find all render calls" do
    stub_node_root <<-RUBY_CODE
      x = 10 + 20
      render :partial => 'controller/action'
      y = x * 2
      render :partial => 'controller/action2'
      call_method(10)
    RUBY_CODE
    expected = []
    expected << @parser.parse("render :partial => 'controller/action'")
    expected << @parser.parse("render :partial => 'controller/action2'")
    @sexp_handler.send(:find_render_call_nodes).should == expected
  end



  it "#find_nodes_by_type_recursively should return nodes with passed type" do
    code = <<-CODE
      10.times do
        meth1(1, meth2(2))
      end
    CODE
    node = @parser.parse(code)
    expected_node1 = @parser.parse("meth1(1, meth2(2))")
    expected_node2 = @parser.parse("meth2(2)")
    result = @sexp_handler.send(:find_nodes_by_type_recursively, node, :call)
    result.should include(expected_node1)
    result.should include(expected_node2)
  end

  it "#find_nodes_by_type_recursively should return root node if root node has appropriate type" do
    node = @parser.parse("meth(1,2)")
    @sexp_handler.send(:find_nodes_by_type_recursively, node, :call).should == [node]
  end


  it "#grab_arglist should return first arglist node" do
    node = Sexp.from_array([ [:arglist, [:lit, 1], [:lit, 2]], 
                              :arglist, [:lit, 10] ])
    expected = Sexp.from_array([:arglist, [:lit, 1], [:lit, 2]])
    @sexp_handler.send(:grab_arglist, node).should == expected
  end


  it "#grab_hash should return first hash node" do
    code = "{:a => 10}; {:b => 20}"
    node = @parser.parse(code)
    expected = Sexp.from_array([:hash, [:lit, :a], [:lit, 10]])
    @sexp_handler.send(:grab_hash, node).should == expected
  end


  it "#get_value_by_key_from_hash should return appropriate value if key is symbol or string" do
    hash_node = Sexp.from_array(
      [:hash,
        [:lit, :partial],
          [:lit, :some_action],
        [:str, 'two'],
          [:lit, 2]
      ]
    )
    data = {:partial => Sexp.from_array([:lit, :some_action]),
            'two'    => Sexp.from_array([:lit, 2])}
    data.each do |node_type, expected|
      @sexp_handler.send(:get_value_by_key_from_hash, hash_node, node_type).should == expected
    end
  end

  

  it "#grab_var_or_method_name should return name of local variable" do
    node = @parser.parse('loc_var')
    @sexp_handler.send(:grab_var_or_method_name, node).should == :loc_var
  end

  it "#grab_var_or_method_name should return name of instance variable" do
    node = @parser.parse('@instance_var')
    @sexp_handler.send(:grab_var_or_method_name, node).should == :@instance_var
  end

  it "#grab_var_or_method_name should return name of method" do
    node = @parser.parse('meth()')
    @sexp_handler.send(:grab_var_or_method_name, node).should == :meth
  end

end
