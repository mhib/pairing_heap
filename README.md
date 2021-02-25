# PairingHeap

PairingHeap is a pure Ruby priority queue implementation using a pairing heap as the underlying data structure. While a pairing heap is asymptotically less efficient than the Fibonacci heap, it is usually faster in practice. This makes it a popular choice for Prim's MST or Dijkstra's algorithm implementations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pairing_heap'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pairing_heap


## Documentation
https://rubydoc.info/gems/pairing_heap

## Usage
```ruby
require 'pairing_heap'

# Min priority queue
best_defenses = PairingHeap::MinPriorityQueue.new
best_defenses.push('Chelsea', 24)
best_defenses.push('City', 30)
best_defenses.push('Tottenham', 25)
best_defenses.any? # => true
best_defenses.size # => 3
best_defenses.decrease_key('City', 15)
best_defenses.min # => 'City'
best_defenses.pop # => 'City'
best_defenses.extract_min # => 'Chelsea'
best_defenses.extract_min # => 'Tottenham'
best_defenses.any? # => false

# Max priority queue
best_teams = PairingHeap::MaxPriorityQueue.new
best_teams.push('City', 56)
best_teams.push('United', 46)
best_teams.push('Leicester', 46)
best_teams.increase_key('Leicester', 47)
best_teams.max # => 'City'
best_teams.pop # => 'City'
best_teams.extract_max # => 'Leicester'

# Custom comparator(it defaults to :<=.to_proc)
compare_by_length = PairingHeap::PairingHeap.new { |l, r| l.length <= r.length }
compare_by_length.push(:a, '11')
compare_by_length.push(:b, '1')
compare_by_length.push(:c, '11')
compare_by_length.change_priority(:c, '')
compare_by_length.peek # => :c
compare_by_length.pop # => :c
compare_by_length.pop # => :b
compare_by_length.pop # => :a

# SafeChangePriortyQueue
queue = PairingHeap::SafeChangePriorityQueue.new
queue.push(:a, 1)
queue.push(:b, 2)
queue.change_priority(:a, 3) # This works and does not throw an exception
queue.peek # => :b
```
See also [test/performance_dijkstra.rb](./test/performance_dijkstra.rb) for a Dijkstra algorithm implementation.
### Changes from lazy_priority_queue
This API is a drop-in replacement of [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue) with the following differences:

* Custom comparator provided to constructur, compares weights, not internal nodes
* `change_priority` returns `self` instead of the first argument
* `enqueue` returns `self` instead of the first argument
* Queue classes are in the `PairingHeap` namespace, so `require 'pairing_heap` does not load `MinPriorityQueue` to the global scope
* `top_condidition` constructor argument is removed

## Time Complexity
| Operation       | Time complexity | Amortized time complexity |
| --------------- | --------------- | ------------------------- |
| enqueue         | O(1)            | O(1)                      |
| peek            | O(1)            | O(1)                      |
| change_priority | O(1)            | o(log n)                  |
| dequeue         | O(n)            | O(log n)                  |
| delete          | O(n)            | O(log n)                  |

## Benchmarks
I picked the two fastest pure Ruby priority queue implementations I was aware of for the comparison:

