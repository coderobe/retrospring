# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:me) { FactoryBot.create :user }

  describe 'basic assigns' do
    before :each do
      @user = User.new(
        screen_name: 'FunnyMeme2004',
        password: 'y_u_no_secure_password?',
        email: 'nice.meme@nsa.gov'
      )
    end

    subject { @user }

    it { should respond_to(:email) }

    it '#email returns a string' do
      expect(@user.email).to match 'nice.meme@nsa.gov'
    end

    it '#motivation_header has a default value' do
      expect(@user.motivation_header).to match ''
    end

    it 'does not save an invalid screen name' do
      @user.screen_name = '$Funny-Meme-%&2004'
      expect { @user.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  # -- User::TimelineMethods --

  shared_examples_for 'result is blank' do
    it 'result is blank' do
      expect(subject).to be_blank
    end
  end

  describe '#timeline' do
    subject { me.timeline }

    context 'user answered nothing and is not following anyone' do
      include_examples 'result is blank'
    end

    context 'user answered something and is not following anyone' do
      let(:answer) { FactoryBot.create(:answer, user: me) }

      let(:expected) { [answer] }

      it 'includes the answer' do
        expect(subject).to eq(expected)
      end
    end

    context 'user answered something and follows users with answers' do
      let(:user1) { FactoryBot.create(:user) }
      let(:user2) { FactoryBot.create(:user) }
      let(:answer1) { FactoryBot.create(:answer, user: user1, created_at: 12.hours.ago) }
      let(:answer2) { FactoryBot.create(:answer, user: me, created_at: 1.day.ago) }
      let(:answer3) { FactoryBot.create(:answer, user: user2, created_at: 10.minutes.ago) }
      let(:answer4) { FactoryBot.create(:answer, user: user1, created_at: Time.now.utc) }

      let!(:expected) do
        [answer4, answer3, answer1, answer2]
      end

      before(:each) do
        me.follow(user1)
        me.follow(user2)
      end

      it 'includes all answers' do
        expect(subject).to include(answer1)
        expect(subject).to include(answer2)
        expect(subject).to include(answer3)
        expect(subject).to include(answer4)
      end

      it 'result is ordered by created_at in reverse order' do
        expect(subject).to eq(expected)
      end
    end
  end

  describe '#cursored_timeline' do
    let(:last_id) { nil }

    subject { me.cursored_timeline(last_id: last_id, size: 3) }

    context 'user answered nothing and is not following anyone' do
      include_examples 'result is blank'
    end

    context 'user answered something and is not following anyone' do
      let(:answer) { FactoryBot.create(:answer, user: me) }

      let(:expected) { [answer] }

      it 'includes the answer' do
        expect(subject).to eq(expected)
      end
    end

    context 'user answered something and follows users with answers' do
      let(:user1) { FactoryBot.create(:user) }
      let(:user2) { FactoryBot.create(:user) }
      let!(:answer1) { FactoryBot.create(:answer, user: me, created_at: 1.day.ago) }
      let!(:answer2) { FactoryBot.create(:answer, user: user1, created_at: 12.hours.ago) }
      let!(:answer3) { FactoryBot.create(:answer, user: user2, created_at: 10.minutes.ago) }
      let!(:answer4) { FactoryBot.create(:answer, user: user1, created_at: Time.now.utc) }

      before(:each) do
        me.follow(user1)
        me.follow(user2)
      end

      context 'last_id is nil' do
        let(:last_id) { nil }
        let(:expected) do
          [answer4, answer3, answer2]
        end

        it 'includes three answers' do
          expect(subject).not_to include(answer1)
          expect(subject).to include(answer2)
          expect(subject).to include(answer3)
          expect(subject).to include(answer4)
        end

        it 'result is ordered by created_at in reverse order' do
          expect(subject).to eq(expected)
        end
      end

      context 'last_id is answer2.id' do
        let(:last_id) { answer2.id }

        it 'includes answer1' do
          expect(subject).to include(answer1)
          expect(subject).not_to include(answer2)
          expect(subject).not_to include(answer3)
          expect(subject).not_to include(answer4)
        end
      end

      context 'last_id is answer1.id' do
        let(:last_id) { answer1.id }

        include_examples 'result is blank'
      end
    end
  end
end
