require 'spec_helper'

describe OodJob::Script do
  attribs = %i(
    accounting_id args content email email_on_started email_on_terminated
    error_path input_path job_environment job_name join_files min_phys_memory
    min_procs native nodes output_path priority queue_name rerunnable
    reservation_id start_time submit_as_hold wall_time workdir
  )

  # fixture
  let(:orig_args)  {
    {
      accounting_id: 'account123',
      args: [ 'arg1', 'arg2' ],
      content: 'my script text',
      email: [ 'email1', 'email2' ],
      email_on_started: true,
      email_on_terminated: false,
      error_path: Pathname.new("/path/to/error"),
      input_path: Pathname.new("/path/to/input"),
      job_environment: { 'ENV1' => 'env1' },
      job_name: 'my_job',
      join_files: true,
      min_phys_memory: 123,
      min_procs: 1000,
      native: nil,
      nodes: [ "node1", OodJob::NodeRequest.new(procs: 100) ],
      output_path: Pathname.new("/path/to/output"),
      priority: 2,
      queue_name: 'queue123',
      rerunnable: false,
      reservation_id: 'rsv123',
      start_time: Time.at(22222),
      submit_as_hold: false,
      wall_time: 44444,
      workdir: Pathname.new("/path/to/workdir")
    }
  }

  let(:args) {
    {
      accounting_id: double(to_s: orig_args[:accounting_id].to_s),
      args: [ double(to_s: orig_args[:args][0].to_s), double(to_s: orig_args[:args][1].to_s) ],
      content: double(to_s: orig_args[:content].to_s),
      email: [ double(to_s: orig_args[:email][0].to_s), double(to_s: orig_args[:email][1].to_s) ],
      email_on_started: orig_args[:email_on_started],
      email_on_terminated: orig_args[:email_on_terminated],
      error_path: double(to_s: orig_args[:error_path].to_s),
      input_path: double(to_s: orig_args[:input_path].to_s),
      job_environment: { double(to_s: orig_args[:job_environment].first[0].to_s) => double(to_s: orig_args[:job_environment].first[1].to_s) },
      job_name: double(to_s: orig_args[:job_name].to_s),
      join_files: orig_args[:join_files],
      min_phys_memory: double(to_i: orig_args[:min_phys_memory].to_i),
      min_procs: double(to_i: orig_args[:min_procs].to_i),
      native: orig_args[:native],
      nodes: [ double(to_s: orig_args[:nodes][0].to_s), double(to_h: orig_args[:nodes][1].to_h) ],
      output_path: double(to_s: orig_args[:output_path].to_s),
      priority: double(to_i: orig_args[:priority].to_i),
      queue_name: double(to_s: orig_args[:queue_name].to_s),
      rerunnable: orig_args[:rerunnable],
      reservation_id: double(to_s: orig_args[:reservation_id].to_s),
      start_time: double(to_i: orig_args[:start_time].to_i),
      submit_as_hold: orig_args[:submit_as_hold],
      wall_time: double(to_i: orig_args[:wall_time].to_i),
      workdir: double(to_s: orig_args[:workdir].to_s)
    }
  }
  subject(:script) { OodJob::Script.new args }

  attribs.each do |attrib|
    it { is_expected.to respond_to(attrib).with(0).arguments }
    it { is_expected.not_to respond_to("#{attrib}=") }
  end
  it { is_expected.to respond_to(:to_h).with(0).arguments }

  it_behaves_like 'a value object' do
    let(:diff_args1) { orig_args.merge(rerunnable: true) }
    let(:diff_args2) { orig_args.merge(output_path: "/path/to/output2") }
    let(:same_script)  { OodJob::Script.new(orig_args) }
    let(:diff_script1) { OodJob::Script.new(diff_args1) }
    let(:diff_script2) { OodJob::Script.new(diff_args2) }
    let(:eq_obj)      { [ same_script, orig_args ] }
    let(:not_eq_obj)  { [ diff_script1, diff_args1, diff_script2, diff_args2 ] }
    let(:eql_obj)     { [ same_script ] }
    let(:not_eql_obj) { [ diff_script1, diff_args1, diff_script2, diff_args2, orig_args ] }
  end

  describe '.new' do
    context 'when valid args' do
      before { script }

      it { expect(args[:accounting_id]).to have_received(:to_s).with(no_args) }
      it { expect(args[:args][0]).to have_received(:to_s).with(no_args) }
      it { expect(args[:args][1]).to have_received(:to_s).with(no_args) }
      it { expect(args[:error_path]).to have_received(:to_s).with(no_args) }
      it { expect(args[:input_path]).to have_received(:to_s).with(no_args) }
      it { expect(args[:job_environment].first[0]).to have_received(:to_s).with(no_args) }
      it { expect(args[:job_environment].first[1]).to have_received(:to_s).with(no_args) }
      it { expect(args[:job_name]).to have_received(:to_s).with(no_args) }
      it { expect(args[:min_phys_memory]).to have_received(:to_i).with(no_args) }
      it { expect(args[:min_procs]).to have_received(:to_i).with(no_args) }
      it { expect(args[:output_path]).to have_received(:to_s).with(no_args) }
      it { expect(args[:priority]).to have_received(:to_i).with(no_args) }
      it { expect(args[:queue_name]).to have_received(:to_s).with(no_args) }
      it { expect(args[:reservation_id]).to have_received(:to_s).with(no_args) }
      it { expect(args[:start_time]).to have_received(:to_i).with(no_args) }
      it { expect(args[:wall_time]).to have_received(:to_i).with(no_args) }
      it { expect(args[:workdir]).to have_received(:to_s).with(no_args) }

      context 'and :email is single object' do
        let(:email) { double(to_s: 'email') }
        let(:args) { super().merge email: email }

        it { expect(email).to have_received(:to_s).with(no_args) }
      end

      context 'and :email is array' do
        it { expect(args[:email][0]).to have_received(:to_s).with(no_args) }
        it { expect(args[:email][1]).to have_received(:to_s).with(no_args) }
      end

      context 'and :content responds to #to_s' do
        it { expect(args[:content]).to have_received(:to_s).with(no_args) }
      end

      context 'and :nodes is a single object that responds to #to_s' do
        let(:node) { double(to_s: 'node1') }
        let(:args) { super().merge nodes: node }

        it { expect(node).to have_received(:to_s).with(no_args) }
      end

      context 'and :nodes is a single object that responds to #to_h' do
        let(:node) { double(to_h: {procs: 200, properties: ['test1', 'test2']}) }
        let(:args) { super().merge nodes: node }

        it { expect(node).to have_received(:to_h).with(no_args) }
      end

      context 'and :nodes is an array of objects' do
        it { expect(args[:nodes][0]).to have_received(:to_s).with(no_args) }
        it { expect(args[:nodes][1]).to have_received(:to_h).with(no_args) }
      end
    end

    context 'when :content not defined' do
      let(:args) { super().reject { |k, v| k == :content } }

      it 'raises ArgumentError' do
        expect { script }.to raise_error(ArgumentError)
      end
    end

    context 'when extra arguments defined' do
      let(:args) { super().merge extra: 'extra' }

      it 'raises no error' do
        expect { script }.not_to raise_error
      end
    end
  end

  attribs.each do |attrib|
    describe "##{attrib}" do
      subject { super().send(attrib) }

      it { is_expected.to eq(orig_args[attrib]) }
    end
  end

  describe '#email' do
    subject { script.email }

    context 'when single object' do
      let(:args) { super().merge email: 'email' }

      it { is_expected.to eq(['email']) }
    end

    context 'when array of objects' do
      let(:args) { super().merge email: ['email1', 'email2'] }

      it { is_expected.to eq(['email1', 'email2']) }
    end
  end

  describe '#content' do
    subject { script.content }

    context 'when responds to #to_s' do
      let(:args) { super().merge content: 'test 123' }

      it { is_expected.to eq('test 123') }
    end
  end

  describe '#nodes' do
    subject { script.nodes }

    context 'when it is a single object that responds to #to_s' do
      let(:args) { super().merge nodes: 'node1' }

      it { is_expected.to eq(['node1']) }
    end

    context 'when it is a single object that responds to #to_h' do
      let(:args) { super().merge nodes: {procs: 1, properties: ['prop1']} }

      it { is_expected.to eq([OodJob::NodeRequest.new(procs: 1, properties: ['prop1'])]) }
    end

    context 'when it is an array of objects' do
      let(:args) { super().merge nodes: ['node1', {procs: 1, properties: ['prop1']}] }

      it { is_expected.to eq(['node1', OodJob::NodeRequest.new(procs: 1, properties: ['prop1'])]) }
    end
  end

  describe '#to_h' do
    subject { script.to_h }

    it { is_expected.to eq(orig_args) }
  end
end
