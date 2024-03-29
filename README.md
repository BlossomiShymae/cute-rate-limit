# cute-rate-limit

A cute rate limiter in Crystal that implements token bucket algorithm. Uses
`sleep` blocking strategy when limit is exceeded.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cute-rate-limit:
       github: BlossomiShymae/cute-rate-limit
   ```

2. Run `shards install`

## Usage

```crystal
require "cute-rate-limit"
```

A limiter uses a token bucket based algorithm that defaults to blocking
strategy `sleep` when limit is exceeded.

In an example web API context, the limit is 20 requests every 1 second. It would
be very, very bad if we ignore this limit. :c

Rate limiters solve this problem. Using a limiter with a full bucket, the 
maximum burst is 20 requests before limiter blocks with `sleep`. Tokens are 
allocated every `1 / token_rate` period, where `token_rate = bucket_size / bucket_period`
per second.

To create a limiter with a `bucket_size` of 20 tokens and a `bucket_period`
of 1000 milliseconds:

```crystal
cute_limiter = CuteRateLimit::Limiter.new 20 1*1000
```

For verbose readability:

```crystal
cute_limiter = CuteRateLimit::Limiter.new 20 1.second.total_milliseconds.to_i
```

To use a limiter:

```crystal
cute_limiter.use # => 19
```

Multiple limiters can be used together in tandem:

```crystal
cute_limiter1 = CuteRateLimit::Limiter.new 20 1*1000
cute_limiter2 = CuteRateLimit::Limiter.new 100 120*1000

cute_limiter1.use
cute_limiter2.use
 ```

Check the bucket of a limiter with `#token_bucket`
```crystal
cute_limiter2.token_bucket # => 100

50.times do
   cute_limiter2.use
end

cute_limiter2.token_bucket # => 50
```

## Contributing

1. Fork it (<https://github.com/BlossomiShymae/cute-rate-limit/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [BlossomiShymae](https://github.com/BlossomiShymae) - creator and maintainer
