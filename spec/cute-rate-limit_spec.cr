require "./spec_helper"

describe CuteRateLimit do
  describe CuteRateLimit::Limiter do
    describe ".use" do
      it "correctly rate limits given constraints" do
        bucket_size = 20
        bucket_period = 1 * 1000
        limiter = CuteRateLimit::Limiter.new(bucket_size, bucket_period)
        timestamp = Time.monotonic

        (bucket_size * 2).times do
          limiter.use
        end

        elapsed = Time.monotonic - timestamp
        elapsed.total_milliseconds.should be >= bucket_period
      end

      it "handles nested rate limits" do
        bucket_size1 = 4
        bucket_period1 = 1 * 1000
        bucket_size2 = 5
        bucket_period2 = 6 * 1000
        limiter1 = CuteRateLimit::Limiter.new(bucket_size1, bucket_period1)
        limiter2 = CuteRateLimit::Limiter.new(bucket_size2, bucket_period2)
        timestamp = Time.monotonic

        (bucket_size2 * 2).times do
          limiter1.use
          limiter2.use
        end

        elapsed = Time.monotonic - timestamp
        elapsed.total_milliseconds.should be >= ((bucket_period1 / bucket_period2) + bucket_period2)
      end
    end
  end
end
