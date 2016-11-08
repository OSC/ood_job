require 'spec_helper'

describe OodJob::Adapter do
  attribs = %i(
    cluster
  )

  # fixture
  let(:orig_args) {
    {
      cluster: "my cluster"
    }
  }

  let(:args) {
    {
      cluster: orig_args[:cluster]
    }
  }
  subject(:adapter) { OodJob::Adapter.new args }


  attribs.each do |attrib|
    it { is_expected.to respond_to(attrib).with(0).arguments }
    it { is_expected.not_to respond_to("#{attrib}=") }
  end
  it { is_expected.to respond_to(:submit).with(0).arguments.and_keywords(:script, :after, :afterok, :afternotok, :afterany) }
  it { is_expected.to respond_to(:info).with(0).arguments.and_keywords(:id) }
  it { is_expected.to respond_to(:status).with(0).arguments.and_keywords(:id) }
  it { is_expected.to respond_to(:hold).with(0).arguments.and_keywords(:id) }
  it { is_expected.to respond_to(:release).with(0).arguments.and_keywords(:id) }
  it { is_expected.to respond_to(:delete).with(0).arguments.and_keywords(:id) }

  describe '.new' do
    context 'when cluster not defined' do
      let(:args) { super().reject { |k, v| k == :cluster } }

      it 'raises ArgumentError' do
        expect { adapter }.to raise_error(ArgumentError)
      end
    end

    context 'when extra arguments defined' do
      let(:args) { super().merge extra: 'extra' }

      it 'raises no error' do
        expect { adapter }.not_to raise_error
      end
    end
  end

  attribs.each do |attrib|
    describe "##{attrib}" do
      subject { super().send(attrib) }

      it { is_expected.to eq(orig_args[attrib]) }
    end
  end

  describe '#submit' do
    context 'when script not defined' do
      it 'raises ArgumentError' do
        expect { adapter.submit }.to raise_error(ArgumentError)
      end
    end

    context 'when valid arguments' do
      it 'raises NotImplementedError' do
        expect { adapter.submit script: 'script' }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#info' do
    it 'raises NotImplementedError' do
      expect { adapter.info }.to raise_error(NotImplementedError)
    end
  end

  describe '#status' do
    context 'when id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.status }.to raise_error(ArgumentError)
      end
    end

    context 'when valid arguments' do
      it 'raises NotImplementedError' do
        expect { adapter.status id: 'id' }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#hold' do
    context 'when id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.hold }.to raise_error(ArgumentError)
      end
    end

    context 'when valid arguments' do
      it 'raises NotImplementedError' do
        expect { adapter.hold id: 'id' }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#release' do
    context 'when id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.release }.to raise_error(ArgumentError)
      end
    end

    context 'when valid arguments' do
      it 'raises NotImplementedError' do
        expect { adapter.release id: 'id' }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#delete' do
    context 'when id not defined' do
      it 'raises ArgumentError' do
        expect { adapter.delete }.to raise_error(ArgumentError)
      end
    end

    context 'when valid arguments' do
      it 'raises NotImplementedError' do
        expect { adapter.delete id: 'id' }.to raise_error(NotImplementedError)
      end
    end
  end
end
