class CpuHeavyApp
  def call(env)
    # Do some math
    100.times do |i|
      Math.sqrt(23467**2436) * i / 0.2
    end
    # Return a 200 with a number
    [200, { "Content-Type" => "text/html" }, ["42"]]
  end
end
