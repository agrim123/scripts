#!/bin/ruby

def gen_pass()
  alpha = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
  special = "!@#$%^&*()_+{}|:?><[];/.,-="
  numbers = "1234567890"

  rand_alpha = alpha.chars.shuffle.sample(26).join()
  rand_special = special.chars.shuffle.sample(5).join()
  rand_number = numbers.chars.shuffle.join()
  rand_garbage = (0...20).map { ('a'..'z').to_a[rand(26)] }.join

  rand_pass = "#{rand_alpha}#{rand_number}#{rand_special}#{rand_garbage}"

  n = rand(16...30)

  rand_pass.chars.shuffle.shuffle.sample(n).join()
end

puts gen_pass()
