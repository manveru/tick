require 'spec/helper'

describe Tick::Ticket do
  behaves_like :tick

  it 'creates a ticket' do
    milestone = tick.create_milestone(name: 'creating first ticket')

    milestone.create_ticket(name: 'first ticket', author: 'manveru')

    tickets = milestone.tickets
    tickets.size.should == 1
    ticket = tickets.first
    ticket.name.should == 'first ticket'
    ticket.author.should == 'manveru'
  end

  it 'creates some tickets' do
    milestone = tick.create_milestone(name: 'creating tickets')

    ticket0 = milestone.create_ticket(name: 'one',   author: 'manveru')
    ticket1 = milestone.create_ticket(name: 'two',   author: 'manveru')
    ticket2 = milestone.create_ticket(name: 'three', author: 'manveru')

    tickets = milestone.tickets
    tickets.uniq.size.should == 3
    tickets.map(&:name).sort.
      should == [ticket0, ticket1, ticket2].map(&:name).sort
  end

  it 'modifies a ticket' do
    milestone = tick.create_milestone(name: 'modifying tickets')

    ticket = milestone.create_ticket(name: 'one', author: 'manveru')
    created_at = ticket.created_at
    updated_at = ticket.updated_at

    ticket.update(author: 'mika')
    ticket.author.should == 'mika'
    ticket.created_at.should == created_at
    ticket.updated_at.should != updated_at
  end

  it 'updates a ticket without duplicating it' do
    milestone = tick.create_milestone(name: 'keep identity after update')
    ticket0 = milestone.create_ticket(name: 'ticket', status: 'open')

    ticket0.update(name: 'ticket', status: 'resolved')

    tickets = milestone.tickets
    tickets.size.should == 1
    ticket1 = tickets.first

    ticket1.path.to_s.should == ticket0.path.to_s
    ticket1.status.should == ticket0.status.should
  end

  it 'flags a ticket as resolved' do
    milestone = tick.create_milestone(name: 'resolving tickets')

    ticket0 = milestone.create_ticket(name: 'problem', status: 'open')
    ticket0.status.should == 'open'
    ticket0.update(status: 'resolved').should != false
    ticket0.status.should == 'resolved'
  end

  it 'flags a ticket as invalid' do
    milestone = tick.create_milestone(name: 'invalid tickets')

    ticket0 = milestone.create_ticket(name: 'problem', status: 'open')
    ticket0.status.should == 'open'
    ticket0.update(status: 'invalid').should != false
    ticket0.status.should == 'invalid'
  end

  it 'flags a ticket as on hold' do
    milestone = tick.create_milestone(name: 'tickets on hold')

    ticket0 = milestone.create_ticket(name: 'problem', status: 'open')
    ticket0.status.should == 'open'
    ticket0.update(status: 'hold').should != false
    ticket0.status.should == 'hold'
  end

  it 'flags a ticket as open' do
    milestone = tick.create_milestone(name: 'tickets on hold')

    ticket0 = milestone.create_ticket(name: 'problem', status: 'resolved')
    ticket0.status.should == 'resolved'
    ticket0.update(status: 'open').should != false
    ticket0.status.should == 'open'
  end

  it 'select tickets by status' do
    milestone = tick.create_milestone(name: 'selecting tickets by status')

    milestone.create_ticket(name: '1', status: 'open')
    milestone.create_ticket(name: '2', status: 'open')

    milestone.create_ticket(name: '3', status: 'resolved')
    milestone.create_ticket(name: '4', status: 'resolved')

    milestone.create_ticket(name: '5', status: 'hold')
    milestone.create_ticket(name: '6', status: 'hold')

    milestone.create_ticket(name: '7', status: 'invalid')
    milestone.create_ticket(name: '8', status: 'invalid')

    open = milestone.select(status: 'open')
    open.size.should == 2
    open.map(&:name).should == %w[1 2]

    resolved = milestone.select(status: 'resolved')
    resolved.size.should == 2
    resolved.map(&:name).should == %w[3 4]

    hold = milestone.select(status: 'hold')
    hold.size.should == 2
    hold.map(&:name).should == %w[5 6]

    invalid = milestone.select(status: 'invalid')
    invalid.size.should == 2
    invalid.map(&:name).should == %w[7 8]
  end

  it 'adds tags to tickets' do
    milestone = tick.create_milestone(name: 'tagging')

    ticket0 = milestone.create_ticket(name: 'tagged', tags: %w[one])
    ticket1 = milestone.create_ticket(name: 'tagged', tags: %w[one two])
    ticket2 = milestone.create_ticket(name: 'tagged', tags: %w[one two three])

    ticket0.tags.should == %w[one]
    ticket1.tags.should == %w[one two]
    ticket2.tags.should == %w[one two three]
  end

  it 'select tickets by tags' do
    milestone = tick.create_milestone(name: 'select tickets by tags')

    milestone.create_ticket(name: '1', tags: %w[one])
    milestone.create_ticket(name: '2', tags: %w[one two])
    milestone.create_ticket(name: '3', tags: %w[one two three])

    one = milestone.select{|ticket| ticket.tags.include?('one') }
    one.size.should == 3
    one.map(&:name).should == %w[1 2 3]

    two = milestone.select{|ticket| ticket.tags.include?('two') }
    two.size.should == 2
    two.map(&:name).should == %w[2 3]

    three = milestone.select{|ticket| ticket.tags.include?('three') }
    three.size.should == 1
    three.map(&:name).should == %w[3]
  end

  it 'can be commented on' do
    milestone = tick.create_milestone(name: 'have a comment')

    ticket = milestone.create_ticket(name: 'need comments')
    ticket.create_comment(content: 'nothing important', author: 'manveru')

    comments = ticket.comments
    comments.size.should == 1
    comment = comments.first
    comment.content.should == 'nothing important'
    comment.author.should == 'manveru'
  end

  it 'can have multiple comments' do
    milestone = tick.create_milestone(name: 'have comments')

    ticket = milestone.create_ticket(name: 'need comments')

    ticket.create_comment(content: '1', author: 'manveru')
    ticket.create_comment(content: '2', author: 'manveru')
    ticket.create_comment(content: '3', author: 'manveru')

    comments = ticket.comments
    comments.size.should == 3
  end

  it 'can have an attachment' do
    milestone = tick.create_milestone(name: 'have an attachment')

    ticket = milestone.create_ticket(name: 'needs attachments')
    ticket.create_attachment(content: 'nothing important', author: 'manveru')

    attachments = ticket.attachments
    attachments.size.should == 1
    attachment = attachments.first
    attachment.content.should == 'nothing important'
    attachment.author.should == 'manveru'
  end

  it 'has an identity that depends on the content' do
    milestone = tick.create_milestone(name: 'shared identity')
    ticket0 = milestone.create_ticket(name: 'ticket 0')
    ticket1 = milestone.create_ticket(name: 'ticket 0')
    ticket0.path.should == ticket1.path
    sleep 1 # make sure the time has no influence on the checksum
    ticket2 = milestone.create_ticket(name: 'ticket 0')
    ticket2.path.should == ticket1.path
  end

  it 'can have everything at once' do
    milestone = tick.create_milestone(name: 'milestone')
    ticket0 = milestone.create_ticket(name: 'ticket 0')
    comment01 = ticket0.create_comment(content: 'comment 01')
    comment02 = ticket0.create_comment(content: 'comment 02')
    attachment01 = ticket0.create_attachment(content: 'attachment 01')
    attachment02 = ticket0.create_attachment(content: 'attachment 02')

    ticket1 = milestone.create_ticket(name: 'ticket 1')
    comment11 = ticket1.create_comment(content: 'comment 11')
    comment12 = ticket1.create_comment(content: 'comment 12')
    attachment11 = ticket1.create_attachment(content: 'attachment 11')
    attachment12 = ticket1.create_attachment(content: 'attachment 12')

    milestone.tickets.size.should == 2

    milestone.tickets.each do |ticket|
      ticket.comments.size.should == 2
      ticket.attachments.size.should == 2
    end
  end

  it 'has a description' do
    milestone = tick.create_milestone(name: 'descriptions')
    ticket = milestone.create_ticket(name: 'ticket', description: 'yay')
    ticket.description.should == 'yay'
  end
end
