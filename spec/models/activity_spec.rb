require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module ActivityTestHelper
  def create_activity_assigned_to(tie)
    @tie = tie
    @activity = Factory(:activity, :_tie => tie)
  end

  def create_ability_accessed_by(tie_type)
    t = Factory(tie_type, :sender => @tie.sender)
    u = t.receiver_subject
    @ability = Ability.new(u)
  end

  def create_ability_accessed_by_receiver
    u = @tie.receiver_subject
    @ability = Ability.new(u)
  end

  def create_ability_accessed_publicly
    u = Factory(:user)
    @ability = Ability.new(u)
  end

  shared_examples_for "Allows Creating" do
    it "should allow create" do
      @ability.should be_able_to(:create, @activity)
    end
  end
  
  shared_examples_for "Allows Reading" do
    it "should allow read" do
      @ability.should be_able_to(:read, @activity)
    end
  end
  
  shared_examples_for "Allows Updating" do
    it "should allow update" do
      @ability.should be_able_to(:update, @activity)
    end
  end
  
  shared_examples_for "Allows Destroying" do
    it "should allow destroy" do
      @ability.should be_able_to(:destroy, @activity)
    end
  end

  shared_examples_for "Denies Creating" do
    it "should deny create" do
      @ability.should_not be_able_to(:create, @activity)
    end
  end
  
  shared_examples_for "Denies Reading" do
    it "should deny read" do
      @ability.should_not be_able_to(:read, @activity)
    end
  end
  
  shared_examples_for "Denies Updating" do
    it "should deny update" do
      @ability.should_not be_able_to(:update, @activity)
    end
  end
  
  shared_examples_for "Denies Destroying" do
    it "should deny destroy" do
      @ability.should_not be_able_to(:destroy, @activity)
    end
  end
  
end

describe Activity do
  include ActivityTestHelper

  describe "wall" do
    context "with a friend activity" do
      before do
        @activity = Factory(:activity)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "receiver home" do
        it "should include activity" do
          @activity.receiver.wall(:home).should include(@activity)
        end
      end

      describe "alien home" do
        it "should not include activity" do
          Factory(:user).wall(:home).should_not include(@activity)
        end
      end

      describe "sender profile" do
        context "for sender" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.sender).should include(@activity)
          end
        end

        context "for receiver" do
          it "should include activity" do
            @activity.sender.wall(:profile, :for => @activity.receiver).should include(@activity)
            @activity.sender.wall(:profile,
                                  :for => @activity.receiver,
                                  :relation => @activity.tie.relation).should include(@activity)
          end
        end
      end
    end

    context "with public activity" do
      before do
        tie = Factory(:user).public_tie
        @activity = Factory(:activity, :_tie => tie)
      end

      describe "sender home" do
        it "should include activity" do
          @activity.sender.wall(:home).should include(@activity)
        end
      end

      describe "sender profile" do
        context "accessed by alien" do
          it "should include activity" do
            @activity.sender.wall(:profile,
                                  :for => Factory(:user)).should include(@activity)
          end
        end

        context "accessed by anonymous" do
          it "should include activity" do
            @activity.sender.wall(:profile,
                                  :for => nil).should include(@activity)
          end
        end
      end
    end
  end

  describe "belonging to friend" do
    before do
      create_activity_assigned_to(Factory(:friend))
    end

    describe "accessed by sender" do
      before do
        create_ability_accessed_by_receiver
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different friend" do
      before do
        create_ability_accessed_by :friend
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by acquaintance" do
      before do
        create_ability_accessed_by :acquaintance
      end


      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed publicly" do
      before do
        create_ability_accessed_publicly
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end
  
  describe "belonging to friend self tie" do
    before do
      user = Factory(:user)
      tie = user.ties.where(:relation_id => user.relation('friend')).first
      create_activity_assigned_to(tie)
    end

    describe "accessed by the sender" do
      before do
        create_ability_accessed_by_receiver
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by a friend" do
      before do
        create_ability_accessed_by :friend
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by acquaintance" do
      before do
        create_ability_accessed_by :acquaintance
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed publicly" do
      before do
        create_ability_accessed_publicly
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end

  describe "belonging to public self tie" do

    before do
      user = Factory(:user)
      tie = user.ties.where(:relation_id => user.relation_public).first
      create_activity_assigned_to(tie)
    end

    describe "accessed by the sender" do
      before do
        create_ability_accessed_by_receiver
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by a friend" do
      before do
        create_ability_accessed_by :friend
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed by acquaintance" do
      before do
        create_ability_accessed_by :acquaintance
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed publicly" do
      before do
        create_ability_accessed_publicly
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end

  describe "belonging to public tie from a public" do

    before do
      create_activity_assigned_to(Factory(:public))
      create_ability_accessed_by_receiver
    end
    
    it_should_behave_like "Denies Creating"
  end

  describe "belonging to member tie" do
    before do
      create_activity_assigned_to(Factory(:member))
    end

    describe "accessed by same member" do
      before do
        create_ability_accessed_by_receiver
      end

      it_should_behave_like "Allows Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end
    
    describe "accessed by different member" do
      before do
        create_ability_accessed_by :member
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Allows Reading"
      it_should_behave_like "Allows Updating"
      it_should_behave_like "Allows Destroying"
    end

    describe "accessed by partner" do
      before do
        create_ability_accessed_by :partner
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end

    describe "accessed publicly" do
      before do
        create_ability_accessed_publicly
      end

      it_should_behave_like "Denies Creating"
      it_should_behave_like "Denies Reading"
      it_should_behave_like "Denies Updating"
      it_should_behave_like "Denies Destroying"
    end
  end
end
