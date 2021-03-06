require 'spec_helper'

feature "Search Field", js: true do
  include SessionSteps

  before do
    user = create( :user_with_account )
    login user

    visit root_path
  end

  describe "finding users" do
    context "if there is only one matching user" do
      before do
        @user1 = create( :user, last_name: "foo" )
        fill_in 'query', with: "foo"
        
        press_enter in: 'query'
      end
      specify "searching for foo should redirect to the user page" do
        page.should have_content( @user1.title )
        page.should have_content( I18n.t( :name ) )
        page.should have_content( I18n.t( :contact_information ) )
      end
    end
    context "if there are more users matching" do
      before do
        @user1 = create( :user, last_name: "foo" )
        @user2 = create( :user, last_name: "foobar" )
        fill_in 'query', with: "foo"
        press_enter in: 'query'
      end
      specify "searching for foo should list both users" do
        page.should have_content( I18n.t( :found_users ) )
        page.should have_content( "#{@user1.last_name}, #{@user1.first_name}" )
        page.should have_content( "#{@user1.last_name}, #{@user1.first_name}" )
      end
    end
    context "if there are more users matching" do
      before do
        @user1 = create( :user, last_name: "foo" )
        @user2 = create( :user, last_name: "blarzfoo" )
        @user3 = create( :user, last_name: "cannonfoo" )
        @user3.profile_fields.create( label: "Home Address", value: "Pariser Platz 1\n 10117 Berlin", type: "ProfileFieldTypes::Address" )
        @user3.profile_fields.create( label: "General Info", value: "Foo Bar", type: "ProfileFieldTypes::General")

        fill_in 'query', with: "foo"
        press_enter in: 'query'
      end
      specify "searching for foo should list each user only once" do
        page.should have_content( I18n.t( :found_users ) )
        page.should have_content( @user1.last_name )
        page.should have_content( @user2.last_name )
        page.should have_content( @user3.last_name )
        u1 = find('div.users_found').all(:css, 'a', :text => @user1.last_name)
        u2 = find('div.users_found').all(:css, 'a', :text => @user2.last_name)
        u3 = find('div.users_found').all(:css, 'a', :text => @user3.last_name)
        u1.size.should == 1
        u2.size.should == 1
        u3.size.should == 1
      end
    end
  end

  describe "finding pages" do
    before do
      @page = create( :page, title: "foo" )
      fill_in 'query', with: "foo"
      press_enter in: 'query'
    end
    subject { page }
    it { should have_content( @page.title ) }
  end

  describe "finding groups" do
    before do
      @group = create( :group, name: "foo" )
      fill_in 'query', with: "foo"
      press_enter in: 'query'
    end
    subject { page }
    it { should have_content( @group.title ) }
  end

  describe "a space should be interpreted as a wild card" do
    before do
      @page = create( :page, title: "foo some bar page" )
      fill_in 'query', with: "foo bar"
      press_enter in: 'query'
    end
    subject { page }
    it { should have_content( @page.title ) }
  end

end


