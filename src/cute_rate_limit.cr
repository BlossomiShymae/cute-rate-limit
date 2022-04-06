# `CuteRateLimit` module that contains rate limiting tools such as `Limiter`.
module CuteRateLimit
  VERSION = "0.1.0"

  extend self

  # A limiter uses a token bucket based algorithm that defaults to blocking
  # strategy `sleep` when limit is exceeded.
  #
  # To create a limiter with a *bucket_size* of 20 tokens and a *bucket_period*
  # of 1000 milliseconds:
  #
  # ```
  # cute_limiter = CuteRateLimit::Limiter.new 20 1*1000
  # ```
  #
  # For verbose readability:
  #
  # ```
  # cute_limiter = CuteRateLimit::Limiter.new 20 1.second.total_milliseconds.to_i
  # ```
  #
  # To use a limiter:
  #
  # ```
  # cute_limiter.use
  # ```
  #
  # Multiple limiters can be used together in tandem:
  #
  # ```
  # cute_limiter1 = CuteRateLimit::Limiter.new 20 1*1000
  # cute_limiter2 = CuteRateLimit::Limiter.new 100 120*1000
  #
  # cute_limiter1.use
  # cute_limiter2.use
  # ```
  #
  # Check the bucket of limiter with `#token_bucket`
  class Limiter
    @@id : Int64 = 0
    # Returns the number of tokens in bucket this limiter has
    #
    # ```
    # cute_limiter.token_bucket # => *token_bucket*
    # ```
    getter token_bucket : Int64
    @token_rate : Int64 | Float64
    @bucket_period : Int64 | Float64
    @bucket_size : Int64
    @last_recent_timestamp : Time::Span
    @id : Int64

    # Prints the current instance information of Limiter
    #
    # ```
    # cute_limiter.to_s # => <Limiter 0 of @bucket_size=20, @bucket_period=1000, @token_bucket=20>
    # ```
    def to_s(io : IO)
      io << "<Limiter #{@id} of @bucket_size=#{@bucket_size}, @bucket_period=#{@bucket_period}, @token_bucket=#{@token_bucket}>"
    end

    # Creates a limiter with *bucket_size* and *bucket_period*.
    #
    # NOTE: The units of milliseconds are used for *bucket_period* when creating
    # a limiter.
    def initialize(bucket_size : Int64, bucket_period : Int64)
      @bucket_period = bucket_period / 1000
      @token_bucket = @bucket_size = bucket_size
      @token_rate = @bucket_size / @bucket_period
      @last_recent_timestamp = Time.monotonic
      @id = @@id
      @@id += 1
    end

    # Calls #fill_token_bucket and tries to take away a token.
    # #use will `sleep` until *token_bucket* is allocated a token to take
    # from.
    #
    # Returns the number of tokens in bucket this limiter has
    #
    # ```
    # cute_limiter.use # => *token_bucket*
    # ```
    def use
      fill_token_bucket

      if @token_bucket == 0
        sleep (1 / @token_rate).seconds
        fill_token_bucket
        @token_bucket -= 1
      end

      if @token_bucket > 0
        @token_bucket -= 1
      end

      @token_bucket
    end

    # Fills token bucket based on elapsed time from stored timestamp.
    #
    # Truncates excess tokens that surpass the given *bucket_size*.
    private def fill_token_bucket
      elapsed = Time.monotonic - @last_recent_timestamp
      @token_bucket += (@token_rate * elapsed.total_seconds).round(0).to_i
      @last_recent_timestamp = Time.monotonic

      if @token_bucket > @bucket_size
        @token_bucket = @bucket_size
      end
    end
  end
end
