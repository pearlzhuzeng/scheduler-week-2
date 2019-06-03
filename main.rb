
require_relative './service'
require_relative './serviceProvider'
require_relative './appointment'
require_relative './timeblock'
require_relative './print'
require_relative './init'
require_relative './colors'
require_relative './availability'
require 'tty-prompt'
$prompt = TTY::Prompt.new

def successPrint
  puts 'Success!'
  puts ''
end

def find_sp_by_service(serviceName)
  sp_with_service = []
  for sp in $all_sp do
    for s in sp.services do
      if s.name == serviceName
        sp_with_service.push(sp)
        break
      end
    end
  end
  return sp_with_service
end

def get_sp_by_name(name)
  sp = $all_sp.select do |sp| 
    sp.name == name
  end
  if sp.length == 1
    return sp.first
  else
    return false
  end
end

def serviceErrorMessage
  puts ''
  puts 'Service Provider Not Found...'
  puts 'Choose from the following:'
  spPrint($all_sp)
end

def serviceAdd
  service_name = $prompt.ask('Service Name:')
  service_price = $prompt.ask('Service Price:')
  service_length = $prompt.ask('Service Length (Mins):')
  loop do
    provider_name = $prompt.ask('Add to which provider?:')
    sp = get_sp_by_name(provider_name)
    if sp
      sp.serviceAdd(Service.new(service_name, service_price, service_length))
      #successPrint()
      break
    else
      serviceErrorMessage()
    end
  end
end

def serviceRemove
  puts "Choose Service to Remove"
  servicePrint($all_sp)
  service_name = $prompt.ask('Service Name:')
  provider_name = $prompt.ask('Service Provider:')
  spToRemove = nil
  isFound = false
  sp = $all_sp.select do |sp|
    if sp.name == provider_name
      spToRemove = sp
      isFound = true
      break      
    end
  end
  if isFound
    spToRemove.serviceRemove(service_name)
    successPrint()
  else
    serviceErrorMessage()
  end
end

def spAdd
  provider_name = $prompt.ask('Provider Name:')
  provider_phone = $prompt.ask('Provider Phone Number:')
  $all_sp.push(ServiceProvider.new(provider_name, provider_phone, [], {}, []))
  successPrint()
end

def spRemove
  provider_name = $prompt.ask('Provider Name To Remove:')
  $all_sp.each do |sp|
    if sp.name == provider_name
      puts "Deleting #{provider_name}"
      confirm = y_or_n()
      if confirm
        $all_sp.delete(sp)
        successPrint()
      else
        puts 'Did Not Delete'
      end
    end
  end
end

def y_or_n
  loop do
    yn = $prompt.ask('(y/n):')
    if yn == 'y'
      return true
    elsif yn == 'n'
      return false
    else
      puts "Enter y or n"
    end
  end
end

def appointmentAdd
  client_name = $prompt.ask('Your Name:')
  puts "Hello #{client_name}! Choose Provider & Service to Schedule"
  servicePrint($all_sp)
  provider_name = $prompt.ask('Provider Name:')
  service_name = $prompt.ask('Service Name:')
  month = $prompt.ask('Date (MM):')
  day = $prompt.ask('Date (DD):')
  year = $prompt.ask('Date (YYYY):')
  start_time = $prompt.ask('Start Time (ex: 13:30):')
  temp = start_time.split(':')
  hour = temp[0].to_i
  minute = temp[1].to_i
  puts 'Will This Appointment Reoccur Weekly?'
  isWeekly = y_or_n()
  puts(isWeekly)
  sp = get_sp_by_name(provider_name)
  service = sp.containsService(service_name)

  start_datetime = DateTime.new(year.to_i, month.to_i, day.to_i, hour, minute)
  sp.add_appointment(service, TimeBlock.new(start_datetime, isWeekly, service.length), client_name)
  successPrint()
end

def availabilityAdd
  provider_name = $prompt.ask('Provider Name:')
  month = $prompt.ask('Date (MM):')
  day = $prompt.ask('Date (DD):')
  year = $prompt.ask('Date (YYYY):')
  start_time = $prompt.ask('Start Time (ex: 13:30):')
  end_time = $prompt.ask('End Time (ex: 14:30):')
  start_temp = start_time.split(':')
  start_hour = start_temp[0].to_i
  start_minute = start_temp[1].to_i

  end_temp = end_time.split(':')
  end_hour = end_temp[0].to_i
  end_minute = end_temp[1].to_i

  sp = get_sp_by_name(provider_name)

  start_datetime = DateTime.new(year.to_i, month.to_i, day.to_i, start_hour, start_minute)
  end_datetime = DateTime.new(year.to_i, month.to_i, day.to_i, end_hour, end_minute)
  #sp.add_appointment(service, TimeBlock.new(month, day, year, start_datetime, isWeekly, service.length), client_name)
  sp.add_availability(start_datetime, end_datetime)
  successPrint()
end

def scheduleView
  puts "Choose a Service Provider to see their schedule:"
  spPrint($all_sp)
  provider_name = $prompt.ask('Provider Name:')
  spToUse = nil
  isFound = false
  sp = $all_sp.select do |sp|
    if sp.name == provider_name
      spToUse = sp
      isFound = true
      break      
    end
  end
  if isFound
    spToUse.scheduleView()
  else
    serviceErrorMessage()
  end

end

def list_commands
  puts "#{BgCyan}COMMAND LIST:#{Reset}"
  puts "--------------------------------"
  puts "#{Cyan}s:add#{Reset} | Add service"
  puts "#{Cyan}s:remove#{Reset} | Remove service"
  puts "#{Cyan}s:list#{Reset} | Display all services"
  puts "#{Cyan}sp:add#{Reset} | Add service provider"
  puts "#{Cyan}sp:remove#{Reset} | Remove service provider"
  puts "#{Cyan}sp:list#{Reset} | Display all service providers"
  puts "#{Cyan}appt:add#{Reset} | Add new appointment"
  puts "#{Cyan}avail:add#{Reset} | Add new availability block"
  puts "#{Cyan}schedule:view#{Reset} | View schedule"
  puts "--------------------------------"
end

commands = {
  's:add' => Proc.new{serviceAdd},
  's:remove' => Proc.new{serviceRemove},
  's:list' => Proc.new{servicePrint($all_sp)},
  'sp:add' => Proc.new{spAdd},
  'sp:remove' => Proc.new{spRemove},
  'sp:list' => Proc.new{spPrint($all_sp)},
  'appt:add' => Proc.new{appointmentAdd},
  'avail:add' => Proc.new{availabilityAdd},
  'schedule:view' => Proc.new{scheduleView},
}

# INITIALIZE
$all_sp = initData

loop do
  next_prompt = $prompt.ask('Please enter a command:')
  puts ''
  isCommand = false
  commands.each do |command, function|
    if next_prompt == command
      function.call()
      isCommand = true
    end
  end
  if !isCommand
    puts "Unknown command #{Red}#{next_prompt}#{Reset}"
    list_commands
    next
  end
end



