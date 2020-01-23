require 'memcache'
require 'byebug'

$client = MemCache.new 'localhost:1892'


def display_key
  puts $client.get('testkey', raw: true)
  puts "------"
  puts
end

# key, value, expiration, raw 
$client.set('testkey', 'test value', 0, true)
$client.set('testkey', 'test', 0, true)

# key, raw
display_key

$client.add('testkey', 'test testkey', 0, true)

display_key

$client.replace('testkey', 'test testkey replace', 0, true)

display_key

$client.append('testkey', ' appended')

display_key

$client.prepend('testkey', 'prepended ')

display_key

$client.cas('testkey', 0, true){"testkey cas"}

display_key
# raw means that the content will not be Marshalled
# https://ruby-doc.org/core-2.6.3/Marshal.html