* [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue) that uses a lazy binomial heap. This is probably the most popular option, used for example in [RGL](https://github.com/monora/rgl/)
* Pure Ruby implementation of Fibonacci Heap from [priority-queue](https://github.com/supertinou/priority-queue) ([link to source](https://github.com/supertinou/priority-queue/blob/master/lib/priority_queue/ruby_priority_queue.rb))

All tests except for the third one were executed by [benchmark-ips](https://github.com/evanphx/benchmark-ips) with parameters `time = 180` and `warmup = 30`, on an `Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz`.
### Stress test without changing priority test(N = 1000) [source code](./test/performance.rb)
Original performance test from [lazy_priority_queue](https://github.com/matiasbattocchia/lazy_priority_queue)
> A stress test of 1,000,000 operations: starting with 1,000 pushes/0 pops, following 999 pushes/1 pop, and so on till 0 pushes/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin20]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>14</td>
    <td>60.564595</td>
    <td>0.231</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>8</td>
    <td>62.489819</td>
    <td>0.128(1.81x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>68.719194</td>
    <td>0.116(1.99x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.2.14.0 (2.5.7) 2020-12-08 ebe64bafb9 OpenJDK 64-Bit Server VM 15.0.2+7 on 15.0.2+7 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>17</td>
    <td>61.195794</td>
    <td>0.278</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>14</td>
    <td>64.375927</td>
    <td>0.218(1.28x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>9</td>
    <td>67.415358</td>
    <td>0.134(2.08x slower)</td>
  </tr>
</table>

### Stress test with changing priority(N = 1000) [source code](./test/performance_with_change_priority.rb)
A stress test of 2,000,000 operations: starting with 1,000 pushes/1000 change_priorities/0 pops, following 999 pushes/999 change_priorities/1 pop, and so on till 0 pushes/0 change_priorities/1000 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin20]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>13</td>
    <td>60.280165</td>
    <td>0.216</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>8</td>
    <td>67.414861s</td>
    <td>0.119(1.82x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>7</td>
    <td>61.067436</td>
    <td>0.115(1.88x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.2.14.0 (2.5.7) 2020-12-08 ebe64bafb9 OpenJDK 64-Bit Server VM 15.0.2+7 on 15.0.2+7 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>16</td>
    <td>62.519677</td>
    <td>0.256</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>13</td>
    <td>63.832733</td>
    <td>0.204(1.26x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>8</td>
    <td>60.250658</td>
    <td>0.133(1.93x slower)</td>
  </tr>
</table>

### Stress test with changing priority(N = 10) [source code](./test/performance_with_change_priority.rb)
A stress test of 200 operations: starting with 10 pushes/10 change_priorities/0 pops, following 9 pushes/9 change_priorities/1 pop, and so on till 0 pushes/0 change_priorities/10 pops.
<table>
  <tr>
    <th colspan="4">ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin20]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>5991.2</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>3803.5(1.58x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>3681.9(1.64x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.2.14.0 (2.5.7) 2020-12-08 ebe64bafb9 OpenJDK 64-Bit Server VM 15.0.2+7 on 15.0.2+7 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>6784.3</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>6044.5(1.12x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>4070.5(1.67x slower)</td>
  </tr>
</table>

### Dijkstra's algorithm with RGL [source code](./test/performance_rgl.rb)
<table>
  <tr>
    <th colspan="4">ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin20]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>7</td>
    <td>64.768526</td>
    <td>0.108</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>6</td>
    <td>63.278091</td>
    <td>0.095(1.14x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>6</td>
    <td>65.898081</td>
    <td>0.091(1.19x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.2.14.0 (2.5.7) 2020-12-08 ebe64bafb9 OpenJDK 64-Bit Server VM 15.0.2+7 on 15.0.2+7 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>12</td>
    <td>60.277567</td>
    <td>0.199</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>12</td>
    <td>61.238395</td>
    <td>0.196(1.02x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10</td>
    <td>62.687378</td>
    <td>0.160(1.25x slower)</td>
  </tr>
</table>

### Simple Dijkstra's algorithm implementation [source code](./test/performance_dijkstra.rb)
<table>
  <tr>
    <th colspan="4">ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin20]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>20</td>
    <td>60.028380</td>
    <td>0.334</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10</td>
    <td>64.471303</td>
    <td>0.155(2.14x slower)</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>9</td>
    <td>65.986618</td>
    <td>0.136(2.45x slower)</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.2.14.0 (2.5.7) 2020-12-08 ebe64bafb9 OpenJDK 64-Bit Server VM 15.0.2+7 on 15.0.2+7 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Iterations</th>
    <th>Seconds</th>
    <th>Iterations per second</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>21</td>
    <td>61.727259</td>
    <td>0.340</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>14</td>
    <td>63.436863</td>
    <td>0.221(1.54x slower)</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>10</td>
    <td>62.447662</td>
    <td>0.160(2.12x slower)</td>
  </tr>
</table>

### Summary
<table>
  <tr>
    <th colspan="4">ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin20]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1</td>
  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.720x slower</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.721x slower</td>
  </tr>
  <tr>
    <th colspan="4">jruby 9.2.14.0 (2.5.7) 2020-12-08 ebe64bafb9 OpenJDK 64-Bit Server VM 15.0.2+7 on 15.0.2+7 +jit [darwin-x86_64]</th>
  </tr>
  <tr>
    <th>Library</th>
    <th>Slower geometric mean</th>
  </tr>
  <tr>
    <td>pairing_heap</td>
    <td>1</td>
  </tr>
  <tr>
    <td>lazy_priority_queue</td>
    <td>1.23x slower</td>

  </tr>
  <tr>
    <td>Fibonacci</td>
    <td>1.78x slower</td>
  </tr>
</table>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhib/pairing_heap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
