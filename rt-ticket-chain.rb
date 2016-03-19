#! /usr/bin/env ruby
# -*- encoding : utf-8 -*-
#require 'yaml'

#ticket_id = system ("rt create -t ticket set subject='Ruby script test' Text = 'Что-то сделать' owner = 'Alex' CF-'Order'='2222'")

#ticket_id = '# Ticket 124 created.'
#puts ticket_id.gsub!(/\D/, "")  if ticket_id.match(/\# Ticket \d+ created\./)
#puts tickets.inspect

require 'kwalify'
dryrun = true

# load schema data
schema = Kwalify::Yaml.load_file('schema.yml')

# create validator
validator = Kwalify::Validator.new(schema)

file = 'project.yml'
#file = 'test1.yml'
tickets = Kwalify::Yaml.load_file(file)

## create parser with validator
## (if validator is ommitted, no validation executed.)
parser = Kwalify::Yaml::Parser.new(validator)

document = parser.parse_file(file)

## show errors if exist
errors = parser.errors()
if errors && !errors.empty?
  for e in errors
    puts "#{e.linenum}:#{e.column} [#{e.path}] #{e.message}"
  end
  abort("Please check file #{file}")
end

to_ticket = ["Subject","Text","Owner","Queue","Due"]
to_link = ["DependsOn","DependedOnBy"]

def param_wrap (param,value)
end

#Create tickets and get real rt ticket id
rt_ticket_id = 100

tickets.each do |ticket|
	rt = "rt create -t ticket set"
	ticket.keys.each do |param|
		 rt << " #{param}=\"#{ticket[param]}\"" if to_ticket.include?(param) and ticket[param] 
	end
	
	if dryrun
		puts rt 
		rt_ticket_id += 1
	else
		respond = system (rt) 
		rt_ticket_id = respond.gsub!(/\D/, "")  if respond.match(/\# Ticket \d+ created\./)
	end
		ticket["rt_ticket_id"] = rt_ticket_id
end 

#Create links beetwen tickets
tickets.each do |ticket| #All tickets array
	ticket.keys.each do |param| #Every param in array row
		if to_link.include?(param) and ticket[param]# and linked_ticket[:rt_ticket_id]
			ticket[param].each do |link| #Every value in parametr
				linked_ticket = tickets.find{|t| t["Ticket"] == link}["rt_ticket_id"]
			puts  "rt link #{param} #{ticket["rt_ticket_id"]} #{linked_ticket}" if to_link.include?(param) and ticket[param] and linked_ticket != ticket["rt_ticket_id"]
			end
		end
	end
end 






