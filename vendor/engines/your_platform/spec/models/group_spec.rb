require 'spec_helper'

describe Group do

  # General Properties
  # ==========================================================================================

  describe "(Basic Properties)" do

    before { @group = create( :group ) }
    subject { @group }

    it { should respond_to( :name ) }
    it { should respond_to( :name= ) }
    it { should respond_to( :token ) }
    it { should respond_to( :token= ) }
    it { should respond_to( :internal_token ) }
    it { should respond_to( :internal_token= ) }
    it { should respond_to( :extensive_name ) }
    it { should respond_to( :extensive_name= ) }

    describe "#title" do
      it "should be the same as the group's name" do
        @group.name = "Group Name"
        @group.title.should == "Group Name"
      end
    end

  end


  # Associated Objects
  # ==========================================================================================

  # Workflows
  # ------------------------------------------------------------------------------------------

  describe "(Workflows)" do
    before do
      @group = create( :group )
      @subgroup = create( :group )
      @subgroup.parent_groups << @group
      
      @workflow = create( :workflow )
      @workflow.parent_groups << @group
      @subworkflow = create( :workflow )
      @subworkflow.parent_groups << @subgroup

      @group.reload
      @workflow.reload
    end
    subject { @group }

    describe "#descendant_workflows" do
      it "should return the workflows of the group and its subgroups" do
        @group.descendant_workflows.should include( @workflow, @subworkflow )
        @workflow.ancestor_groups.should include( @group )
      end
    end

    describe "#child_workflows" do
      it "should return only the workflows of the groups, not of the subgroups" do
        @group.child_workflows.should include( @workflow )
        @group.child_workflows.should_not include( @subworkflow )
        @workflow.ancestor_groups.should include( @group )
        @subworkflow.ancestor_groups.should include( @group, @subgroup )
      end
    end
  end


  # Users
  # ------------------------------------------------------------------------------------------

  describe "(Users)" do

    before do
      @user = create( :user )
      @group = create( :group )
      @subgroup = create( :group ); @group.child_groups << @subgroup
      @everyone_group = Group.find_everyone_group
    end

    describe "#descendant_users" do
      describe "for usual groups" do
        before { @user.parent_groups << @subgroup }
        subject { @group.descendant_users }

        it "should return all descendant users, including the users of the subgroups" do
          subject.should include( @user )
        end
      end
      describe "for the everyone group" do
        subject { @everyone_group.descendant_users }
        
        it "should return all users, even those not explicitely added as dag descendants" do
          subject.should include( @user )
        end
      end
    end

    describe "#child_users" do
      describe "for usual groups" do
        before { @user.parent_groups << @group }
        subject { @group.child_users }

        it "should return all child users" do
          subject.should include( @user )
        end
      end
      describe "for the everyone group" do
        subject { @everyone_group.child_users }
        
        it "should return all users, even though not explicitely added as dag children" do
          subject.should include( @user )
        end
      end
    end

    describe "#assign_user" do
      it "should assign the user to the group" do
        @group.child_users.should_not include( @user )
        @group.assign_user( @user )
        @group.reload
        @group.child_users.should include( @user )
      end
      describe "for users that are already members" do
        before { @group.child_users << @user }
        it "should just keep them as members" do
          @group.child_users.should include( @user )
          @group.assign_user( @user )
          @group.reload
          @group.child_users.should include( @user )
        end
      end
    end

    describe "#unassign_user" do
      describe "if the user is a member" do
        before { @group.child_users << @user }
        it "should remove the membership" do
          @group.child_users.should include( @user )
          @group.unassign_user( @user )
          @group.reload
          @group.child_users.should_not include( @user )
        end
      end
      describe "if the user is not a member" do
        it "should raise an error" do
          @group.child_users.should_not include( @user )
          expect { @group.unassign_user( @user ) }.to raise_error
        end
      end
    end

  end


  # Groups
  # ------------------------------------------------------------------------------------------

  describe "(Groups)" do
    describe "#descendant_groups_by_name" do
      before do
        @name_match = "Group Name"
        @group = create( :group )
        @group1 = create( :group, :name => @name_match ); @group1.parent_groups << @group
        @group2 = create( :group, :name => "Other #{@name_match}" ); @group2.parent_groups << @group1        
        @group3 = create( :group, :name => @name_match ); @group3.parent_groups << @group2
        @matching_groups = [ @group1, @group3 ]
        @not_matching_groups = [ @group2 ]
      end
      subject { @group.descendant_groups_by_name( @name_match ) }
      it "should return all descendant groups matching the name" do
        @matching_groups.each { |g| subject.should include( g ) }
        @not_matching_groups.each { |g| subject.should_not include( g ) }
      end
    end
  end


  # User Group Memberships
  # ------------------------------------------------------------------------------------------
  
  describe "(User Group Memberships)" do

    before do
      @group = create( :group )
      @user1 = create( :user ); @group.assign_user( @user1 )
      @user2 = create( :user ); @group.assign_user( @user2 )
      @membership1 = UserGroupMembership.find_by( user: @user1, group: @group )
      @membership2 = UserGroupMembership.find_by( user: @user2, group: @group )
    end

    describe "#memberships" do
      subject { @group.memberships }
      it { should include( @membership1, @membership2 ) }
    end

    describe "#membership_of" do
      subject { @group.membership_of( @user1 ) }
      it { should == @membership1 }
    end

    describe "#direct_member_titles_string" do
      subject { @group.direct_member_titles_string }
      it { should == "#{@user1.title}, #{@user2.title}" }
    end

    describe "#direct_member_titles_string=" do
      before { @group.direct_member_titles_string = "#{@user1.title}" }
      it "should set the memberships according to the titles" do
        @group.memberships.should include( @membership1 )
        @group.memberships.should_not include( @membership2 )
      end
    end

  end


end