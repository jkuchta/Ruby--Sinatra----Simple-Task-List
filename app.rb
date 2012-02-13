#Task list sample
require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-aggregates'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/mydatabase.db")

class Task
  
  include DataMapper::Resource
  
  property :id,       Serial
  property :name,     String
  property :dueDate,  String
  property :status,   String
  property :type,     String
  property :priority, Integer
  
end

DataMapper.auto_upgrade!


get '/' do
  @tasks = Task.all(:order => [:priority.desc])
  erb :index
end

post '/task' do
  @task = Task.new()
  @task.type = params[:taskType]
  @task.name = params[:taskName]
  @task.dueDate = params[:taskDate]
  @task.status = "Active"
  if Task.min(:priority) == nil
    @task.priority = 1000000
  else
    @task.priority = Task.max(:priority) + 1000000
  end
  puts @task.priority
  if @task.save
    redirect('/')
  end
  
end

get '/complete/:id' do
  task = Task.get(params[:id])
  unless task.nil?
    task.status = "Complete"
    if task.save
      redirect('/')
    end
  end
end

get '/delete/:id' do
  task = Task.get(params[:id])
  unless task.nil?
    task.destroy
  end
  redirect('/')
end

get '/down/:id' do
  downPriorities = nil
  task = Task.get(params[:id])
  unless task.nil?
    downPriorities = repository(:default).adapter.select('SELECT priority from tasks where priority < ' + task.priority.to_s() + ' order by priority desc limit 2')
    puts downPriorities.inspect
    if downPriorities.length == 2
      task.priority = (downPriorities[0] + downPriorities[1]) / 2
    elsif downPriorities.length == 1
      task.priority = downPriorities[0] / 2
    end
    if task.save
      redirect('/')
    end
  end
end


get '/up/:id' do
  upPriorities = nil
  task = Task.get(params[:id])
  unless task.nil?
    upPriorities = repository(:default).adapter.select('SELECT priority from tasks where priority > ' + task.priority.to_s() + ' order by priority asc limit 2')
    puts upPriorities.inspect
    if upPriorities.length == 2
      task.priority = (upPriorities[0] + upPriorities[1]) / 2
    elsif upPriorities.length == 1
      task.priority = (upPriorities[0] * 2) / 1.5
    end
    if task.save
      redirect('/')
    end
  end
end