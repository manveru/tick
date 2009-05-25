require 'spec/helper'

describe Tick::Ticket do
  behaves_like :tick

  it 'creates some tickets' do
    milestone = tick.create_milestone(:name => '1.0')

    ticket0 = milestone.create_ticket(:name => 'one', :author => 'manveru')
    ticket1 = milestone.create_ticket(:name => 'two', :author => 'manveru')
    ticket2 = milestone.create_ticket(:name => 'three', :author => 'manveru')

    tickets = milestone.tickets
    tickets.uniq.size.should == 3
    tickets.map{|ticket| ticket.name }.sort.
      should == [ticket0, ticket1, ticket2].map{|ticket| ticket.name }.sort
  end
end
