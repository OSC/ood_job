# OodJob

Library that provides a generic interface to submit/status/hold/release/delete
batch jobs for various resource managers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ood_job'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install ood_job
```

## Usage

### Create a Job

First we will need a script to submit to the resource manager. The simplest
script object can consist of either a file or a string of shell code.

```ruby
# A path to a file
script = OodJob::Script.new(content: Pathname.new("/path/to/my/script"))

# Or a string IO
script_str = StringIO.new("echo 'begin' && sleep 60 && echo 'done'")
script = OodJob::Script.new(content: script_str)

# Or a string
script_str = "echo 'hello world'"
script = OodJob::Script.new(content: script_str)
```

A script object must be supplied with an object that responds to the method
`#read`.

With time you will create more complicated script objects:

```ruby
script = OodJob::Script.new(
  content: Pathname.new("/path/to/my/script"),
  job_name: "my_solver_job",
  wall_time: 3600,                         # walltime=01:00:00
  nodes: [NodeRequest.new(procs: 12)]*20,  # nodes=20:ppn=12
  output_path: Pathname.new("/path/to/output"),
  join_files: true,
  accounting_id: "PZS0001"
)
```

Note: Any options supplied when creating a script object **will** override
those specified in the script file itself.

### Submit a Script

Once you have a script object you are satisfied with, you will want to submit
it to a given resource manager. This is where the `OodCluster::Cluster` object
will come into play. This object describes a given cluster and its various
servers (one of which is a resource manager).

If you are using the `OodAppkit` from a Rails app:

```ruby
# Get the Oakley cluster object from OodAppkit
oak = OodAppkit.clusters['oakley']

# Use this cluster object to submit the script (be sure you choose the correct
# adapter to communicate with this cluster)
adapter = OodJob::Adapters::Torque.new(cluster: oak)

# Submit your script
adapter.submit(script: script)
#=> "1234.server"
```

To submit dependencies for complex workflows:

```ruby
# Submit pre-processing script
pre_id = adapter.submit(script: pre_process_script)

# Submit multiple solver scripts to run if pre-processing terminated
# successfully
solve_id1 = adapter.submit(script: solver_script1, afterok: [pre_id])
solve_id2 = adapter.submit(script: solver_script2, afterok: [pre_id])
solve_id3 = adapter.submit(script: solver_script3, afterok: [pre_id])
solve_id4 = adapter.submit(script: solver_script4, afterok: [pre_id])

# Sumit post-processing script to run after all jobs terminated with or without
# errors
adapter.submit(script: post_process, afterany: [solve_id1, solve_id2, solve_id3, solve_id4])
```

### Status of Job

Assuming we have our adapter object from before and we know the job id:

```ruby
# Get job status
status = adapter.status(id: "1234.server")
#=> #<OodJob::Status @state=:running>

# Check if job is queued or running
status.queued?  #=> false
status.running? #=> true
```

If we want more details about the job, we can request its `#info`

```ruby
# Get job info
info = adapter.info(id: "1234.server")
#=> #<OodJob::Info ...>

# Check some values
info.job_owner       #=> "bob"
info.submission_time #=> 2016-11-07 10:12:05 -0500
info.procs           #=> 12
info.status          #=> #<OodJob::Status @state=:running>
...
```

Note: You can retrieve the info for every job on the cluster if you specify a
blank id.

```ruby
# Get all jobs info
adapter.info(id: "")
#=> [
#     #<OodJob::Info ...>,
#     #<OodJob::Info ...>,
#     ...
#   ]
```

### Hold a Job

Assuming we have our adapter object from before and we know the job id:

```ruby
# Hold job
adapter.hold(id: "1234.server")
```

### Release a Job

Assuming we have our adapter object from before and we know the job id:

```ruby
# Release job
adapter.release(id: "1234.server")
```

### Delete a job

Assuming we have our adapter object from before and we know the job id:

```ruby
# Delete job
adapter.delete(id: "1234.server")
```

## Development

To develop you will need to install all the necessary gems:

```sh
bundle install --path=vendor/bundle
```

You can then access the development console through:

```sh
bundle exec pry -Ilib
```

You must always run through the tests after changes to make sure you didn't
break anything:

```sh
bundle exec rspec spec
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ood_job/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
