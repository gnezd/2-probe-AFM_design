require 'pry'

# Check rules
# No standardized form yet for rules, if-else chain for now
def check(conf)
  pass = true
  #puts "________Checking__________"
  #puts conf.map {|line| "#{line.join '-'}\n"}
  # Tip 1 ability to approach
  diff = (0..conf[0].size-1).map {|act_id| conf[0][act_id] ^ conf[2][act_id]}
  return false if diff[2]|diff[3] == 0
  # Tip 1 scan
  return false if diff[0]|diff[1] == 0

  # Tip2 approach and scan
  diff = (0..conf[1].size-1).map {|act_id| conf[1][act_id] ^ conf[2][act_id]}
  return false if diff[0]|diff[1] == 0
  return false if diff[2]|diff[3] == 0

  # Tip1-tip2 coarse alignment and relative scan
  diff = (0..conf[0].size-1).map {|act_id| conf[0][act_id] ^ conf[1][act_id]}
  return false if diff[0]|diff[1] == 0
  return false if diff[2]|diff[3] == 0

  # Check for bridging
  (0..conf.size-1).each do |ith_component|
    total_intersect = [1,1,1,1]
    (0..conf.size-1).each do |jth_component|
      next if ith_component == jth_component
      i_intersect = (0..conf[ith_component].size-1).map {|act_id| conf[ith_component][act_id] & conf[jth_component][act_id]}
      next if i_intersect == [0,0,0,0]
      i_sub_j = (0..conf[ith_component].size-1).map {|act_id| (conf[ith_component][act_id] > conf[jth_component][act_id]) ? 1 : 0}
      j_sub_i = (0..conf[ith_component].size-1).map {|act_id| (conf[jth_component][act_id] > conf[ith_component][act_id]) ? 1 : 0}
      if (i_sub_j != [0,0,0,0]) && (j_sub_i != [0,0,0,0])
        #puts "Bridging at #{ith_component}-#{jth_component}: isj #{i_sub_j.join}, jsi #{j_sub_i.join}"
        return false
      end
      total_intersect = (0..total_intersect.size-1).map {|act_id| i_intersect[act_id] & total_intersect[act_id]}
      return false if total_intersect == [0,0,0,0]
    end
      
  end
  return true
end

def comb(n)
  conf = Array.new(3) {[0,0,0,0]}
  (0..11).each do |bit|
    #puts [bit/4, bit%4].join('-')
    conf[bit/4][bit%4] = ("%012b" % n)[bit].to_i
  end
  conf
end

# Generate assembly configuration of a possible 2-probe AFM
# With actuatorss:
# piezo 1(picocube), piezo 2(563.3CD), stage 1, and stage 2
actuators = ['pz1', 'pz2', 'st1', 'st2']
# To position parts:
# sample, tip1, and tip2
# (For now we assume that tip1 always reside with laser-PSD, and that tip 2 moves with the microscope)
parts = ['tip1', 'tip2', 'sample']
conf = []

pass = false

#binding.pry

(0..2**12-1).each do |comb_i|  #puts conf.join
  conf = comb(comb_i)
  pass = check(conf)
  if pass
    puts "_____Config #{comb_i}_____"
    puts conf.map {|line| "#{line.join '-'}\n"}
  end
end