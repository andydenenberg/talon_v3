class Ping
  require 'net/ping'
  
  def sweep(base, highest)
    (0..highest).each do |i|
      addr = base + i.to_s
      p = Net::Ping::External.new(addr, port=7, timeout=1)
      response = p.ping?
      if response
          puts addr + ' - ' + response.to_s
      else
          puts addr + ' - ' + 'no response'
      end
    end # loop
  end
    
end



class Ping_sweep  
  
  def test
    require 'net/ping'
    base = '192.168.0.'
    p2 = Net::Ping::External.new('www.denenberg.net')
    response = p2.ping
    puts response
    (1..255).each do |i|
      addr = base + i.to_s
      p1 = Net::Ping::External.new(addr, port=7, timeout=1)
      response = p1.ping?
        if response
            puts addr + ' - ' + response.to_s
        end
    end
  end
  
end

try_it = Ping.new.sweep('192.168.0.', 20)
