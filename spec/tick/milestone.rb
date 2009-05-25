require 'spec/helper'

describe Milestone = Tick::Milestone do
  behaves_like :tick

  it 'should sort correctly' do
    future = Milestone.new(nil, :name => 'future')
    one_oh = Milestone.new(nil, :name => '1.0')
    two_oh = Milestone.new(nil, :name => '2.0')

    [one_oh, future, two_oh].sort.should == [one_oh, two_oh, future]
  end

  it 'creates some milestones' do
    one_oh = Milestone.create(tick, :name => '1.0')
    two_oh = Milestone.create(tick, :name => '2.0')

    tick.milestones.should == [one_oh, two_oh]
  end
end
