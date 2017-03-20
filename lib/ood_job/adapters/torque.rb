require 'pbs'
require 'ood_job/refinements/array_wrap'

module OodJob
  module Adapters
    # An adapter object that describes the communication with a Torque resource
    # manager for job management.
    class Torque < Adapter
      using Refinements::ArrayWrap

      # Mapping of state characters for PBS
      STATE_MAP = {
        'Q' => :queued,
        'H' => :queued_held,
        'R' => :running,
        'S' => :suspended,
        'E' => :running         # exiting, but still running
      }

      # Submit a job with the attributes defined in the job template instance
      # @param (see Adapter#submit)
      # @return (see Adapter#submit)
      # @raise [Error] if something goes wrong submitting a job
      # @see Adapter#submit
      def submit(script:, after: [], afterok: [], afternotok: [], afterany: [])
        after      = Array.wrap(after).map(&:to_s)
        afterok    = Array.wrap(afterok).map(&:to_s)
        afternotok = Array.wrap(afternotok).map(&:to_s)
        afterany   = Array.wrap(afterany).map(&:to_s)

        # Set headers
        headers = {}
        headers.merge!(job_arguments: script.args.join(' ')) unless script.args.nil?
        headers.merge!(Hold_Types: :u) if script.submit_as_hold
        headers.merge!(Rerunable: script.rerunnable ? 'y' : 'n') unless script.rerunnable.nil?
        headers.merge!(init_work_dir: script.workdir) unless script.workdir.nil?
        headers.merge!(Mail_Users: script.email.join(',')) unless script.email.nil?
        mail_points  = ''
        mail_points += 'b' if script.email_on_started
        mail_points += 'e' if script.email_on_terminated
        headers.merge!(Mail_Points: mail_points) unless mail_points.empty?
        headers.merge!(Job_Name: script.job_name) unless script.job_name.nil?
        # ignore input_path (not defined in Torque)
        headers.merge!(Output_Path: script.output_path) unless script.output_path.nil?
        headers.merge!(Error_Path: script.error_path) unless script.error_path.nil?
        headers.merge!(Join_Path: 'oe') if script.join_files
        headers.merge!(reservation_id: script.reservation_id) unless script.reservation_id.nil?
        headers.merge!(Priority: script.priority) unless script.priority.nil?
        headers.merge!(Execution_Time: script.start_time.localtime.strftime("%C%y%m%d%H%M.%S")) unless script.start_time.nil?
        headers.merge!(Account_Name: script.accounting_id) unless script.accounting_id.nil?

        # Set dependencies
        depend = []
        depend << "after:#{after.join(':')}"           unless after.empty?
        depend << "afterok:#{afterok.join(':')}"       unless afterok.empty?
        depend << "afternotok:#{afternotok.join(':')}" unless afternotok.empty?
        depend << "afterany:#{afterany.join(':')}"     unless afterany.empty?
        headers.merge!(depend: depend.join(','))       unless depend.empty?

        # Set resources
        resources = {}
        resources.merge!(mem: "#{script.min_phys_memory}KB") unless script.min_phys_memory.nil?
        resources.merge!(walltime: seconds_to_duration(script.wall_time)) unless script.wall_time.nil?
        if script.nodes && !script.nodes.empty?
          nodes = uniq_array(script.nodes)
          resources.merge!(nodes: nodes.map {|k, v| k.is_a?(NodeRequest) ? node_request_to_str(k, v) : k }.join('+'))
        end

        # Set environment variables
        envvars = script.job_environment || {}

        # Set native options
        if script.native
          headers.merge!   script.native.fetch(:headers, {})
          resources.merge! script.native.fetch(:resources, {})
          envvars.merge!   script.native.fetch(:envvars, {})
        end

        # Submit job
        pbs.submit_string(script.content, queue: script.queue_name, headers: headers, resources: resources, envvars: envvars)
      rescue PBS::Error => e
        raise Error, e.message
      end

      # Retrieve job info from the resource manager
      # @param (see Adapter#info)
      # @return (see Adapter#info)
      # @raise [Error] if something goes wrong getting job info
      # @see Adapter#info
      def info(id: '')
        id = id.to_s
        info_ary = pbs.get_jobs(id: id).map do |k, v|
          /^(?<job_owner>[\w-]+)@/ =~ v[:Job_Owner]
          allocated_nodes = parse_nodes(v[:exec_host] || "")
          Info.new(
            id: k,
            status: STATE_MAP.fetch(v[:job_state], :undetermined),
            allocated_nodes: allocated_nodes,
            submit_host: v[:submit_host],
            job_owner: job_owner,
            procs: allocated_nodes.inject(0) { |sum, x| sum + x[:procs] },
            queue_name: v[:queue],
            wallclock_time: duration_in_seconds(v.fetch(:resources_used, {})[:walltime]),
            cpu_time: duration_in_seconds(v.fetch(:resources_used, {})[:cput]),
            submission_time: v[:ctime],
            dispatch_time: v[:start_time],
            native: v
          )
        end
        info_ary.size == 1 ? info_ary.first : info_ary
      rescue PBS::UnkjobidError
        Info.new(
          id: id,
          status: :undetermined
        )
      rescue PBS::Error => e
        raise Error, e.message
      end

      # Retrieve job status from resource manager
      # @param (see Adapter#status)
      # @return (see Adapter#status)
      # @raise [Error] if something goes wrong getting job status
      # @see Adapter#status
      def status(id:)
        id = id.to_s
        char = pbs.get_job(id, filters: [:job_state])[id][:job_state]
        Status.new(state: STATE_MAP.fetch(char, :undetermined))
      rescue PBS::UnkjobidError
        Status.new(state: :undetermined)
      rescue PBS::Error => e
        raise Error, e.message
      end

      # Put the submitted job on hold
      # @param (see Adapter#hold)
      # @return (see Adapter#hold)
      # @raise [Error] if something goes wrong holding a job
      # @see Adapter#hold
      def hold(id:)
        pbs.hold_job(id.to_s)
      rescue PBS::UnkjobidError
        nil
      rescue PBS::Error => e
        raise Error, e.message
      end

      # Release the job that is on hold
      # @param (see Adapter#release)
      # @return (see Adapter#release)
      # @raise [Error] if something goes wrong releasing a job
      # @see Adapter#release
      def release(id:)
        pbs.release_job(id.to_s)
      rescue PBS::UnkjobidError
        nil
      rescue PBS::Error => e
        raise Error, e.message
      end

      # Delete the submitted job
      # @param (see Adapter#delete)
      # @return (see Adapter#delete)
      # @raise [Error] if something goes wrong deleting a job
      # @see Adapter#delete
      def delete(id:)
        pbs.delete_job(id.to_s)
      rescue PBS::UnkjobidError
        nil
      rescue PBS::Error => e
        raise Error, e.message
      end

      private
        # PBS object used to communicate with Torque batch server
        def pbs
          s = cluster.resource_mgr_server
          PBS::Batch.new(host: s.host, lib: s.lib, bin: s.bin)
        end

        # Convert duration to seconds
        def duration_in_seconds(time)
          time.nil? ? 0 : time.split(':').map { |v| v.to_i }.inject(0) { |total, v| total * 60 + v }
        end

        # Convert seconds to duration
        def seconds_to_duration(time)
          '%02d:%02d:%02d' % [time/3600, time/60%60, time%60]
        end

        # Convert host list string to individual nodes
        # "n0163/2,7,10-11+n0205/0-11+n0156/0-11"
        def parse_nodes(node_list)
          node_list.split('+').map do |n|
            name, procs_list = n.split('/')
            # count procs used in range expression
            procs = procs_list.split(',').inject(0) do |sum, x|
              sum + (x =~ /^(\d+)-(\d+)$/ ? ($2.to_i - $1.to_i) : 0) + 1
            end
            {name: name, procs: procs}
          end
        end

        # Convert a NodeRequest object to a valid Torque string
        def node_request_to_str(node, cnt)
          str = cnt.to_s
          str += ":ppn=#{node.procs}" if node.procs
          str += ":#{node.properties.join(':')}" if node.properties
          str
        end
    end
  end
end
