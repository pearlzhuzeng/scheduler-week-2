  # name
  # phoneNum
  # services = []
  # availability = hash{day:[TimeBlocks]}
  # appointments = []

class ServiceProvider
  attr_reader :name, :phoneNum, :services, :availability, :appointments, :serviceAdd
  def initialize(name, phoneNum, services, availability, appointments) (
    @name = name
    @phoneNum = phoneNum
    @services = services
    @availability = availability
    @appointments = appointments
  )
  end

  def serviceRemove(service_name) (
    for service in @services do
      if service.name == service_name
        @services.delete(service)
      end
    end
    )
  end

  def printServices()
    puts "#{Magenta}#{@name}'s#{Reset} Services:"
    @services.each do |s|
      s.printDetails
    end
  end

  def scheduleView()
    puts "#{Magenta}#{@name}'s#{Reset} Appointments:"
    i = 1;
    @appointments.each do |a|
      puts "#{BgCyan}APPOINTMENT #{i}#{Reset}"
      a.printDetails
      i += 1
    end
  end

  def containsService(name) (
    for service in @services do
      if service.name == name
        return service
      end
    end
    return false
  )
  end

  def serviceAdd(service) (
    @services.push(service)
  )
  end
  
  def is_available(service, timeblock, isWeekly)
    #add check to make sure timeblock is in the future
    is_future_date = (timeblock.startTime >= DateTime.now)
    puts is_future_date

    #check if provider offers service
    service_offered = containsService(service.name)
    puts('past service_offered')

    #check provider's availability
    availability_blocks = @availability[timeblock.dayOfWeek]
    puts('past availability_blocks')
    #IDK what is wrong with this but causes program to crash, commented out for now
    # provider_available = false
    # for block in availability_blocks do
    #   if block.contains(timeblock)
    #     provider_available = true
    #   end
    # end
    #
    provider_available = true

    puts('here')

    #check for overlap with provider's appointments
    no_overlap_with_appointments = true
    puts(@appointments)
    puts(appointments)
    puts('-----------------')
    @appointments.each do |appointment|
      #check for overlap if either appointment is weekly

      if appointment.timeblock.isWeekly || isWeekly
        if appointment.timeblock.dayOfWeek == timeblock.dayOfWeek
          if appointment.timeblock.overlaps_time(timeblock)
            no_overlap_with_appointments = false
          end
        end
      end
      #check for overlap if dates are the same

      if appointment.timeblock.overlaps(timeblock)
        no_overlap_with_appointments = false
      end
    end
    return is_future_date && service_offered && 
      provider_available && no_overlap_with_appointments

  end

  def add_appointment(service, timeblock, client)
    #add appointment to provider's schedule
    if is_available(service, timeblock, timeblock.isWeekly)
      puts("Success!")
      appointment = Appointment.new(timeblock, service, client, self)
      @appointments << appointment
    end

  end

  def add_availability(start_timeblock, end_timeblock)
    #need to add a check here
    availability_block = Availability.new(start_timeblock, end_timeblock, self)
    @availability << availability_block
  end


end