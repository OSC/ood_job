require 'spec_helper'

describe OodJob::NodeRequest do
  attribs = %i(
    procs properties
  )

  # fixture
  let(:orig_args)  {
    {
      procs: 123,
      properties: [ 'prop1', 'prop2' ]
    }
  }

  let(:args) {
    {
      procs: double(to_i: orig_args[:procs].to_i),
      properties: [ double(to_s: orig_args[:properties][0]), double(to_s: orig_args[:properties][1]) ]
    }
  }
  subject(:node) { OodJob::NodeRequest.new args }

  attribs.each do |attrib|
    it { is_expected.to respond_to(attrib).with(0).arguments }
    it { is_expected.not_to respond_to("#{attrib}=") }
  end
  it { is_expected.to respond_to(:to_h).with(0).arguments }

  it_behaves_like 'a value object' do
    let(:diff_args1) { { procs: 123, properties: ['prop2', 'prop1'] } }
    let(:diff_args2) { { procs: 321, properties: ['prop1', 'prop2'] } }
    let(:same_node)  { OodJob::NodeRequest.new(orig_args) }
    let(:diff_node1) { OodJob::NodeRequest.new(diff_args1) }
    let(:diff_node2) { OodJob::NodeRequest.new(diff_args2) }
    let(:eq_obj)      { [ same_node, orig_args ] }
    let(:not_eq_obj)  { [ diff_node1, diff_node2, diff_args1, diff_args2 ] }
    let(:eql_obj)     { [ same_node ] }
    let(:not_eql_obj) { [ diff_node1, diff_node2, diff_args1, diff_args2, orig_args ] }
  end

  describe '.new' do
    context 'when valid args' do
      before { node }

      it { expect(args[:procs]).to have_received(:to_i).with(no_args) }

      context 'and properties is single object' do
        let(:prop) { double(to_s: 'prop') }
        let(:args) { super().merge properties: prop }

        it { expect(prop).to have_received(:to_s).with(no_args) }
      end

      context 'and properties is array' do
        it { expect(args[:properties][0]).to have_received(:to_s).with(no_args) }
        it { expect(args[:properties][1]).to have_received(:to_s).with(no_args) }
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

  describe '#properties' do
    subject { node.properties }

    context 'when single object' do
      let(:args) { super().merge properties: 'prop' }

      it { is_expected.to eq(['prop']) }
    end

    context 'when array of objects' do
      let(:args) { super().merge properties: ['propA', 'propB'] }

      it { is_expected.to eq(['propA', 'propB']) }
    end
  end

  describe '#to_h' do
    subject { node.to_h }

    it { is_expected.to eq(orig_args) }
  end
end
