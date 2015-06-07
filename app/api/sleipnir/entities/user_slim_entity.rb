class Sleipnir::Entities::UserSlimEntity < Sleipnir::Entities::UserEntity
  expose :avatar do |user, options|
    user.profile_picture.url(:medium)
  end

  expose :header do |user, options|
    user.profile_header.url(:web)
  end

  unexpose :motivation_header
  unexpose :website
  unexpose :location
  unexpose :bio

  unexpose :admin
  unexpose :moderator
  unexpose :supporter
  unexpose :blogger
  unexpose :contributor

  expose :banned do |user, options|
    user.banned?
  end

  unexpose :locale

  unexpose :friend_count
  unexpose :follower_count
  unexpose :asked_count
  unexpose :answered_count
  unexpose :commented_count
  unexpose :smiled_count
  unexpose :comment_smiled_count

  unexpose :privacy_allow_anonymous_questions
  unexpose :privacy_allow_stranger_answers

  with_options(if: {type: :full}) do
    unexpose :privacy_allow_public_timeline
    unexpose :privacy_show_in_search
  end

  unexpose :created_at
end
