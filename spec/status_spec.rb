require 'spec_helper'

describe OodJob::Status do
  attribs = %i(
    state
  )

  states = %i(
    queued queued_held requeued requeued_held running suspended undetermined
  )

  # fixture
  let(:orig_args) {
    {
      state: :running
    }
  }

  let(:args) {
    {
      state: double(to_sym: orig_args[:state].to_sym)
    }
  }
  subject(:status) { OodJob::Status.new args }

  attribs.each do |attrib|
    it { is_expected.to respond_to(attrib).with(0).arguments }
    it { is_expected.not_to respond_to("#{attrib}=") }
  end
  states.each do |state|
    it { is_expected.to respond_to("#{state}?").with(0).arguments }
  end
  it { is_expected.to respond_to(:to_sym).with(0).arguments }

  it_behaves_like 'a value object' do
    let(:diff_args)  { { state: :queued } }
    let(:same_status) { OodJob::Status.new(orig_args) }
    let(:diff_status) { OodJob::Status.new(diff_args) }
    let(:eq_obj)      { [ same_status, orig_args[:state] ] }
    let(:not_eq_obj)  { [ diff_status, diff_args[:state] ] }
    let(:eql_obj)     { [ same_status ] }
    let(:not_eql_obj) { [ diff_status, diff_args[:state], orig_args[:state] ] }
  end

  describe '.new' do
    context 'when valid args' do
      before { status }

      it { expect(args[:state]).to have_received(:to_sym).with(no_args) }
    end

    context 'when :state not defined' do
      let(:args) { super().reject { |k, v| k == :state } }

      it 'raises ArgumentError' do
        expect { status }.to raise_error(ArgumentError)
      end
    end

    context 'when :state is invalid' do
      let(:args) { super().merge state: :invalid_state }

      it 'raises OodJob::Status::InvalidState' do
        expect { status }.to raise_error(OodJob::Status::InvalidState)
      end
    end

    context 'when extra arguments defined' do
      let(:args) { super().merge extra: 'extra' }

      it 'raises no error' do
        expect { status }.not_to raise_error
      end
    end
  end

  attribs.each do |attrib|
    describe "##{attrib}" do
      subject { super().send(attrib) }

      it { is_expected.to eq(orig_args[attrib]) }
    end
  end

  states.each do |state|
    describe "##{state}?" do
      subject { super().send("#{state}?") }

      context "when #{state}" do
        let(:args) { super().merge state: state }

        it { is_expected.to be }
      end

      context "when not #{state}" do
        let(:args) { super().merge state: states.select {|s| s != state }.first }

        it { is_expected.not_to be }
      end
    end
  end

  describe '#to_sym' do
    subject { status.to_sym }

    it { is_expected.to eq(orig_args[:state]) }
  end
end
