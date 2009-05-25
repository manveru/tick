# Tick

Tick is a distributed ticket tracking system hosted inside a Git repo.

* The source can be found at [GitHub](http://github.com/manveru/tick)
* Documentation will be hosted at [Rubyists](http://doc.rubyists.com/tick)


## Overview

Distributed ticket tracking is still a very experimental field with little
common practice.

Tick tries to tackle the problem in a simple manner, that is distinct from the
well-known ditz and ticgit ticket trackers or the way fossil handles it.

The approach tries to take the best properties of the current solutions and
distill them to something much easier to approach.
Two properties that have high priority is portability and fidelity of ticket
data and speed.
Given that this tries to be a git-based ticket-tracker, we will take advantage
of using a separate branch, but will do so in a manner that makes concurrent
access possible.
All of these features will have more impact on disk space than on memory usage,
and I think this is a reasonable trade-off as most ticket trackers have a low
amount of data but need to work as fast as possible.
It is also important that graphical, CLI, or web-frontends do not lock the
repository they operate on, but rather operate atomically while ensuring
integrity.

The source of Tick is intended to be very readable and easy to extend to
accommodate people who would like to create additional functionality.

I do not intend to add any plugin facilities yet, but eventually some core
aspects of Tick might become plugins (like comments or attachments) to blaze
the trail for future additions.


## Integration

I will try to provide integration with other ticket systems by working on
synchronization features, this area will need most contribution as I do not
know every ticket tracker under the sun.

Tick works very well in bare git repos, which makes it small, fast, and
efficient in an hosting-environment as well.


## Dependencies

* Ruby greater or equal to 1.9.1
* GitStore can be found at: [GitHub](http://github.com/georgi/git_store)

In future I might make the source compatible with 1.8.x, but that's rather low
priority for now.


## Todo

There are several areas where Tick still needs improvement, first of all we
should track down the most obvious performance issues, as I haven't done
profiling yet.

Plans for the future frontends are:

* CLI
* Shoes and Curses GUI
* Ramaze or Innate web application
* Static website generation to serve snapshots

Various things that need to be done:

* More specs
* YARD docs
* Tutorial
* Instructions for distributed usage
* Porting to Ruby 1.8.6


## Storage

Every `object` in Tick is stored as a directory containing its properties. So
every Tick repository is structured as a tree.

An example might look like following, the type in parenthesis.

    project/tick (repo/branch)
      Milestone-9ab2beb1b0fd505da3a5f2937952a21ab3e1124a (Milestone tree)
        tickets (tree)
          Ticket-aba3fa7a3d641acc937a3c4724b7094f56309c00 (Ticket tree)
            comments (tree)
              Comment-78d3210fe31a80d6f18ac157496f76378f13b3aa (Comment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)
              Comment-63e244b02a26e441c41fdc49cf4dbb1cc41b9e92 (Comment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)
            attachments (tree)
              Attachment-ee40e7bad30ff04b9dc1b97a316ed52116c83520 (Attachment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)
              Attachment-255884ff1585af21cbc6536bd11c55000b62e550 (Attachment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)
          Ticket-ed1f26bb991b72ccc762eeea3482fd9015aa08d8 (Ticket tree)
            comments (tree)
              Comment-d32676cf6dc77713bf3eb7dea83072625f9cd15b (Comment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)
              Comment-2e805f08f62546de0d607e803b29066815ba0aa2 (Comment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)
            attachments (tree)
              Attachment-51443bd9e9931bd7ec67e50974137a5dc7960c0d (Attachment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)
              Attachment-3136124ff5f50311bc21402d92f4b30c84466a68 (Attachment tree)
                created_at (time property)
                updated_at (time property)
                author (string property)
                content (string property)


As you can see, at the root of the repository are multiple directories
representing milestones, which contains property-files and a tickets-directory.

All directories are named by hashing the initial contents, this ensures that
distributed creation of identical objects can be merged without problems.

Every property of objects is stored in a separate files to further minimize
merging conflicts, in future we will also have an automatic merging strategy
that will take care of the most common conflicts like changing ticket status or
identical tickets moving between milestones.

Every property is stored as JSON to give fast and easy interoperability between
programming languages and to keep data fidelity high. We do not use YAML since
that is comparatively slow and provides too many types and features that we
don't need.

You might have noticed that the tree is not meant to be edited by hand, but is
fully tuned to fast and precise machine modification that avoids the impact of
parsing a representation that would be more human-readable.
Of course it is still possible to edit properties manually, but this should be
done with great care and avoided if possible.

### GitStore Objects

Our so-called GitStore-objects are the foundation of Tick, they abstract the
direct interaction with Git to a minimum and let you concentrate on the real
issue at hand.



### Milestone

A milestone has following properties:

* Name
* Author
* Time of creation
* Time of update
* Status (open, closed)
* Description

### Ticket

Every ticket belongs to one milestone.

A Ticket has following properties:

* Name
* Author
* Time of creation
* Time of update
* Status (open, resolved, hold, invalid)
* Description
* Tags

#### Tags

Tags can be arbitrary Unicode strings, but may not contain the ',' character
and any padding spaces. This is not a limitation of Tick itself, but rather of
the various commands that will manipulate tags.

### Property types

In order to simplify serialization to JSON, every property is given a specific
type, which defaults to `:string`.
Following is a list of currently available types and their JSON representation.

Please note that the number of types is very restricted, but based on the YAGNI
principle we will only introduce new ones as needed.

#### String

The `:string` type is represented as the value within a Hash, the key is the
name of the property.

For example `Ticket#author` is serialized to:

    {
      "author": "manveru"
    }


#### Time

The `:time` type is represented as a Fixnum value within a Hash, the key is the
name of the property. The Fixnum is the result of `Time.to_i`, which can be
read again by `Time::at`. As `Time.to_i` represents a UNIX timestamp, this is
only valid until 2038 for now, we don't expect tickets with greater values for
now, and hope that everybody will be running 64bit systems when this becomes an
issue.

For example `Ticket#created_at` is serialized to:

    {
      "created_at": 1243245019
    }


#### Set

The `:set` type is represented as an ordered Array without another enclosure.
It may not contain duplicate values, they will be discarded on every round
trip.

For example `Ticket#tags` is serialized to:

    [
      "git",
      "tick",
      "ticket",
      "tracking"
    ]
