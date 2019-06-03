class Appointment
  attr_reader :timeblock, :service, :client_name, :serviceProvider
  def initialize(timeblock, service, client_name, serviceProvider) (
    @timeblock = timeblock
    @service = service
    @client_name = client_name
    @serviceProvider = serviceProvider
  )
  end

  def printDetails()
    puts "Provider Name: #{Magenta}#{@serviceProvider.name}#{Reset}, Client Name: #{Cyan}#{@client_name}#{Reset}, Service Name: #{Yellow}#{@service.name}#{Reset}"
    puts "Date: #{Green}#{@timeblock.month}/#{@timeblock.day}/#{@timeblock.year}#{Reset} - Start: #{Green}#{@timeblock.startTime.strftime("%T")}#{Reset}, Stop: #{Green}#{@timeblock.endTime.strftime("%T")}#{Reset}"
    puts "----------------------------------------------------------------------"
  end

end