require 'spec_helper'

describe OodJob::Adapters::Torque do
  host = 'host.com'
  lib = Pathname.new('/path/to/lib')
  bin = Pathname.new('/path/to/bin')
  version = 'v123'

  let(:cluster) { double(resource_mgr_server: double(host: host, lib: lib, bin: bin, version: version)) }
  subject(:adapter) { OodJob::Adapters::Torque.new cluster: cluster }

  it { expect(described_class).to be < OodJob::Adapter }

  describe '#submit' do
    context 'when :script not defined' do
      it 'raises ArgumentError' do
        expect { adapter.submit }.to raise_error(ArgumentError)
      end
    end

    context 'when :script is defined' do
      before { allow(PBS::Batch).to receive(:new) { pbs } }
      let(:job_id) { 'job_id' }
      let(:pbs) { double(submit_string: job_id) }
      let(:script_args) { { content: 'test_script' } }
      let(:script) { OodJob::Script.new script_args }
      let(:args) { { script: script } }
      subject { adapter.submit args }

      it 'returns job id' do
        is_expected.to eq(job_id)
      end

      context 'with :content' do
        before { subject }
        let(:queue)     { nil }
        let(:headers)   { {} }
        let(:resources) { {} }
        let(:envvars)   { {} }

        it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }

        context 'and :queue_name' do
          let(:script_args) { super().merge queue_name: 'queue' }
          let(:queue) { 'queue' }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :args' do
          let(:script_args) { super().merge args: ['arg1', 'arg2'] }
          let(:headers) { { job_arguments: 'arg1 arg2' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :submit_as_hold' do
          context 'as true' do
            let(:script_args) { super().merge submit_as_hold: true }
            let(:headers) { { Hold_Types: :u } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'as false' do
            let(:script_args) { super().merge submit_as_hold: false }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end

        context 'and :rerunnable' do
          context 'as true' do
            let(:script_args) { super().merge rerunnable: true }
            let(:headers) { { Rerunable: 'y' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'as false' do
            let(:script_args) { super().merge rerunnable: false }
            let(:headers) { { Rerunable: 'n' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end

        context 'and :job_environment' do
          let(:script_args) { super().merge job_environment: {'VAR1' => 'ENV1', 'VAR2' => 'ENV2'} }
          let(:envvars) { { 'VAR1' => 'ENV1', 'VAR2' => 'ENV2' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :workdir' do
          let(:script_args) { super().merge workdir: Pathname.new('/path/to/workdir') }
          let(:headers) { { init_work_dir: Pathname.new('/path/to/workdir') } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :email' do
          let(:script_args) { super().merge email: ['email1', 'email2'] }
          let(:headers) { { Mail_Users: 'email1,email2' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :email_as_started' do
          context 'as true' do
            let(:script_args) { super().merge email_on_started: true }
            let(:headers) { { Mail_Points: 'b' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'as false' do
            let(:script_args) { super().merge email_on_started: false }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end

        context 'and :email_as_terminated' do
          context 'as true' do
            let(:script_args) { super().merge email_on_terminated: true }
            let(:headers) { { Mail_Points: 'e' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'as false' do
            let(:script_args) { super().merge email_on_terminated: false }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end

        context 'and :email_as_started as well as :email_on_terminated' do
          let(:script_args) { super().merge email_on_started: true, email_on_terminated: true }
          let(:headers) { { Mail_Points: 'be' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :job_name' do
          let(:script_args) { super().merge job_name: 'job name' }
          let(:headers) { { Job_Name: 'job name' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :input_path' do
          let(:script_args) { super().merge input_path: Pathname.new('/path/to/input') }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :output_path' do
          let(:script_args) { super().merge output_path: Pathname.new('/path/to/output') }
          let(:headers) { { Output_Path: Pathname.new('/path/to/output') } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :error_path' do
          let(:script_args) { super().merge error_path: Pathname.new('/path/to/error') }
          let(:headers) { { Error_Path: Pathname.new('/path/to/error') } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :join_files' do
          context 'as true' do
            let(:script_args) { super().merge join_files: true }
            let(:headers) { { Join_Path: 'oe' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'as false' do
            let(:script_args) { super().merge join_files: false }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end

        context 'and :reservation_id' do
          let(:script_args) { super().merge reservation_id: 'rsv id' }
          let(:headers) { { reservation_id: 'rsv id' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :priority' do
          let(:script_args) { super().merge priority: 5000 }
          let(:headers) { { Priority: 5000 } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :start_time' do
          let(:script_args) { super().merge start_time: 1478631234 }
          let(:headers) { { Execution_Time: '201611081353.54' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :accounting_id' do
          let(:script_args) { super().merge accounting_id: 'account id' }
          let(:headers) { { Account_Name: 'account id' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :min_phys_memory' do
          let(:script_args) { super().merge min_phys_memory: 1234 }
          let(:resources) { { mem: '1234KB' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :wall_time' do
          let(:script_args) { super().merge wall_time: 94534 }
          let(:resources) { { walltime: '26:15:34' } }

          it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
        end

        context 'and :nodes' do
          context 'as single node name' do
            let(:script_args) { super().merge nodes: 'node1' }
            let(:resources) { { nodes: 'node1' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'as single node request object' do
            let(:script_args) { super().merge nodes: { procs: 12, properties: ['type1', 'type2'] } }
            let(:resources) { { nodes: '1:ppn=12:type1:type2' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'as a list of nodes' do
            let(:script_args) { super().merge nodes: ['node1'] + [{procs: 12}]*4 + ['node2', {procs: 45, properties: 'type1'}] }
            let(:resources) { { nodes: 'node1+4:ppn=12+node2+1:ppn=45:type1' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end

        context 'and :native' do
          context 'with :headers' do
            let(:script_args) { super().merge native: { headers: { check: 'this' } } }
            let(:headers) { { check: 'this' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'with :resources' do
            let(:script_args) { super().merge native: { resources: { check: 'this' } } }
            let(:resources) { { check: 'this' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context 'with :envvars' do
            let(:script_args) { super().merge native: { envvars: { check: 'this' } } }
            let(:envvars) { { check: 'this' } }

            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end

        %i(after afterok afternotok afterany).each do |after|
          context "and :#{after} is defined as a single object" do
            let(:_job_id) { '_job id' }
            let(:_id)     { double(to_s: _job_id) }
            let(:args)    { { script: script, after => _id } }
            let(:headers) { { depend: "#{after}:#{_job_id}" } }

            it { expect(_id).to have_received(:to_s).with(no_args) }
            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end

          context "and :#{after} is defined as an array" do
            let(:_job_id) { [ '_job id0', '_job id1' ] }
            let(:_id)     { [ double(to_s: _job_id[0]), double(to_s: _job_id[1]) ] }
            let(:args)    { { script: script, after => _id } }
            let(:headers) { { depend: "#{after}:#{_job_id.join(':')}" } }

            it { expect(_id[0]).to have_received(:to_s).with(no_args) }
            it { expect(_id[1]).to have_received(:to_s).with(no_args) }
            it { expect(pbs).to have_received(:submit_string).with(script_args[:content], queue: queue, headers: headers, resources: resources, envvars: envvars) }
          end
        end
      end

      context 'and raises PBS::Error' do
        before { expect(pbs).to receive(:submit_string).and_raise(PBS::Error) }

        it 'raises OodJob::Adapter::Error' do
          expect { subject }.to raise_error(OodJob::Adapter::Error)
        end
      end
    end
  end

  describe '#info' do
    context 'when :id is not specified' do
      before { allow(PBS::Batch).to receive(:new) { pbs } }
      let(:job_hash) { {} }
      let(:pbs) { double(get_jobs: {}) }
      subject { adapter.info }

      it 'gets the job info using PBS' do
        subject
        expect(pbs).to have_received(:get_jobs).with(id: '')
      end

      it 'returns an array' do
        is_expected.to eq([])
      end
    end

    context 'when :id is specified' do
      before { allow(PBS::Batch).to receive(:new) { pbs } }
      let(:job_id)   { 'job id' }
      let(:job_hash) { {} }
      let(:id)  { double(to_s: job_id) }
      let(:pbs) { double(get_jobs: { job_id => job_hash }) }
      subject { adapter.info id: id }

      it 'duck-types :id' do
        subject
        expect(id).to have_received(:to_s).with(no_args)
      end

      it 'gets the job info using PBS' do
        subject
        expect(pbs).to have_received(:get_jobs).with(id: job_id)
      end

      context 'and job is not running' do
        let(:job_hash) {
          {
            :Job_Name=>"gromacs_job",
            :Job_Owner=>"cwr0448@oakley02.osc.edu",
            :job_state=>"Q",
            :queue=>"parallel",
            :server=>"oak-batch.osc.edu:15001",
            :Account_Name=>"PAA0016",
            :Checkpoint=>"u",
            :ctime=>"1478625456",
            :Error_Path=>"oakley02.osc.edu:/users/PDS0218/cwr0448/GROMACS/VANILLIN/BULK/E75/free/gromacs_job.e7964023",
            :Hold_Types=>"n",
            :Join_Path=>"oe",
            :Keep_Files=>"n",
            :Mail_Points=>"a",
            :mtime=>"1478625456",
            :Output_Path=>"oakley02.osc.edu:/users/PDS0218/cwr0448/GROMACS/VANILLIN/BULK/E75/free/gromacs_job.o7964023",
            :Priority=>"0",
            :qtime=>"1478625456",
            :Rerunable=>"True",
            :Resource_List=>{:gattr=>"PDS0218", :nodect=>"2", :nodes=>"2:ppn=12", :walltime=>"30:00:00"},
            :Shell_Path_List=>"/bin/bash",
            :euser=>"cwr0448",
            :egroup=>"PDS0218",
            :queue_type=>"E",
            :etime=>"1478625456",
            :submit_args=>"subGro.sh",
            :fault_tolerant=>"False",
            :job_radix=>"0",
            :submit_host=>"oakley02.osc.edu"
          }
        }

        it 'returns correct OodJob::Info object' do
          is_expected.to eql(OodJob::Info.new(
            :id=>job_id,
            :status=>:queued,
            :allocated_nodes=>[],
            :submit_host=>"oakley02.osc.edu",
            :job_owner=>"cwr0448",
            :procs=>0,
            :queue_name=>"parallel",
            :wallclock_time=>0,
            :cpu_time=>0,
            :submission_time=>"1478625456",
            :dispatch_time=>nil,
            :native=>job_hash
          ))
        end
      end

      context 'and job is running' do
        let(:job_hash) {
          {
            :Job_Name=>"12_4_g_s_10hr_96_p7",
            :Job_Owner=>"osu9723@oakley01.osc.edu",
            :resources_used=>{:cput=>"73:29:59", :energy_used=>"0", :mem=>"12425624kb", :vmem=>"31499808kb", :walltime=>"06:28:23"},
            :job_state=>"R",
            :queue=>"parallel",
            :server=>"oak-batch.osc.edu:15001",
            :Account_Name=>"PAS1136",
            :Checkpoint=>"u",
            :ctime=>"1474895720",
            :Error_Path=>"oakley01.osc.edu:/users/PAS1136/osu9723/12_4_g_s_10hr_96_p7.e7539119",
            :exec_host=>"n0635/0-11+n0636/0-11+n0658/0-11+n0657/0-11+n0656/0-11+n0311/0-11+n0310/0-11+n0309/0-11",
            :exec_port=>"15003+15003+15003+15003+15003+15003+15003+15003",
            :Hold_Types=>"n",
            :Join_Path=>"oe",
            :Keep_Files=>"n",
            :Mail_Points=>"a",
            :mtime=>"1478612793",
            :Output_Path=>"oakley01.osc.edu:/users/PAS1136/osu9723/12_4_g_s_10hr_96_p7.o7539119",
            :Priority=>"0",
            :qtime=>"1474895720",
            :Rerunable=>"True",
            :Resource_List=>{:gattr=>"PAS1136", :nodect=>"8", :nodes=>"8:ppn=12", :walltime=>"09:59:00"},
            :session_id=>"9739",
            :Shell_Path_List=>"/bin/bash",
            :euser=>"osu9723",
            :egroup=>"PAS1136",
            :queue_type=>"E",
            :comment=>"could not find appropriate resources on partition ALL for the following shapes: shape[1] 96 (resources not available in any partition)",
            :etime=>"1478612727",
            :submit_args=>"12_4_g_s_10hr_96_p7.job",
            :start_time=>"1478612793",
            :Walltime=>{:Remaining=>"12581"},
            :start_count=>"1",
            :fault_tolerant=>"False",
            :job_radix=>"0",
            :submit_host=>"oakley01.osc.edu"
          }
        }

        it 'returns correct OodJob::Info object' do
          is_expected.to eql(OodJob::Info.new(
            :id=>job_id,
            :status=>:running,
            :allocated_nodes=>[
              {:name=>"n0635", :procs=>12},
              {:name=>"n0636", :procs=>12},
              {:name=>"n0658", :procs=>12},
              {:name=>"n0657", :procs=>12},
              {:name=>"n0656", :procs=>12},
              {:name=>"n0311", :procs=>12},
              {:name=>"n0310", :procs=>12},
              {:name=>"n0309", :procs=>12}
            ],
            :submit_host=>"oakley01.osc.edu",
            :job_owner=>"osu9723",
            :procs=>96,
            :queue_name=>"parallel",
            :wallclock_time=>23303,
            :cpu_time=>264599,
            :submission_time=>"1474895720",
            :dispatch_time=>"1478612793",
            :native=>job_hash
          ))
        end
      end

      context 'and raises PBS::UnkjobidError' do
        before { expect(pbs).to receive(:get_jobs).and_raise(PBS::UnkjobidError) }

        it 'returns default OodJob::Info' do
          is_expected.to eql(OodJob::Info.new(id: job_id, status: :completed))
        end
      end

      context 'and raises PBS::Error' do
        before { expect(pbs).to receive(:get_jobs).and_raise(PBS::Error) }

        it 'raises OodJob::Adapter::Error' do
          expect { subject }.to raise_error(OodJob::Adapter::Error)
        end
      end
    end
  end

  describe '#status' do
    context 'when :id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.status }.to raise_error(ArgumentError)
      end
    end

    context 'when :id is specified' do
      before { allow(PBS::Batch).to receive(:new) { pbs } }
      let(:job_id) { 'job id' }
      let(:state)  { 'Q' }
      let(:id)  { double(to_s: job_id) }
      let(:pbs) { double(get_job: { job_id => { job_state: state } }) }
      subject { adapter.status id: id }

      it 'duck-types :id' do
        subject
        expect(id).to have_received(:to_s).with(no_args)
      end

      context 'and job is queued' do
        before { subject }

        it { expect(pbs).to have_received(:get_job).with(job_id, filters: [:job_state]) }
        it { is_expected.to be_queued }
      end

      context 'and job is held' do
        let(:state) { 'H' }
        before { subject }

        it { expect(pbs).to have_received(:get_job).with(job_id, filters: [:job_state]) }
        it { is_expected.to be_queued_held }
      end

      context 'and job is suspended' do
        let(:state) { 'S' }
        before { subject }

        it { expect(pbs).to have_received(:get_job).with(job_id, filters: [:job_state]) }
        it { is_expected.to be_suspended }
      end

      context 'and job is running' do
        let(:state) { 'R' }
        before { subject }

        it { expect(pbs).to have_received(:get_job).with(job_id, filters: [:job_state]) }
        it { is_expected.to be_running }
      end

      context 'and job is completed' do
        let(:state) { 'C' }
        before { subject }

        it { expect(pbs).to have_received(:get_job).with(job_id, filters: [:job_state]) }
        it { is_expected.to be_completed }
      end

      context 'and job is unknown PBS state' do
        let(:state) { 'X' }
        before { subject }

        it { expect(pbs).to have_received(:get_job).with(job_id, filters: [:job_state]) }
        it { is_expected.to be_undetermined }
      end

      context 'and raises PBS::UnkjobidError' do
        before { expect(pbs).to receive(:get_job).and_raise(PBS::UnkjobidError) }

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end
        it { is_expected.to be_completed }
      end

      context 'and raises PBS::Error' do
        before { expect(pbs).to receive(:get_job).and_raise(PBS::Error) }

        it 'raises OodJob::Adapter::Error' do
          expect { subject }.to raise_error(OodJob::Adapter::Error)
        end
      end
    end
  end

  describe '#hold' do
    context 'when :id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.hold }.to raise_error(ArgumentError)
      end
    end

    context 'when :id is specified' do
      before { allow(PBS::Batch).to receive(:new) { pbs } }
      let(:job_id) { 'job id' }
      let(:id)  { double(to_s: job_id) }
      let(:pbs) { double(hold_job: nil) }
      subject { adapter.hold id: id }

      it 'duck-types :id' do
        subject
        expect(id).to have_received(:to_s).with(no_args)
      end

      it 'holds the job using PBS' do
        subject
        expect(pbs).to have_received(:hold_job).with(job_id)
      end

      context 'and raises PBS::UnkjobidError' do
        before { expect(pbs).to receive(:hold_job).and_raise(PBS::UnkjobidError) }

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end
      end

      context 'and raises PBS::Error' do
        before { expect(pbs).to receive(:hold_job).and_raise(PBS::Error) }

        it 'raises OodJob::Adapter::Error' do
          expect { subject }.to raise_error(OodJob::Adapter::Error)
        end
      end
    end
  end

  describe '#release' do
    context 'when :id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.release }.to raise_error(ArgumentError)
      end
    end

    context 'when :id is specified' do
      before { allow(PBS::Batch).to receive(:new) { pbs } }
      let(:job_id) { 'job id' }
      let(:id)  { double(to_s: job_id) }
      let(:pbs) { double(release_job: nil) }
      subject { adapter.release id: id }

      it 'duck-types :id' do
        subject
        expect(id).to have_received(:to_s).with(no_args)
      end

      it 'releases the job using PBS' do
        subject
        expect(pbs).to have_received(:release_job).with(job_id)
      end

      context 'and raises PBS::UnkjobidError' do
        before { expect(pbs).to receive(:release_job).and_raise(PBS::UnkjobidError) }

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end
      end

      context 'and raises PBS::Error' do
        before { expect(pbs).to receive(:release_job).and_raise(PBS::Error) }

        it 'raises OodJob::Adapter::Error' do
          expect { subject }.to raise_error(OodJob::Adapter::Error)
        end
      end
    end
  end

  describe '#delete' do
    context 'when :id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.delete }.to raise_error(ArgumentError)
      end
    end

    context 'when :id is specified' do
      before { allow(PBS::Batch).to receive(:new) { pbs } }
      let(:job_id) { 'job id' }
      let(:id)  { double(to_s: job_id) }
      let(:pbs) { double(delete_job: nil) }
      subject { adapter.delete id: id }

      it 'duck-types :id' do
        subject
        expect(id).to have_received(:to_s).with(no_args)
      end

      it 'deletes the job using PBS' do
        subject
        expect(pbs).to have_received(:delete_job).with(job_id)
      end

      context 'and raises PBS::UnkjobidError' do
        before { expect(pbs).to receive(:delete_job).and_raise(PBS::UnkjobidError) }

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end
      end

      context 'and raises PBS::Error' do
        before { expect(pbs).to receive(:delete_job).and_raise(PBS::Error) }

        it 'raises OodJob::Adapter::Error' do
          expect { subject }.to raise_error(OodJob::Adapter::Error)
        end
      end
    end
  end
end
