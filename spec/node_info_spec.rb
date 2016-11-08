require 'spec_helper'

describe OodJob::NodeInfo do
  attribs = %i(
    name procs
  )

  # fixtures
  let(:orig_args) {
    {
      name: 'node_name',
      procs: 123
    }
  }

  let(:args) {
    {
      name: double(to_s: orig_args[:name].to_s),
      procs: double(to_i: orig_args[:procs].to_i)
    }
  }
  subject(:node) { OodJob::NodeInfo.new args }

  attribs.each do |attrib|
    it { is_expected.to respond_to(attrib).with(0).arguments }
    it { is_expected.not_to respond_to("#{attrib}=") }
  end
  it { is_expected.to respond_to(:to_h).with(0).arguments }

  it_behaves_like 'a value object' do
    let(:diff_args) { { name: 'bad', procs: 321 } }
    let(:same_node) { OodJob::NodeInfo.new(orig_args) }
    let(:diff_node) { OodJob::NodeInfo.new(diff_args) }
    let(:eq_obj)      { [ same_node, orig_args ] }
    let(:not_eq_obj)  { [ diff_node, diff_args ] }
    let(:eql_obj)     { [ same_node ] }
    let(:not_eql_obj) { [ diff_node, diff_args, orig_args ] }
  end

  describe '.new' do
    context 'when valid args' do
      before { node }

      it { expect(args[:name]).to have_received(:to_s).with(no_args) }
      it { expect(args[:procs]).to have_received(:to_i).with(no_args) }
    end

    context 'when :name not defined' do
      let(:args) { super().reject { |k, v| k == :name } }

      it 'raises ArgumentError' do
        expect { node }.to raise_error(ArgumentError)
      end
    end

    context 'when :procs not defined' do
      let(:args) { super().reject { |k, v| k == :procs } }

      it 'raises ArgumentError' do
        expect { node }.to raise_error(ArgumentError)
      end
    end

    context 'when extra arguments defined' do
      let(:args) { super().merge extra: 'extra' }

      it 'raises no error' do
        expect { node }.not_to raise_error
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
    subject { node.to_h }

    it { is_expected.to eq(orig_args) }
  end
end
