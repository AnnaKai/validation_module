require "ostruct"
require_relative '../validation.rb'

RSpec.describe Validation do
  describe '#valid?' do
    context 'no validation rules' do
      class DefaultValidation
        include Validation
      end

      it 'returns true by default' do
        expect(DefaultValidation.new.valid?).to be true
      end
    end

    context 'when validating presence' do
      context 'presence is false' do
        class PresenceFalseValidation < OpenStruct
          include Validation

          validate :last_name, presence: true
          validate :first_name, presence: false
        end

        subject do
          PresenceFalseValidation.new
        end

        it 'returns true' do
          subject.last_name = 'Potter'
          expect(subject.valid?).to be true
        end
      end

      context 'presence is true' do
        class PresenceTrueValidation < OpenStruct
          include Validation

          validate :first_name, presence: true
          validate :last_name, presence: true
        end

        subject do
          PresenceTrueValidation.new
        end

        it 'is invalid if a required value is nil' do
          subject.first_name = nil
          expect(subject.valid?).to be false
        end

        it 'is invalid if a required value is empty string' do
          subject.first_name = ''
          expect(subject.valid?).to be false
        end

        it 'is valid if a required value is present' do
          subject.first_name = 'Harry'
          subject.last_name = 'Potter'

          expect(subject.valid?).to be true
        end

        it 'is invalid when value is not present' do
          subject.first_name = 'Harry'
          subject.last_name = ''

          expect(subject.valid?).to be false
        end
      end
    end

    context 'when validating format' do
      class FormatValidation < OpenStruct
        include Validation
        validate :number, format: /\A\d*\z/
      end

      subject do
        FormatValidation.new
      end

      it 'is valid when matches format' do
        subject.number = '555'
        expect(subject.valid?).to be true
      end

      it 'is invalid when does not match format' do
        subject.number = 'aaa'
        expect(subject.valid?).to be false
      end
    end

    context 'when validating type' do
      class TypeValidation < OpenStruct
        include Validation
        validate :age, type: Integer
      end

      subject do
        TypeValidation.new
      end

      it 'is valid when matches class type' do
        subject.age = 40
        expect(subject).to be_valid
      end

      it 'is invalid when does not match class type' do
        subject.age = 'Harry'
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#validate!' do
    class DummyValidation < OpenStruct
      include Validation

      validate :first_name, presence: true
      validate :number, format: /\A\d*\z/
      validate :age, type: Integer
    end

    subject do
      DummyValidation.new
    end

    it 'raises a presence error with a message if validation does not pass' do
      subject.first_name = nil
      expect { subject.validate! }.to raise_error('first_name failed presence validation')
    end

    it 'raises a format error with a message if validation does not pass' do
      subject.first_name = 'Harry'
      subject.number = 'string'
      expect { subject.validate! }.to raise_error('number failed format validation')
    end

    it 'raises a type error with a message if validation does not pass' do
      subject.first_name = 'Harry'
      subject.number = '9'
      subject.age = 'string'
      expect { subject.validate! }.to raise_error('age failed type validation')
    end

    it 'does not raise an error' do
      subject.first_name = 'Harry'
      subject.number = '9'
      subject.age = 20
      expect { subject.validate! }.not_to raise_error
    end
  end
end
