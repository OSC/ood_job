require 'spec_helper'

describe OodJob::Info do
  attribs = %i(
    allocated_nodes cpu_time dispatch_time id job_owner native procs queue_name
    status submission_time submit_host wallclock_time
  )

  # fixture
  let(:orig_args)  {
    {
      allocated_nodes: [ OodJob::NodeInfo.new(name: 'n1', procs: 12), OodJob::NodeInfo.new(name: 'n2', procs: 6) ],
      cpu_time: 9999,
      dispatch_time: Time.at(55555),
      id: '1234.server',
      job_owner: 'bob',
      native: nil,
      procs: 18,
      queue_name: 'queue123',
      status: OodJob::Status.new(state: :running),
      submission_time: Time.at(44444),
      submit_host: 'submt_host123',
      wallclock_time: 66666
    }
  }

  let(:args) {
    {
      allocated_nodes: [ double(to_h: orig_args[:allocated_nodes][0].to_h), double(to_h: orig_args[:allocated_nodes][1].to_h) ],
      cpu_time: double(to_i: orig_args[:cpu_time].to_i),
      dispatch_time: double(to_i: orig_args[:dispatch_time].to_i),
      id: double(to_s: orig_args[:id].to_s),
      job_owner: double(to_s: orig_args[:job_owner].to_s),
      native: orig_args[:native],
      procs: double(to_i: orig_args[:procs].to_i),
      queue_name: double(to_s: orig_args[:queue_name].to_s),
      status: double(to_sym: orig_args[:status].to_sym),
      submission_time: double(to_i: orig_args[:submission_time].to_i),
      submit_host: double(to_s: orig_args[:submit_host].to_s),
      wallclock_time: double(to_i: orig_args[:wallclock_time].to_i)
    }
  }
  subject(:info) { OodJob::Info.new args }


  attribs.each do |attrib|
    it { is_expected.to respond_to(attrib).with(0).arguments }
    it { is_expected.not_to respond_to("#{attrib}=") }
  end
  it { is_expected.to respond_to(:to_h).with(0).arguments }

  it_behaves_like 'a value object' do
    let(:diff_args1) { orig_args.merge(cpu_time: 1000) }
    let(:diff_args2) { orig_args.merge(status: OodJob::Status.new(state: :queued)) }
    let(:same_info)  { OodJob::Info.new(orig_args) }
    let(:diff_info1) { OodJob::Info.new(diff_args1) }
    let(:diff_info2) { OodJob::Info.new(diff_args2) }
    let(:eq_obj)      { [ same_info, orig_args ] }
    let(:not_eq_obj)  { [ diff_info1, diff_args1, diff_info2, diff_args2 ] }
    let(:eql_obj)     { [ same_info ] }
    let(:not_eql_obj) { [ diff_info1, diff_args1, diff_info2, diff_args2, orig_args ] }
  end

  describe '.new' do
    context 'when valid args' do
      before { info }

      it { expect(args[:allocated_nodes][0]).to have_received(:to_h).with(no_args) }
      it { expect(args[:allocated_nodes][1]).to have_received(:to_h).with(no_args) }
      it { expect(args[:cpu_time]).to have_received(:to_i).with(no_args) }
      it { expect(args[:dispatch_time]).to have_received(:to_i).with(no_args) }
      it { expect(args[:id]).to have_received(:to_s).with(no_args) }
      it { expect(args[:job_owner]).to have_received(:to_s).with(no_args) }
      it { expect(args[:procs]).to have_received(:to_i).with(no_args) }
      it { expect(args[:queue_name]).to have_received(:to_s).with(no_args) }
      it { expect(args[:status]).to have_received(:to_sym).with(no_args) }
      it { expect(args[:submission_time]).to have_received(:to_i).with(no_args) }
      it { expect(args[:submit_host]).to have_received(:to_s).with(no_args) }
      it { expect(args[:wallclock_time]).to have_received(:to_i).with(no_args) }
    end

    context 'when id not defined' do
      let(:args) { super().reject { |k, v| k == :id } }

      it 'raises ArgumentError' do
        expect { info }.to raise_error(ArgumentError)
      end
    end

    context 'when status not defined' do
      let(:args) { super().reject { |k, v| k == :status } }

      it 'raises ArgumentError' do
        expect { info }.to raise_error(ArgumentError)
      end
    end

    context 'when extra arguments defined' do
      let(:args) { super().merge extra: 'extra' }

      it 'raises no error' do
        expect { info }.not_to raise_error
      end
    end
  end

  attribs.each do |attrib|
    describe "##{attrib}" do
      subject { super().send(attrib) }

      it { is_expected.to eq(orig_args[attrib]) }
    end
  end

  describe '#to_h' do
    subject { info.to_h }

    it { is_expected.to eq(orig_args) }
  end
end
