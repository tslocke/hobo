FactoryGirl.define do
  factory :story do
    title   "Sample Story"
    body    "lorem ipsum blah blah blah"
    project
    color   "#000000"
  end

  factory :project do
    name "Sample Project"
  end

  factory :story_status do
    name "status"
  end

  factory :task do
    description "Task"
    position 1
    story
  end

end
