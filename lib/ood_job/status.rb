module OodJob
  # An object that describes the current state of a submitted job
  class Status
    # Possible states a submitted job can be in:
    #   # Job status cannot be determined
    #   :undetermined
    #
    #   # Job is queued for being scheduled and executed
    #   :queued
    #
    #   # Job has been placed on hold by the system, the administrator, or
    #   # submitting user
    #   :queued_held
    #
    #   # Job is running on an execution host
    #   :running
    #
    #   # Job has been suspended by the user, the system, or the administrator
    #   :suspended
    #
    #   # Job was re-queued by the resource manager and is eligible to run
    #   :requeued
    #
    #   # Job was re-queued by the resource manager and is currently placed on
    #   # hold by the system, the administrator, or the submitting user
    #   :requeued_held
    STATES = %i(
      undetermined
      queued
      queued_held
      running
      suspended
      requeued
      requeued_held
    )

    # The root exception class that all {Status} exceptions inherit from
    class Error < StandardError; end

    # The exception raised when attempting to set an invalid state
    class InvalidState < Error; end

    # Current status of submitted job
    # @return [Symbol] status of job
    attr_reader :state

    # @param state [#to_sym] status of job
    def initialize(state:, **_)
      @state = state.to_sym
      raise InvalidState, "this is not a valid state: #{@state}" unless STATES.include?(@state)
    end

    # @!method undetermined?
    #   Whether the status is undetermined
    #   @return [Boolean] whether undetermined
    #
    # @!method queued?
    #   Whether the status is queued
    #   @return [Boolean] whether queued
    #
    # @!method queued_held?
    #   Whether the status is queued_held
    #   @return [Boolean] whether queued_held
    #
    # @!method running?
    #   Whether the status is running
    #   @return [Boolean] whether running
    #
    # @!method suspended?
    #   Whether the status is suspended
    #   @return [Boolean] whether suspended
    #
    # @!method requeued?
    #   Whether the status is requeued
    #   @return [Boolean] whether requeued
    #
    # @!method requeued_held?
    #   Whether the status is requeued_held
    #   @return [Boolean] whether requeued_held
    STATES.each do |method|
      define_method "#{method}?" do
        state == method
      end
    end

    # Convert object to symbol
    # @return [Symbol] object as symbol
    def to_sym
      state
    end

    # The comparison operator
    # @param other [#to_sym] object to compare against
    # @return [Boolean] whether objects are equivalent
    def ==(other)
      to_sym == other.to_sym
    end

    # Whether objects are identical to each other
    # @param other [#to_sym] object to compare against
    # @return [Boolean] whether objects are identical
    def eql?(other)
      self.class == other.class && self == other
    end

    # Generate a hash value for this object
    # @return [Fixnum] hash value of object
    def hash
      [self.class, to_sym].hash
    end
  end
end
