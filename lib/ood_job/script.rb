module OodJob
  # An object that describes a batch job before it is submitted. This includes
  # the resources this batch job will require of the resource manager.
  class Script
    # String describing the script to be executed on the remote host
    # @return [String] the script content
    attr_reader :content

    # Arguments supplied to script to be executed
    # @return [Array<String>, nil] arguments supplied to script
    attr_reader :args

    # Whether job is held after submitted
    # @return [Boolean, nil] whether job is held after submit
    attr_reader :submit_as_hold

    # Whether job can safely be restarted by the resource manager, for example on
    # node failure or some other re-scheduling event
    # @note This SHOULD NOT be used to let the application denote the
    #   checkpointability of a job
    # @return [Boolean, nil] whether job can be restarted
    attr_reader :rerunnable

    # Environment variables to be set on remote host when running job
    # @note These will override the remote host environment settings
    # @return [Hash{String=>String}, nil] environment variables
    attr_reader :job_environment

    # Directory where the job is executed from
    # @return [Pathname, nil] working directory
    attr_reader :workdir

    # List of email addresses that should be used when resource manager sends
    # status notifications
    # @return [Array<String>, nil] list of emails
    attr_reader :email

    # Whether given email addresses should be notified when job starts
    # @return [Boolean, nil] whether email when job starts
    attr_reader :email_on_started

    # Whether given email addresses should be notified when job ends
    # @return [Boolean, nil] whether email when job ends
    attr_reader :email_on_terminated

    # The name of the job
    # @return [String, nil] name of job
    attr_reader :job_name

    # Path to file specifying the input stream of the job
    # @return [Pathname, nil] file path specifying input stream
    attr_reader :input_path

    # Path to file specifying the output stream of the job
    # @return [Pathname, nil] file path specifying output stream
    attr_reader :output_path

    # Path to file specifying the error stream of the job
    # @return [Pathname, nil] file path specifying error stream
    attr_reader :error_path

    # Whether the error stream should be intermixed with the output stream
    # @return [Boolean, nil] whether error stream intermixed with output stream
    attr_reader :join_files

    # Identifier of existing reservation to be associated with the job
    # @return [String, nil] reservation id
    attr_reader :reservation_id

    # Name of the queue the job should be submitted to
    # @return [String, nil] queue name
    attr_reader :queue_name

    # The scheduling priority for the job
    # @return [Fixnum, nil] scheduling priority
    attr_reader :priority

    # The minmimum amount of physical memory in kilobyte that should be available
    # for the job
    # @return [Fixnum, nil] minimum physical memory
    attr_reader :min_phys_memory

    # The earliest time when the job may be eligible to run
    # @return [Time, nil] eligible start time
    attr_reader :start_time

    # The maximum amount of real time during which the job can be running in
    # seconds
    # @return [Fixnum, nil] max real time
    attr_reader :wall_time

    # The attribute used for job accounting purposes
    # @return [String, nil] accounting id
    attr_reader :accounting_id

    # The minimum number of procs requested per job
    # @return [Fixnum, nil] minimum number of procs
    attr_reader :min_procs

    # Node or list of nodes detailing the specifications the job should run on
    # @example Job to run on a list of defined nodes
    #   my_job.nodes
    #   #=> ["n0001", "n0002", "n0003"]
    # @example Job to run on 2 nodes with 12 procs per node
    #   my_job.nodes
    #   #=> [
    #   #     #<OodJob::NodeRequest procs=12, properties={}>,
    #   #     #<OodJob::NodeRequest procs=12, properties={}>
    #   #   ]
    # @example Create job script that will run on 100 nodes with 20 procs per node
    #   OodJob::Script.new(
    #     script: Pathname.new('/path/to/script'),
    #     nodes: [OodJob::NodeRequest.new(procs: 20)] * 100
    #   )
    # @return [Array<String, NodeRequest>, nil] list of nodes
    attr_reader :nodes

    # Object detailing any native specifications that are implementation specific
    # @note Should not be used at all costs.
    # @return [Object, nil] native specifications
    attr_reader :native

    # @param content [#read, #to_s] the script content
    # @param args [Array<#to_s>, nil] arguments supplied to script
    # @param submit_as_hold [Boolean, nil] whether job is held after submit
    # @param rerunnable [Boolean, nil] whether job can be restarted
    # @param job_environment [Hash{#to_s => #to_s}, nil] environment variables
    # @param workdir [#to_s, nil] working directory
    # @param email [#to_s, Array<#to_s>, nil] list of emails
    # @param email_on_started [Boolean, nil] whether email when job starts
    # @param email_on_terminated [Boolean, nil] whether email when job ends
    # @param job_name [#to_s, nil] name of job
    # @param input_path [#to_s, nil] file path specifying input stream
    # @param output_path [#to_s, nil] file path specifying output stream
    # @param error_path [#to_s, nil] file path specifying error stream
    # @param join_files [Boolean, nil] whether error stream intermixed with output stream
    # @param reservation_id [#to_s, nil] reservation id
    # @param queue_name [#to_s, nil] queue name
    # @param priority [#to_i, nil] scheduling priority
    # @param min_phys_memory [#to_i, nil] minimum physical memory
    # @param start_time [#to_i, nil] eligible start time
    # @param wall_time [#to_i, nil] max real time
    # @param accounting_id [#to_s, nil] accounting id
    # @param min_procs [#to_i, nil] minimum number of procs
    # @param nodes [#to_h, #to_s, Hash{#to_h, #to_s => #to_i}, nil] list of nodes
    # @param native [Object, nil] native specifications
    def initialize(content:, args: nil, submit_as_hold: nil, rerunnable: nil,
                   job_environment: nil, workdir: nil, email: nil,
                   email_on_started: nil, email_on_terminated: nil, job_name: nil,
                   input_path: nil, output_path: nil, error_path: nil,
                   join_files: nil, reservation_id: nil, queue_name: nil,
                   priority: nil, min_phys_memory: nil, start_time: nil,
                   wall_time: nil, accounting_id: nil, min_procs: nil, nodes: nil,
                   native: nil, **_)
      @content             = content.respond_to?(:read) ? content.read : content.to_s
      @args                = args.map(&:to_s) unless args.nil?
      @submit_as_hold      = submit_as_hold unless submit_as_hold.nil?
      @rerunnable          = rerunnable unless rerunnable.nil?
      @job_environment     = job_environment.each_with_object({}) { |(k, v), h| h[k.to_s] = v.to_s } unless job_environment.nil?
      @workdir             = Pathname.new(workdir.to_s) unless workdir.nil?
      @email               = [email].flatten.map(&:to_s) unless email.nil?
      @email_on_started    = email_on_started unless email_on_started.nil?
      @email_on_terminated = email_on_terminated unless email_on_terminated.nil?
      @job_name            = job_name.to_s unless job_name.nil?
      @input_path          = Pathname.new(input_path.to_s) unless input_path.nil?
      @output_path         = Pathname.new(output_path.to_s) unless output_path.nil?
      @error_path          = Pathname.new(error_path.to_s) unless error_path.nil?
      @join_files          = join_files unless join_files.nil?
      @reservation_id      = reservation_id.to_s unless reservation_id.nil?
      @queue_name          = queue_name.to_s unless queue_name.nil?
      @priority            = priority.to_i unless priority.nil?
      @min_phys_memory     = min_phys_memory.to_i unless min_phys_memory.nil?
      @start_time          = Time.at(start_time.to_i) unless start_time.nil?
      @wall_time           = wall_time.to_i unless wall_time.nil?
      @accounting_id       = accounting_id.to_s unless accounting_id.nil?
      @min_procs           = min_procs.to_i unless min_procs.nil?
      @nodes               = [nodes].flatten.map { |n| n.respond_to?(:to_h) ? NodeRequest.new(n.to_h) : n.to_s } unless nodes.nil?
      @native              = native
    end

    # Convert object to hash
    # @return [Hash] object as hash
    def to_h
      {
        content:             content,
        args:                args,
        submit_as_hold:      submit_as_hold,
        rerunnable:          rerunnable,
        job_environment:     job_environment,
        workdir:             workdir,
        email:               email,
        email_on_started:    email_on_started,
        email_on_terminated: email_on_terminated,
        job_name:            job_name,
        input_path:          input_path,
        output_path:         output_path,
        error_path:          error_path,
        join_files:          join_files,
        reservation_id:      reservation_id,
        queue_name:          queue_name,
        priority:            priority,
        min_phys_memory:     min_phys_memory,
        start_time:          start_time,
        wall_time:           wall_time,
        accounting_id:       accounting_id,
        min_procs:           min_procs,
        nodes:               nodes,
        native:              native
      }
    end

    # The comparison operator
    # @param other [#to_h] object to compare against
    # @return [Boolean] whether objects are equivalent
    def ==(other)
      to_h == other.to_h
    end

    # Whether objects are identical to each other
    # @param other [#to_h] object to compare against
    # @return [Boolean] whether objects are identical
    def eql?(other)
      self.class == other.class && self == other
    end

    # Generate a hash value for this object
    # @return [Fixnum] hash value of object
    def hash
      [self.class, to_h].hash
    end
  end
end
